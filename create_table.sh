create_table.sh
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
            read -p "Enter number of columns (or type 'exit' to cancel): " num_columns
            if [[ "$num_columns" == "exit" ]]; then
                echo "Operation canceled."
                exit
            elif [[ -z "$num_columns" ]]; then
                echo "Number of columns cannot be null. Please try again or type 'exit' to cancel."
            elif ! [[ "$num_columns" =~ ^[0-9]+$ ]]; then
                echo "Number of columns must be a valid integer. Please try again or type 'exit' to cancel."
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

    if [[ "$num_columns" -eq 1 ]]; then
        pk_column_num=1
        echo "Since only one column is specified, it will be set as the primary key by default."
        primary_key_column=""
    else
        while true; do
            read -p "Which column is the primary key? Enter column number (1 to $num_columns, or type 'exit' to cancel): " pk_column_num
            if [[ "$pk_column_num" == "exit" ]]; then
                echo "Operation canceled."
                exit
            elif ! [[ "$pk_column_num" =~ ^[0-9]+$ ]] || (( pk_column_num < 1 || pk_column_num > num_columns )); then
                echo "Invalid column number. Please enter a number between 1 and $num_columns or type 'exit' to cancel."
            else
                break
            fi
        done
    fi

    for (( i=1; i<=num_columns; i++ )); do
        while true; do
            read -p "Enter column $i name (or type 'exit' to cancel): " column_name
            if [[ "$column_name" == "exit" ]]; then
                echo "Operation canceled."
                exit
            elif [[ -z "$column_name" ]]; then
                echo "Column name cannot be null. Please try again or type 'exit' to cancel."
            elif [[ ! "$column_name" =~ ^[a-zA-Z] ]]; then
                echo "Column name must start with a letter. Please try again or type 'exit' to cancel."
            elif [[ ! "$column_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
                echo "Column name contains invalid characters. Only letters, numbers, and underscores are allowed. Please try again or type 'exit' to cancel."
            elif [[ " ${column_names[@]} " =~ " $column_name " ]]; then
                echo "Column name '$column_name' already exists. Please choose a different name."
            else
                column_names+=("$column_name")
                break
            fi
        done

        while true; do
            read -p "Enter column $i type (integer/string, or type 'exit' to cancel): " column_type
            if [[ "$column_type" == "exit" ]]; then
                echo "Operation canceled."
                exit
            elif [[ "$column_type" != "integer" && "$column_type" != "string" ]]; then
                echo "Invalid column type. Please enter 'integer' or 'string' or type 'exit' to cancel."
            else
                break
            fi
        done

        if (( i == pk_column_num )); then
            is_primary_key="y"
            primary_key_column="$column_name"
        else
            is_primary_key="n"
        fi
        echo "${column_name}:${column_type}:${is_primary_key}" >> "$metadata_file"
    done
    echo "Table '$table_name' created successfully."
    echo "Press any key to go to the tables menu..."
    read -n 1 -s 
    clear
    . ./tables_menu.sh
}
create_table