#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from pathlib import Path

import MySQLdb


ROOT_DIR = Path(__file__).resolve().parent
PROJECT_DIR = ROOT_DIR
SCHEMA_SQL = ROOT_DIR.parent / "GREGoR Data Model v1.12.sql"
DATA_SQL = ROOT_DIR.parent / "inserts_kv.sql"
TMP_DIR = Path(os.environ.get("TMPDIR", "/tmp")) / "gregor_setup"
NORMALIZED_SCHEMA = TMP_DIR / "schema.mysql.sql"
NORMALIZED_DATA = TMP_DIR / "data.mysql.sql"

DB_NAME = os.environ.get("DJANGO_DB_NAME", "gregor")
DB_USER = os.environ.get("DJANGO_DB_USER", "gregor")
DB_PASSWORD = os.environ.get("DJANGO_DB_PASSWORD", "gregor")
DB_HOST = os.environ.get("DJANGO_DB_HOST", "db")
DB_PORT = int(os.environ.get("DJANGO_DB_PORT", "3306"))

SUPERUSER_USERNAME = os.environ.get("DJANGO_SUPERUSER_USERNAME", "admin")
SUPERUSER_EMAIL = os.environ.get("DJANGO_SUPERUSER_EMAIL", "admin@example.com")
SUPERUSER_PASSWORD = os.environ.get("DJANGO_SUPERUSER_PASSWORD", "admin12345")
MANAGE_PY = PROJECT_DIR / "manage.py"


def run(cmd: list[str], *, stdout=None) -> None:
    subprocess.run(cmd, cwd=PROJECT_DIR, check=True, stdout=stdout)


def wait_for_database() -> None:
    while True:
        try:
            conn = MySQLdb.connect(
                host=DB_HOST,
                port=DB_PORT,
                user=DB_USER,
                passwd=DB_PASSWORD,
                db=DB_NAME,
            )
            conn.close()
            return
        except MySQLdb.OperationalError:
            print("Waiting for MySQL...", flush=True)
            subprocess.run(["sleep", "2"], check=True)


def normalize_sql(sql_text: str) -> str:
    sql_text = sql_text.replace("`", "")
    sql_text = re.sub(r"\bstring\b", "VARCHAR(255)", sql_text, flags=re.IGNORECASE)
    sql_text = re.sub(r"\benumeration\b", "VARCHAR(255)", sql_text, flags=re.IGNORECASE)
    sql_text = re.sub(r"\binteger\b", "INT", sql_text, flags=re.IGNORECASE)
    sql_text = re.sub(r"\bfloat\b", "DOUBLE", sql_text, flags=re.IGNORECASE)
    sql_text = re.sub(r"\bdouble\b", "DOUBLE", sql_text, flags=re.IGNORECASE)
    sql_text = re.sub(r"^ALTER TABLE .*ADD FOREIGN KEY .*;\s*$", "", sql_text, flags=re.IGNORECASE | re.MULTILINE)
    return sql_text


def ensure_normalized_sql() -> None:
    TMP_DIR.mkdir(parents=True, exist_ok=True)
    NORMALIZED_SCHEMA.write_text(normalize_sql(SCHEMA_SQL.read_text()))
    NORMALIZED_DATA.write_text(normalize_sql(DATA_SQL.read_text()))


def table_exists(table_name: str) -> bool:
    conn = MySQLdb.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        passwd=DB_PASSWORD,
        db=DB_NAME,
    )
    try:
        with conn.cursor() as cursor:
            cursor.execute("SHOW TABLES LIKE %s", (table_name,))
            return cursor.fetchone() is not None
    finally:
        conn.close()


def load_database_if_needed() -> None:
    if table_exists("participant"):
        print("Database already initialized; skipping SQL import.", flush=True)
        return

    print("Loading GREGoR schema and seed data into MySQL...", flush=True)
    mysql_base = [
        "mysql",
        "--skip-ssl",
        "-h",
        DB_HOST,
        "-P",
        str(DB_PORT),
        "-u",
        DB_USER,
        f"-p{DB_PASSWORD}",
        DB_NAME,
    ]
    with NORMALIZED_SCHEMA.open("rb") as schema_file:
        subprocess.run(mysql_base, stdin=schema_file, check=True)
    with NORMALIZED_DATA.open("rb") as data_file:
        subprocess.run(mysql_base, stdin=data_file, check=True)


def inspect_models() -> None:
    with (PROJECT_DIR / "gregor_app" / "models.py").open("w") as models_file:
        run(["python", str(MANAGE_PY), "inspectdb"], stdout=models_file)


def inject_comments_and_choices() -> None:
    schema_text = SCHEMA_SQL.read_text()
    models_path = PROJECT_DIR / "gregor_app" / "models.py"
    models_text = models_path.read_text()

    def build_comment_map(sql_text: str) -> dict[str, dict[str, str]]:
        comment_map: dict[str, dict[str, str]] = {}
        table_name = None
        for line in sql_text.splitlines():
            table_match = re.match(r"CREATE TABLE `([^`]+)` \(", line.strip())
            if table_match:
                table_name = table_match.group(1)
                comment_map.setdefault(table_name, {})
                continue
            if table_name is None:
                continue
            if line.strip().startswith(");"):
                table_name = None
                continue
            field_match = re.match(r"\s*`([^`]+)`\s+[^C]+(?:COMMENT\s+'((?:''|[^'])*)')?", line)
            if field_match and field_match.group(2):
                column = field_match.group(1)
                comment = field_match.group(2).replace("''", "'")
                comment_map[table_name][column] = comment
        return comment_map

    def inject_help_text(models: str, comments: dict[str, dict[str, str]]) -> str:
        output = []
        current_table = None
        for line in models.splitlines():
            meta_match = re.match(r"\s*db_table = '([^']+)'", line)
            if meta_match:
                current_table = meta_match.group(1)
            field_match = re.match(r"(\s+)(\w+)\s*=\s*models\.(\w+)\((.*)\)\s*$", line)
            if field_match and current_table and current_table in comments:
                indent, field_name, field_type, args = field_match.groups()
                comment = comments[current_table].get(field_name)
                if comment and "help_text=" not in args:
                    args = args.rstrip()
                    if args:
                        args += ", "
                    args += f"help_text={json.dumps(comment)}"
                    line = f"{indent}{field_name} = models.{field_type}({args})"
            output.append(line)
        return "\n".join(output) + "\n"

    def choice_literal(values: list[str]) -> str:
        return "[" + ", ".join(f"({json.dumps(v)}, {json.dumps(v)})" for v in values) + "]"

    def fetch_choices() -> dict[tuple[str, str], list[str]]:
        conn = MySQLdb.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            passwd=DB_PASSWORD,
            db=DB_NAME,
        )
        try:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT table_name, column_name, key_value
                    FROM key_values
                    ORDER BY table_name, column_name, key_value
                    """
                )
                choices_map: dict[tuple[str, str], list[str]] = {}
                for table_name, column_name, key_value in cursor.fetchall():
                    choices_map.setdefault((table_name, column_name), []).append(key_value)
                return choices_map
        finally:
            conn.close()

    def inject_choices(models: str, choices_map: dict[tuple[str, str], list[str]]) -> str:
        output = []
        current_table = None
        for line in models.splitlines():
            class_match = re.match(r"class\s+(\w+)\(models\.Model\):", line)
            if class_match:
                current_table = class_match.group(1).lower()
            field_match = re.match(r"(\s+)(\w+)\s*=\s*models\.(\w+)\((.*)\)\s*$", line)
            if field_match and current_table:
                indent, field_name, field_type, args = field_match.groups()
                choices = choices_map.get((current_table, field_name))
                if choices and "choices=" not in args:
                    args = args.rstrip()
                    if args:
                        args += ", "
                    args += f"choices={choice_literal(choices)}"
                    line = f"{indent}{field_name} = models.{field_type}({args})"
            output.append(line)
        return "\n".join(output) + "\n"

    models_path.write_text(inject_help_text(models_text, build_comment_map(schema_text)))
    if table_exists("key_values"):
        models_path.write_text(inject_choices(models_path.read_text(), fetch_choices()))


def ensure_superuser() -> None:
    shell_code = f"""
from django.contrib.auth import get_user_model

User = get_user_model()
username = {SUPERUSER_USERNAME!r}
email = {SUPERUSER_EMAIL!r}
password = {SUPERUSER_PASSWORD!r}

if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username=username, email=email, password=password)
    print(f"Created superuser: {{username}}")
else:
    print(f"Superuser already exists: {{username}}")
"""
    run(["python", str(MANAGE_PY), "shell", "-c", shell_code])


def main() -> int:
    wait_for_database()
    ensure_normalized_sql()
    load_database_if_needed()
    inspect_models()
    inject_comments_and_choices()
    run(["python", str(MANAGE_PY), "migrate", "--run-syncdb"])
    ensure_superuser()
    os.execvp("python", ["python", str(MANAGE_PY), "runserver", "0.0.0.0:8000"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
