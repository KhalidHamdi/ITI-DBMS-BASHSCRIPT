# #!/bin/bash
drop_database() {
    db_path="./databases"
        read -p "Enter the name of the database to drop (or type 'exit' to quit): " db_name
        if [ "$db_name" = "exit" ]; then
            echo "Operation canceled."
            break
        fi
        if [ -d "$db_path/$db_name" ]; then
            read -p "Are you sure you want to drop the database '$db_name'? (y/n): " confirmation
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
        else
            echo "Database '$db_name' does not exist. Please try again."
        fi
}
drop_database