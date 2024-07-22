#!/bin/bash
elete_from_table(){
    table_loc="./databases"
    echo "Enter the table name please: "
    read table_name
    folder_path="$table_loc/$table_name/data.txt"
    
    if [ -f "$folder_path" ]; then
        echo "Do you want to delete a row (y/n): "
        read answer
        if [ "$answer" = "y" ]; then
            echo "Enter the primary key for the row you want to delete: "
            read pk
            awk -F ' ' -v pk="$pk" '$2 != pk {print $0}' "$folder_path" > temp.txt
            mv temp.txt "$folder_path"
            echo "Record with primary key '$pk' has been deleted."
        else
            echo "Do you want to display a full column (y/n): "
            read choice
            if [ "$choice" = "n" ]; then
                echo "Enter the column name: "
                read column_name
                case "$column_name" in
                    name) column_number=1;;
                    age) column_number=2;;
                    edu) column_number=3;;
                    *) echo "Invalid column name, please enter a valid name"; exit 1 ;;
                esac
                awk -v col="$column_number" '{print $col}' "$folder_path"
            else
                echo "The '$table_name' does not exist, please enter a valid table name."
            fi
        fi
    fi
}

delete_from_table