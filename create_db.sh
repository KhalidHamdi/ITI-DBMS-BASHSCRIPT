#!/bin/bash

create_database() {
    db_path="./databases"
    while true; 
    do
        read -p "Please enter database name (or type 'exit' to quit): " db_name
        if [[ "$db_name" == "exit" ]]; then
            echo "Exiting the database creation process."
            break
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
            break
        fi
    done
}
create_database