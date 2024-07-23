#!/bin/bash

list_databases() {
    db_path="databases"
    
    while true; 
    do
        if [ -d "$db_path" ]; then
            dbs=$(ls -F "$db_path" | grep '/$')
            if [ -z "$dbs" ]; then
                echo "No databases found."
            else
                echo "Listing databases:"
                echo "$dbs"
            fi
        else
            echo "Database directory does not exist."
        fi

        echo "Press any key to go to the main menu..."
        read -n 1 -s 
        clear
        . ./mainMenu.sh
        return  
    done
}

list_databases
