#!/bin/bash

select_from_table() {
    while true; do
        read -r -p 'Enter the table name to select from (or type "exit" to cancel): ' table_name

        if [[ "$table_name" == "exit" ]]; then
            echo "Operation canceled."
            echo "Press any key to go to the tables menu..."
            read -n 1 -s  
            clear
            . ./tables_menu.sh 
            exit 0
        fi

        if [[ "$table_name" =~ [^a-zA-Z0-9_-] ]]; then
            echo "Invalid table name. Only letters, numbers, underscores, and dashes are allowed. Please try again or type 'exit' to cancel."
            continue
        fi

        if [[ -z "$table_name" ]]; then
            echo "Table name cannot be null. Please try again or type 'exit' to cancel."
            continue
        fi

        table_path="$CURRENT_DB/$table_name"
        if [[ ! -d "$table_path" ]]; then
            echo "Table '$table_name' does not exist. Please try again."
        else
            break
        fi
    done

    metadata_file="$table_path/metadata.txt"
    data_file="$table_path/data.txt"

    if [[ ! -f "$metadata_file" ]]; then
        echo "Metadata file does not exist for table '$table_name'."
        exit 1
    fi

    column_order=()
    while IFS=: read -r col_name _; do
        column_order+=("$col_name")
    done < "$metadata_file"

while true; do
    echo "Select an option:"
    echo "1. Select by row (primary key)"
    echo "2. Select by column"
    echo "3. Select all"
    echo "4. Return to tables menu"  
    read -r -p "Enter your choice: " choice

        case $choice in
            1)
                echo -n 'Enter the primary key for the record you want to display: '
                read -r pk
                row=$(awk -F ':' -v pk="$pk" '$1 == pk {print}' "$data_file")

                if [ -z "$row" ]; then
                    echo "Primary key '$pk' not found in table '$table_name'. Please try again."
                else
                    clear
                    echo "The record(s) with primary key '$pk' is/are:"
                    echo "$row"
                fi
                break
                ;;

            2)
                echo "Enter the column name (${column_order[*]}):"
                read -r column_name

                column_number=$(grep -n "^$column_name:" "$metadata_file" | cut -d: -f1)
                if [ -z "$column_number" ]; then
                    echo "Invalid column name '$column_name'. Please enter a valid name."
                else
                    column_number=$((column_number))
                    clear
                    echo "Displaying data from column '$column_name':"
                    awk -F ':' -v col="$column_number" '{print $col}' "$data_file"
                fi
                break
                ;;

            3)
                clear
                echo -e "\nAll data in table '$table_name':"
                if [ -s "$data_file" ]; then
                    cat "$data_file" | column -t -s ":"
                else
                    clear
                    echo "No data available in table '$table_name'."
                fi
                break
                ;;

            4)
            clear
            . ./tables_menu.sh
            exit 0
            ;;

        *)
            echo "Invalid choice '$choice'. Please enter '1', '2', '3', or '4'."
            ;;
        esac
    done

    echo "Press any key to go to the tables menu..."
    read -n 1 -s
    clear
    . ./tables_menu.sh
    exit 0
}
select_from_table
