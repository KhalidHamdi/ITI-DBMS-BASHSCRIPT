#!/bin/bash

create_database() {
    db_path="./databases"
    while true; 
    do
        read -r -p "Please enter database name (or type 'exit' to quit): " db_name
        if [[ "$db_name" == "exit" ]]; then
            echo "Exiting the database creation process."
            echo "Press any key to go to the main menu..."
            read -n 1 -s 
            clear
            . ./mainMenu.sh        
            return
        fi

        if [[ -z "$db_name" ]]; then
            echo "Database name cannot be empty. Please try again with a valid name."
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

        if [ -d "$db_path/$db_name" ]; then
            echo "Database '$db_name' already exists."
            continue
        else 
            mkdir -p "$db_path/$db_name"
            echo "Successfully created database: '$db_name'."
            export DB_NAME="$db_name"
            break
        fi
    done
    echo "Press any key to go to the main menu..."
    read -n 1 -s 
    clear
    . ./mainMenu.sh
}
create_database