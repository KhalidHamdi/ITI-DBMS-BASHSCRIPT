#!/bin/bash

connect_to_database() {
    db_path="./databases"
    while true; do
        read -r -p "Enter the name of the database you want to connect to (or type 'exit' to cancel): " db_name
        clear
        if [[ "$db_name" == "exit" ]]; then
            echo "Exiting the connect to database process."
            echo "Press any key to go to the main menu..."
            read -n 1 -s
            clear
            . ./mainMenu.sh
            return
        elif [[ -z "$db_name" ]]; then
            echo "Database name cannot be empty. Please try again or type 'exit' to cancel."
            continue
        fi

        if [[ ! "$db_name" =~ ^[a-zA-Z] ]]; then
            echo "Database name must start with a letter. Please try again with a valid name."
            continue
        fi

        if [[ ! "$db_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            echo "Database name contains invalid characters. Only letters, numbers, and underscores are allowed. Please try again with a valid name."
            continue
        fi

        if [[ -d "$db_path/$db_name" ]]; then
            export DB_NAME="$db_name"
            export CURRENT_DB="$db_path/$db_name"
            . ./tables_menu.sh
            return
        else
            echo "Database '$db_name' does not exist. Please try again with a valid name."
        fi
    done
}

connect_to_database