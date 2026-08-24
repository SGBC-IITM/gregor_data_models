#!/usr/bin/env python3
"""Generate key_values INSERT statements from the GREGoR JSON model."""

import argparse
import json


def sql_quote(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def generate(input_path: str) -> str:
    with open(input_path, encoding="utf-8") as model_file:
        model = json.load(model_file)

    rows = []
    for table in model["tables"]:
        for column in table["columns"]:
            enumerations = column.get("enumerations")
            if isinstance(enumerations, list):
                rows.extend(
                    (table["table"], column["column"], value)
                    for value in enumerations
                )
            elif enumerations is not None:
                values = str(enumerations).split()
                rows.extend(
                    (table["table"], column["column"], value)
                    for value in values
                )

    values = ",\n".join(
        "  ({} , {} , {})".format(*(sql_quote(value) for value in row))
        for row in rows
    )
    return (
        "INSERT INTO `key_values` (`table_name`, `column_name`, `key_value`) "
        "VALUES\n"
        + values
        + "\nON DUPLICATE KEY UPDATE `key_value` = VALUES(`key_value`);\n"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", default="GREGoR_data_model.json")
    args = parser.parse_args()
    print(generate(args.input), end="")


if __name__ == "__main__":
    main()
