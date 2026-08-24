#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$ROOT_DIR"
DB_NAME="${DJANGO_DB_NAME:-gregor}"
DB_USER="${DJANGO_DB_USER:-gregor}"
DB_PASSWORD="${DJANGO_DB_PASSWORD:-gregor}"
DB_HOST="${DJANGO_DB_HOST:-db}"
DB_PORT="${DJANGO_DB_PORT:-3306}"
SCHEMA_SQL="$ROOT_DIR/../GREGoR Data Model v1.12.sql"
DATA_SQL="$ROOT_DIR/../inserts_kv.sql"

cd "$PROJECT_DIR"

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

# shellcheck disable=SC1091
source .venv/bin/activate

python -m pip install --upgrade pip
python -m pip install -r requirements.txt

until python - <<PY
import os
import MySQLdb

conn = MySQLdb.connect(
    host=os.environ["DJANGO_DB_HOST"],
    port=int(os.environ["DJANGO_DB_PORT"]),
    user=os.environ["DJANGO_DB_USER"],
    passwd=os.environ["DJANGO_DB_PASSWORD"],
    db=os.environ["DJANGO_DB_NAME"],
)
conn.close()
PY
do
  sleep 2
done

mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$SCHEMA_SQL"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$DATA_SQL"

python manage.py inspectdb > gregor_app/models.py

DJANGO_SUPERUSER_USERNAME="${DJANGO_SUPERUSER_USERNAME:-admin}"
DJANGO_SUPERUSER_EMAIL="${DJANGO_SUPERUSER_EMAIL:-admin@example.com}"
DJANGO_SUPERUSER_PASSWORD="${DJANGO_SUPERUSER_PASSWORD:-admin12345}"

python manage.py migrate --run-syncdb
python manage.py shell <<PY
from django.contrib.auth import get_user_model

User = get_user_model()
username = "${DJANGO_SUPERUSER_USERNAME}"
email = "${DJANGO_SUPERUSER_EMAIL}"
password = "${DJANGO_SUPERUSER_PASSWORD}"

if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username=username, email=email, password=password)
    print(f"Created superuser: {username}")
else:
    print(f"Superuser already exists: {username}")
PY

exec python manage.py runserver 0.0.0.0:8000
