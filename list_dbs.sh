#!/bin/bash

list_databases() {
    db_path="databases"
    
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
}
list_databases