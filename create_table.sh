#!/bin/bash

create_table() {
    while true; do
        read -p "Enter the name of the table you want to add to database '$DB_NAME' (or type 'exit' to cancel): " table_name
        if [[ "$table_name" == "exit" ]]; then
            echo "Operation canceled."
            echo "Press any key to go to the tables menu..."
            read -n 1 -s 
            clear
            . ./tables_menu.sh
        elif [[ -z "$table_name" ]]; then
            echo "Table name cannot be null. Please try again or type 'exit' to cancel."
        elif [[ ! "$table_name" =~ ^[a-zA-Z] ]]; then
            echo "Table name must start with a letter. Please try again or type 'exit' to cancel."
        elif [[ ! "$table_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            echo "Table name contains invalid characters. Only letters, numbers, and underscores are allowed. Please try again or type 'exit' to cancel."
        else
            break
        fi
    done

        if [ -d "$table_name" ]; then
            echo "Table '$table_name' already exists. Please choose a different name."
            exit 1
        else

        while true; do
            read -p "Enter number of fields (or type 'exit' to cancel): " num_fields
        if [[ "$num_fields" == "exit" ]]; then
            echo "Operation canceled."
            exit
        elif [[ -z "$num_fields" ]]; then
            echo "Number of fields cannot be null. Please try again or type 'exit' to cancel."
        elif ! [[ "$num_fields" =~ ^[0-9]+$ ]]; then
            echo "Number of fields must be a valid integer. Please try again or type 'exit' to cancel."
        else
            break
        fi
    done
            mkdir -p "$CURRENT_DB/$table_name"
            metadata_file="$CURRENT_DB/$table_name/metadata.txt"
            data_file="$CURRENT_DB/$table_name/data.txt"
            touch "$metadata_file"
            touch "$data_file"
        fi

    if [[ "$num_fields" -eq 1 ]]; then
        pk_field_num=1
        echo "Since only one field is specified, it will be set as the primary key by default."
        primary_key_field=""
    else
        while true; do
            read -p "Which field is the primary key? Enter field number (1 to $num_fields, or type 'exit' to cancel): " pk_field_num
            if [[ "$pk_field_num" == "exit" ]]; then
                echo "Operation canceled."
                exit
            elif ! [[ "$pk_field_num" =~ ^[0-9]+$ ]] || (( pk_field_num < 1 || pk_field_num > num_fields )); then
                echo "Invalid field number. Please enter a number between 1 and $num_fields or type 'exit' to cancel."
            else
                break
            fi
        done
    fi

    for (( i=1; i<=num_fields; i++ )); do
        while true; do
            read -p "Enter field $i name (or type 'exit' to cancel): " field_name
            if [[ "$field_name" == "exit" ]]; then
                echo "Operation canceled."
                exit
               elif [[ -z "$field_name" ]]; then
                echo "Field name cannot be null. Please try again or type 'exit' to cancel."
            elif [[ ! "$field_name" =~ ^[a-zA-Z] ]]; then
                echo "Field name must start with a letter. Please try again or type 'exit' to cancel."
            elif [[ ! "$field_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
                echo "Field name contains invalid characters. Only letters, numbers, and underscores are allowed. Please try again or type 'exit' to cancel."
            else
                break
            fi
        done

        while true; do
            if [[ "$field_name" =~ id$ ]]; then
                echo "Field name is 'id', setting field type to 'integer'."
                field_type="integer"
                break
            else
                read -p "Enter field $i type (integer/string, or type 'exit' to cancel): " field_type
                if [[ "$field_type" == "exit" ]]; then
                    echo "Operation canceled."
                    exit
                elif [[ "$field_type" != "integer" && "$field_type" != "string" ]]; then
                    echo "Invalid field type. Please enter 'integer' or 'string' or type 'exit' to cancel."
                else
                    break
                fi
            fi
        done

        if (( i == pk_field_num )); then
            is_primary_key="y"
            primary_key_field="$field_name"
        else
            is_primary_key="n"
        fi
        echo "${field_name}:${field_type}:${is_primary_key}" >> "$metadata_file"
    done
    echo "Table '$table_name' created successfully."
    echo "Press any key to go to the tables menu..."
    read -n 1 -s 
    clear
    . ./tables_menu.sh
}
create_table