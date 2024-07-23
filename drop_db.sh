#!/bin/bash

drop_database() {
    db_path="./databases"

    while true; do
        read -p "Enter the name of the database to drop (or type 'exit' to quit): " db_name
        if [ "$db_name" = "exit" ]; then
            echo "Exiting the database dropping process. No changes have been made."
            echo "Press any key to go to the main menu..."
            read -n 1 -s
            clear
            break
        fi

        if [ -z "$db_name" ]; then
            echo "Database name cannot be empty. Please enter a valid database name."
            continue
        fi

        if [ -d "$db_path/$db_name" ]; then
            read -p "Are you sure you want to drop the database '$db_name'? This action cannot be undone.(y/n): " confirmation
            case "$confirmation" in
                [Yy]* )
                    rm -r "$db_path/$db_name"
                    if [ $? -eq 0 ]; then
                        echo "Database '$db_name' dropped successfully."
                    else
                        echo "Failed to drop database '$db_name'. Please check permissions or try again."
                    fi
                    ;;
                [Nn]* )
                    echo "Database '$db_name' was not dropped."
                    ;;
                * )
                    echo "Please answer yes (y) or no (n)."
                    ;;
            esac
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
