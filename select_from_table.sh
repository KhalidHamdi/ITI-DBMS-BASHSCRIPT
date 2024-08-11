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
            return
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
        echo "Please check the table name and try again."
        echo "Press any key to go back to the tables menu..."
        read -n 1 -s
        clear
        . ./tables_menu.sh
        return
    fi

    column_order=()
    while IFS=: read -r col_name _; do
        column_order+=("$col_name")
    done < "$metadata_file"

    while true; do
        echo "Select an option:"
        echo "1. Select by primary key"
        echo "2. Select by column"
        echo "3. Select all"
        read -r -p "Enter your choice: " choice

        case $choice in
            1)
                echo 'Enter the primary key for the record you want to display:'
                read -r -p pk

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
                read -r -p column_name

                column_index=$(awk -F ':' -v col="$column_name" '$1 == col {print NR}' "$metadata_file")
                if [[ -z "$column_index" ]]; then
                    echo "Invalid column name '$column_name'. Please enter a valid name."
                else
                    clear
                    echo "Displaying data from column '$column_name':"
                    awk -F ':' -v col="$column_index" '{print $col}' "$data_file"
                fi
                break
                ;;

            3)
                clear
                echo -e "\nAll data in table '$table_name':"
                if [ -s "$data_file" ]; then
                    cat "$data_file" | column -t -s ":"
                else
                    echo "No data available in table '$table_name'."
                fi
                break
                ;;

            *)
                echo "Invalid choice '$choice'. Please enter '1', '2', or '3'."
                ;;
        esac
    done

    echo "Press any key to go to the tables menu..."
    read -n 1 -s
    clear
    . ./tables_menu.sh
}

select_from_table
