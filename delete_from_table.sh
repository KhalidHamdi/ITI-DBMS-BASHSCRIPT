#!/bin/bash

delete_from_table() {
    while true; do
        read -r -p 'Enter the table name (or type "exit" to cancel): ' table_name

        if [[ "$table_name" == *'\'* ]]; then
            echo "Backslashes are not allowed in table names. Please try again."
            continue
        fi

        if [[ "$table_name" == "exit" ]]; then
            clear
            echo "Operation canceled."
            read -n 1 -s -r -p "Press any key to go to the tables menu..."
            clear
            . ./tables_menu.sh
            return
        elif [[ -z "$table_name" ]]; then
            clear
            echo "You did not enter a table name. Please try again or type 'exit' to cancel."
            continue
        fi

        table_path="$CURRENT_DB/$table_name"
        data_path="$table_path/data.txt"
        metadata_path="$table_path/metadata.txt"

        if [[ -d "$table_path" ]]; then
            break
        else
            echo "Table '$table_name' does not exist. Please try again or type 'exit' to cancel."
        fi
    done

    if [[ ! -s "$data_path" ]]; then
        clear
        echo "The data file is empty. No records to delete."
        read -n 1 -s -r -p "Press any key to go back..."
        clear
        . ./tables_menu.sh
        return
    fi

    while true; do
        echo "Select delete option:"
        echo "1. Delete by primary key"
        echo "2. Delete by full column"
        echo "3. Return to tables menu"
        read -r -p "Enter your choice (1, 2, or 3): " option
        clear

        case $option in
            1)
                while true; do
                    read -r -p "Enter the primary key for the row you want to delete (or type 'exit' to cancel): " pk

                    if [[ "$pk" == "exit" ]]; then
                        clear
                        echo "Operation canceled."
                        read -n 1 -s -r -p "Press any key to go to the tables menu..."
                        clear
                        . ./tables_menu.sh
                        return
                    fi

                    if grep -q "^$pk:" "$data_path"; then
                        echo "Primary key '$pk' exists in data file."

                        pk_column_num=$(awk -F ':' '$3 == "y" {print NR; exit}' "$metadata_path")

                        if [ -z "$pk_column_num" ]; then
                            echo "Primary key column not found in metadata. Operation cannot proceed."
                            read -n 1 -s -r -p "Press any key to go back..."
                            clear
                            continue
                        fi

                        # Filter out the row with matching primary key
                        awk -v pk="$pk" -F ':' '$1 != pk' "$data_path" > temp.txt

                        # Ensure temp.txt exists before moving it
                        if [ -f temp.txt ]; then
                            mv temp.txt "$data_path"
                            clear
                            echo "Record with primary key '$pk' has been deleted."
                        else
                            echo "Error occurred during deletion."
                        fi

                        read -n 1 -s -r -p "Press any key to go back..."
                        clear
                        break
                    else
                        echo "Primary key '$pk' does not exist. Please try again."
                    fi
                done
                break
                ;;

            2)
                while true; do
                    read -r -p "Enter the column name (or type 'exit' to cancel): " column_name

                    if [[ "$column_name" == "exit" ]]; then
                        clear
                        echo "Operation canceled."
                        read -n 1 -s -r -p "Press any key to go to the tables menu..."
                        clear
                        . ./tables_menu.sh
                        return
                    fi

                    column_number=$(awk -F ':' -v col_name="$column_name" '$1 == col_name {print NR}' "$metadata_path")

                    if [ -n "$column_number" ]; then
                        break
                    else
                        echo "Invalid column name. Please try again or type 'exit' to cancel."
                    fi
                done

                pk_column_number=$(awk -F ':' '$3 == "y" {print NR}' "$metadata_path")

                if [ "$column_number" -eq "$pk_column_number" ]; then
                    read -r -p "Warning: The column you are about to delete is the primary key column. This will remove the primary key constraint and may affect data integrity. Are you sure you want to proceed? (y/n) " confirm
                    clear

                    if [ "$confirm" != "y" ]; then
                        clear
                        echo "Operation canceled."
                        read -n 1 -s -r -p "Press any key to go back..."
                        clear
                        continue
                    fi
                fi

                # Delete the column from the data file
                awk -F ':' -v col="$column_number" '{
                    for (i = 1; i <= NF; i++) {
                        if (i != col) {
                            if (i > 1) printf ":";
                            printf "%s", $i;
                        }
                    }
                    printf "\n";
                }' "$data_path" > temp_file

                if [ -f temp_file ]; then
                    mv temp_file "$data_path"
                else
                    echo "Error while processing column deletion."
                    read -n 1 -s -r -p "Press any key to go back..."
                    continue
                fi

                # Delete the column from the metadata file
                awk -F ':' -v col_name="$column_name" '$1 != col_name' "$metadata_path" > temp_file

                if [ -f temp_file ]; then
                    mv temp_file "$metadata_path"
                    clear
                    echo "Column '$column_name' has been deleted from both data and metadata files."
                else
                    echo "Error while processing metadata deletion."
                fi

                read -n 1 -s -r -p "Press any key to go back..."
                clear
                break
                ;;

            3)
                clear
                echo "Returning to tables menu..."
                . ./tables_menu.sh
                return
                ;;

            *)
                echo "Invalid choice. Please enter '1', '2', or '3'."
                ;;
        esac
    done
}

delete_from_table
