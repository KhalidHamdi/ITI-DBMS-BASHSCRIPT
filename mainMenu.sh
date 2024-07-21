#!/bin/bash

main_menu() {
    while true; do
        echo "Main Menu"
        echo "1. Create Database"
        echo "2. List Databases"
        echo "3. Connect To Database"
        echo "4. Drop Database"
        echo "5. Exit"

        read -p "Please select an option: " menu_option

        case $menu_option in
            1) source create_db.sh ;;
            2) source list_dbs.sh ;;
            3) source connect_to_database.sh ;;
            4) source drop_db.sh ;;
            5) echo "Exiting..."; break ;;
            *) echo "Invalid option. Please select a valid option." ;;
        esac
    done
}

main_menu