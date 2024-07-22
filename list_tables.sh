#!/bin/bash

list_tables() {
    if [[ -z "$CURRENT_DB" ]]; then
        echo "No database is currently selected. Please connect to a database first."
        return
    fi

    if [[ -d "$CURRENT_DB" ]]; then
        tables=$(ls "$CURRENT_DB" 2>/dev/null)

        if [[ -z "$tables" ]]; then
            echo "No tables found in database '$DB_NAME'."
        else
            echo "Tables found in database '$DB_NAME': 
$tables"
        fi
    else
        echo "Database directory '$CURRENT_DB' does not exist."
    fi
    echo "Press any key to go to the tables menu..."
    read -n 1 -s 
    clear
    . ./tables_menu.sh
}

list_tables

