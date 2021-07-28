from argparse import ArgumentParser
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# pylint: disable=no-name-in-module
from google.cloud import bigquery  # type: ignore


class TableChanges:
    new_columns: List[bigquery.SchemaField] = []
    existing_columns: List[bigquery.SchemaField] = []
    changed_columns_property_keys: Dict = defaultdict(list)


def check_for_existing_column_changes(test_table: bigquery.Table,
                                      prod_table: bigquery.Table,
                                      table_changes: TableChanges):
    schema_tuples = list(zip(test_table.schema, prod_table.schema))
    for schema_tuple in schema_tuples:
        if schema_tuple[0] != schema_tuple[1]:
            test_table_field: bigquery.SchemaField = schema_tuple[0]
            prod_table_field: bigquery.SchemaField = schema_tuple[1]
            table_changes.existing_columns.append(test_table_field)
            if test_table_field.name != prod_table_field.name:
                print(
                    f"Column name mismatch detected for table: {test_table.table_id}"
                )
                table_changes.changed_columns_property_keys[
                    test_table_field.name].append('name')
            if test_table_field.description != prod_table_field.description:
                print(
                    f"Column description mismatch detected for table: {test_table.table_id}"
                )
                table_changes.changed_columns_property_keys[
                    test_table_field.name].append('description')
            if test_table_field.field_type != prod_table_field.field_type:
                print(
                    f"Column field type mismatch detected for table: {test_table.table_id}"
                )
                table_changes.changed_columns_property_keys[
                    test_table_field.name].append('field_type')
            if test_table_field.mode != prod_table_field.mode:
                print(
                    f"Column mode mismatch detected for table: {test_table.table_id}"
                )
                table_changes.changed_columns_property_keys[
                    test_table_field.name].append('mode')


def check_for_new_columns(test_table: bigquery.Table,
                          prod_table: bigquery.Table,
                          table_changes: TableChanges):
    if len(test_table.schema) > len(prod_table.schema):
        print(f"New columns detected for table: {test_table.table_id}")
        table_changes.new_columns = test_table.schema[len(prod_table.schema):]


def write_table_update_ddl(file: Path, table_changes: TableChanges,
                           output_ddl_dir: str):
    output_ddl_dir_path = Path(output_ddl_dir)
    output_ddl_dir_path.mkdir(exist_ok=True, parents=True)
    input_ddl = open(file).read()
    with open(output_ddl_dir_path / f'{file.stem}.sqlx', 'w') as ddl_file:
        create_as_select_statement = f' AS SELECT * '
        # Add SQL syntax for handling data type changes on existing columns
        cols_with_changes = table_changes.changed_columns_property_keys.keys()
        if table_changes.existing_columns:
            create_as_select_statement += f"EXCEPT({','.join(cols_with_changes)}), "
        for col_name in cols_with_changes:
            changed_fields: List[str] = list(
                table_changes.changed_columns_property_keys.get(
                    col_name))  # type: ignore
            if 'field_type' in changed_fields:
                create_as_select_statement += f"CAST({col_name} AS TYPE) AS {col_name}"
        create_as_select_statement += ','
        # Add SQL syntax for setting default values on new columns
        for new_col in table_changes.new_columns:
            create_as_select_statement += f"'default value' AS {new_col.name},"
        create_as_select_statement += " FROM ${self()}"
        update_ddl = 'config { hasOutput: true }\n\n' + input_ddl
        update_ddl = update_ddl.replace("CREATE TABLE", "CREATE OR REPLACE TABLE")
        update_ddl = update_ddl.replace(";", create_as_select_statement)
        ddl_file.write(update_ddl)


def check_ddl_directory_for_changes(bq_client: bigquery.Client, input_ddl_dir,
                                    output_ddl_dir, test_project_id,
                                    test_dataset_id, prod_project_id,
                                    prod_dataset_id):
    for file in Path(input_ddl_dir).glob('*.sql'):
        test_table_id = file.stem
        test_table_ref = bq_client.get_table(
            bigquery.Table.from_string(
                f"{test_project_id}.{test_dataset_id}.{test_table_id}"))
        prod_table_ref = bq_client.get_table(
            bigquery.Table.from_string(
                f"{prod_project_id}.{prod_dataset_id}.{test_table_id}"))

        test_table: bigquery.Table = bq_client.get_table(test_table_ref)
        prod_table: bigquery.Table = bq_client.get_table(prod_table_ref)
        table_changes: TableChanges = TableChanges()
        check_for_existing_column_changes(test_table, prod_table, table_changes)
        check_for_new_columns(test_table, prod_table, table_changes)
        write_table_update_ddl(file, table_changes, output_ddl_dir)


def get_cmd_line_args():
    parser = ArgumentParser(
        description='This tool keeps BigQuery in sync with DDLs from a repo.')
    parser.add_argument('input_ddl_dir', help='Directory holding input DDLs')
    parser.add_argument(
        '--test-project-id',
        help='BigQuery project in which the tool deploys input DDLs.')
    parser.add_argument(
        '--test-dataset-id',
        help='BigQuery dataset in which the tool deploys input DDLs.')
    parser.add_argument(
        '--prod-project-id',
        help='BigQuery project in which the tool deploys changes.')
    parser.add_argument('--prod-dataset-id',
                        help='GCP Project in which the tool deploys changes.')
    parser.add_argument(
        '--output-ddl-dir',
        help='GCP Project in which the tool deploys input DDLs.')
    return parser.parse_args()


def main():
    args = get_cmd_line_args()
    bq_client = bigquery.Client(project=args.test_project_id)

    check_ddl_directory_for_changes(bq_client, args.input_ddl_dir,
                                    args.output_ddl_dir, "danny-bq",
                                    "dataform_test", "danny-bq",
                                    "dataform_prod")


if __name__ == '__main__':
    main()
