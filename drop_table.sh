#!/bin/bash

drop_table() {
    db_path="./databases"

    if [[ -z "$CURRENT_DB" ]]; then
        echo "No database is currently selected. Please connect to a database first."
        exit 1
    fi

    while true; do
        read -r -p "Enter the name of the table to drop (or type 'exit' to cancel): " table_name
        if [[ "$table_name" == "exit" ]]; then
            clear
            echo "Operation canceled."
            . ./tables_menu.sh
            return
        elif [[ -z "$table_name" ]]; then
            echo "Table name cannot be null. Please try again or type 'exit' to cancel."
        elif [[ ! "$table_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            echo "Invalid table name. Table names should start with a letter and contain only letters, numbers, and underscores."
        else
            table_path="$CURRENT_DB/$table_name"
            if [[ ! -d "$table_path" ]]; then
                echo "Table '$table_name' does not exist. Please try again with a valid table name or type 'exit' to cancel."
            else
                echo "Table '$table_name' found."   
                break
            fi
        fi
    done

    while true; do
        read -r -p "Are you sure you want to drop the table '$table_name'? This action cannot be undone. (y/n): " confirm
        case "$confirm" in
            [Yy]*)
                rm -rf "$table_path"
                if [[ ! -d "$table_path" ]]; then
                    echo "Table '$table_name' dropped successfully."
                else
                    echo "Failed to drop the table '$table_name'."
                fi
                break
                ;;
            [Nn]*)
                echo "Operation canceled."
                break
                ;;
            *)
                echo "Invalid input. Please answer yes (y) or no (n)."
                ;;
        esac
    done

    echo "Press any key to go to the tables menu..."
    read -n 1 -s 
    clear
    . ./tables_menu.sh
}

drop_table
