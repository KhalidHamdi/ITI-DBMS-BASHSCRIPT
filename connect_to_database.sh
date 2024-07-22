#!/bin/bash

connect_to_database() {
    db_path="./databases"

    while true; do
        read -rp "Enter the name of the database you want to connect to (or type 'exit' to cancel):" db_name
        clear

        if [[ "$db_name" == "exit" ]]; then
            echo "Exiting the connect to database process."
            echo "Press any key to go to the main menu..."
            read -n 1 -s 
            clear
            . ./mainMenu.sh        
        fi

        if [[ -d $db_path/$db_name ]]; then
            export DB_NAME="$db_name"
            export CURRENT_DB="$db_path/$db_name"
            . ./tables_menu.sh
            return  
        else
            echo "Database does not exist. Please try again with a valid name."
            echo ""
        fi
    done
}

connect_to_database