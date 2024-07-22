#!/bin/bash

tables_menu() {
    echo "Database '$db_name' is connected.";
    while true; do
        echo "Tables Menu"
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert Into Table"
        echo "5. Back to Main Menu"
        echo "6. Delete From Table"
        
        read -p "Please select an option: " db_menu_option

        case $db_menu_option in
            1)clear; . ./create_table.sh ;;
            2)clear; . ./list_tables.sh ;;  
            3)clear; . ./drop_table.sh ;;
            4)clear; . ./insert_into_table.sh ;;
            5)clear; . ./mainMenu.sh ;;
            6)clear; . ./delete_from_table.sh ;;
            *) echo "Invalid option. Please select a valid option." ;;
        esac
    done
}

tables_menu
