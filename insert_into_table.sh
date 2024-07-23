#!/bin/bash

insert_into_table() {
    db_path="./databases"

    if [[ -z "$CURRENT_DB" ]]; then
        echo "No database is currently selected. Please connect to a database first."
        exit 1
    fi

    db_folder="$db_path/$CURRENT_DB"

    while true; do
        read -p "Enter table name (or type 'exit' to cancel): " table_name
        if [[ "$table_name" == "exit" ]]; then
            clear
            echo "Operation canceled."
            . ./tables_menu.sh
        elif [[ -z "$table_name" ]]; then
            echo "Table name cannot be null. Please try again or type 'exit' to cancel."
        elif [[ ! "$table_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            echo "Table name contains invalid characters. Only letters, numbers, and underscores are allowed, and it must start with a letter. Please try again or type 'exit' to cancel."
        else
            table_path="$CURRENT_DB/$table_name"
            if [[ ! -d "$table_path" ]]; then
                echo "Table '$table_name' does not exist in database '$db_name'. Please try again or type 'exit' to cancel."
            else
                break
            fi
        fi
    done

    metadata_file="$table_path/metadata.txt"
    data_file="$table_path/data.txt"

    if [[ ! -f "$metadata_file" ]]; then
        echo "Metadata file does not exist for table '$table_name'."
        exit 1
    fi

    declare -A field_types
    declare -A field_names
    primary_key_field=""

    while IFS=: read -r field_name field_type is_primary_key; do
        field_names["$field_name"]="$field_name"
        field_types["$field_name"]="$field_type"
        if [[ "$is_primary_key" == "y" ]]; then
            primary_key_field="$field_name"
        fi
    done < "$metadata_file"

    if [[ -z "$primary_key_field" ]]; then
        echo "No primary key defined for table '$table_name'."
        exit 1
    fi

    declare -A new_row

    for field in "${!field_names[@]}"; do
        while true; do
            read -p "Enter value for $field (${field_types[$field]}): " value
            if [[ "${field_types[$field]}" == "integer" ]]; then
                if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                    echo "Invalid value. $field must be an integer. Please try again."
                else
                    new_row["$field"]="$value"
                    break
                fi
            elif [[ "${field_types[$field]}" == "string" ]]; then
                if [[ -z "$value" ]]; then
                    echo "Invalid value. $field must be a non-empty string. Please try again."
                else
                    new_row["$field"]="$value"
                    break
                fi
            fi
        done
    done

    if [[ -s "$data_file" ]]; then
        while IFS= read -r line; do
            pk_value=$(echo "$line" | cut -d':' -f1)
            if [[ "${new_row[$primary_key_field]}" == "$pk_value" ]]; then
                echo "Duplicate entry for primary key $primary_key_field. Operation aborted."
                exit 1
            fi
        done < "$data_file"
    fi

    row_data=""
    for field in "${!field_names[@]}"; do
        row_data+="${new_row[$field]}:"
    done

    row_data=${row_data%:}

    echo "$row_data" >> "$data_file"
    echo "Row inserted successfully into table '$table_name' in database '$CURRENT_DB'."
}

insert_into_table