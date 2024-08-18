#!/bin/bash

insert_into_table() {
    while true; do
        read -r -p "Enter table name (or type 'exit' to cancel): " table_name
        if [[ "$table_name" == "exit" ]]; then
            clear
            echo "Operation canceled."
            . ./tables_menu.sh
        elif [[ -z "$table_name" ]]; then
            echo "Table name cannot be empty. Please try again or type 'exit' to cancel."
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

    declare -A column_types
    declare -a column_order
    primary_key_column=""

    while IFS=: read -r column_name column_type is_primary_key; do
        column_types["$column_name"]="$column_type"
        column_order+=("$column_name")
        if [[ "$is_primary_key" == "y" ]]; then
            primary_key_column="$column_name"
        fi
    done < "$metadata_file"

    if [[ -z "$primary_key_column" ]]; then
        echo "No primary key defined for table '$table_name'."
        exit 1
    fi

    declare -A new_row

    for column in "${column_order[@]}"; do
        while true; do
            read -r -p "Enter value for $column (${column_types[$column]}): " value

            if [[ -z "$value" ]]; then
                echo "Invalid value. $column cannot be null. Please try again."
                continue
            fi

            if [[ "${column_types[$column]}" == "integer" ]]; then
                if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                    echo "Invalid value. $column must be an integer. Please try again."
                else
                    new_row["$column"]="$value"
                    break
                fi
            elif [[ "${column_types[$column]}" == "string" ]]; then
                if [[ ! "$value" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
                    echo "Invalid value. $column must be a valid string. Please try again."
                else
                    new_row["$column"]="$value"
                    break
                fi
            fi
        done
    done

    while true; do
        is_duplicate=false
        if [[ -s "$data_file" ]]; then
            while IFS= read -r line; do
                pk_value=$(echo "$line" | cut -d':' -f1)
                if [[ "${new_row[$primary_key_column]}" == "$pk_value" ]]; then
                    echo "Duplicate entry for primary key $primary_key_column. Please enter a new value."
                    is_duplicate=true
                    break
                fi
            done < "$data_file"
        fi

        if ! $is_duplicate; then
            break
        fi

        while true; do
            read -r -p "Enter a new value for primary key $primary_key_column: " new_value
            if [[ "${column_types[$primary_key_column]}" == "integer" ]]; then
                if ! [[ "$new_value" =~ ^[0-9]+$ ]]; then
                    echo "Invalid value. Primary key must be an integer. Please try again."
                else
                    new_row["$primary_key_column"]="$new_value"
                    break
                fi
            elif [[ "${column_types[$primary_key_column]}" == "string" ]]; then
                if [[ -z "$new_value" ]]; then
                    echo "Invalid value. Primary key must be a non-empty string. Please try again."
                else
                    new_row["$primary_key_column"]="$new_value"
                    break
                fi
            fi
        done
    done

    row_data=""
    for column in "${column_order[@]}"; do
        row_data+="${new_row[$column]}:"
    done

    row_data=${row_data%:}

    echo "$row_data" >> "$data_file"
    echo "Row inserted successfully into table '$table_name' in database '$db_name'."
    echo "Press any key to go to the tables menu..."
    read -n 1 -s 
    clear
    . ./tables_menu.sh
}
insert_into_table