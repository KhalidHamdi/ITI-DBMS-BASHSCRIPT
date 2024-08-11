#!/bin/bash

main_menu() {
    while true; do
        echo "Main Menu"
        echo "1. Create Database"
        echo "2. List Databases"
        echo "3. Connect To Database"
        echo "4. Drop Database"
        echo "5. Exit"

        read -r -p "Please select an option: " menu_option

        case $menu_option in
            1) clear ; . ./create_db.sh ;;
            2) clear ; . ./list_dbs.sh  ;;
            3) clear ; . ./connect_to_database.sh  ;;
            4) clear ; . ./drop_db.sh ;;
            5) echo "Exiting..."; exit ;;
            *) echo "Invalid option. Please select a valid option." ;;
        esac
    done
}

main_menu
