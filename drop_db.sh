#!/bin/bash

drop_database() {
    db_path="./databases"

    while true; do
        read -r -p "Enter the name of the database to drop (or type 'exit' to quit): " db_name
        if [ "$db_name" = "exit" ]; then
            echo "Exiting the database dropping process. No changes have been made."
            break
        fi

        if [ -z "$db_name" ]; then
            echo "Database name cannot be empty. Please enter a valid database name."
            continue
        fi

        if [[ ! "$db_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            echo "Invalid database name. Only letters, numbers, and underscores are allowed, and it must start with a letter."
            continue
        fi

        if [ -d "$db_path/$db_name" ]; then
            while true; do
                read -r -p "Are you sure you want to drop the database '$db_name'? This action cannot be undone. (y/n): " confirmation
                case "$confirmation" in
                    [Yy]* )
                        rm -r "$db_path/$db_name"
                        if [ $? -eq 0 ]; then
                            echo "Database '$db_name' dropped successfully."
                        else
                            echo "Failed to drop database '$db_name'. Please check permissions or try again."
                        fi
                        break
                        ;;
                    [Nn]* )
                        echo "Database '$db_name' was not dropped."
                        break
                        ;;
                    * )
                        echo "Invalid input. Please answer yes (y) or no (n)."
                        ;;
                esac
            done
            echo "Press any key to go to the main menu..."
            read -n 1 -s
            clear
            . ./mainMenu.sh
            return
        else
            echo "Database '$db_name' does not exist. Please try again."
        fi
    done
}

drop_database
