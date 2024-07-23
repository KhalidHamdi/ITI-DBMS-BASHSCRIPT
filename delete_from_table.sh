#!/bin/bash
#!/bin/bash
delete_from_table() {
    while true; do
        echo -n 'Enter table name (or type "exit" to cancel): '
        read table_name

        if [[ "$table_name" == "exit" ]]; then
            clear
            echo "Operation canceled."
            read -n 1 -s -r -p "Press any key to go to the tables menu..."
            clear
            . ./tables_menu.sh
            exit 0
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

    while true; do
        echo -n "Do you want to delete by primary key (y/n): "
        read -n 1 -s -r answer
        clear

        if [ "$answer" = "y" ]; then
            while true; do
                echo -n "Enter the primary key for the row you want to delete (or type 'exit' to cancel): "
                read pk

                if [[ "$pk" == "exit" ]]; then
                    clear
                    echo "Operation canceled."
                    read -n 1 -s -r -p "Press any key to go to the tables menu..."
                    clear
                    . ./tables_menu.sh
                    exit 0
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

                    awk -v pk="$pk" -v pk_col="$pk_column_num" -F ':' '$pk_col != pk' "$data_path" > temp.txt
                    mv temp.txt "$data_path"
                    clear
                    echo "Record with primary key '$pk' has been deleted."
                    read -n 1 -s -r -p "Press any key to go back..."
                    clear
                    break
                else
                    echo "Primary key '$pk' does not exist. Please try again."
                fi
            done
            break
        elif [ "$answer" = "n" ]; then
            while true; do
                echo -n "Do you want to delete a full column (y/n): "
                read -n 1 -s -r choice
                clear

                if [ "$choice" = "y" ]; then
                    while true; do
                        echo -n "Enter the column name (or type 'exit' to cancel): "
                        read column_name

                        if [[ "$column_name" == "exit" ]]; then
                            clear
                            echo "Operation canceled."
                            read -n 1 -s -r -p "Press any key to go to the tables menu..."
                            clear
                            . ./tables_menu.sh
                            exit 0
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
                        echo "Warning: The column you are about to delete is the primary key column. This will remove the primary key constraint and may affect data integrity. Are you sure you want to proceed? (y/n)"
                        read -n 1 -s -r confirm
                        clear

                        if [ "$confirm" != "y" ]; then
                            clear
                            echo "Operation canceled."
                            read -n 1 -s -r -p "Press any key to go back..."
                            clear
                            continue
                        fi
                    fi

                    awk -F ':' -v col="$column_number" '{ for (i = 1; i <= NF; i++) if (i != col) printf "%s%s", $i, (i < NF && i != col - 1) ? ":" : "\n" }' "$data_path" > temp_file
                    mv temp_file "$data_path"
                    clear
                    echo "Column '$column_name' has been deleted."
                    read -n 1 -s -r -p "Press any key to go back..."
                    clear
                    break

                elif [ "$choice" = "n" ]; then
                    clear
                    echo "Operation canceled."
                    read -n 1 -s -r -p "Press any key to go to the tables menu..."
                    clear
                    . ./tables_menu.sh
                    exit 0
                else
                    echo "Invalid input. Please enter 'y' or 'n'."
                fi
            done
            break
        else
            echo "Invalid input. Please enter 'y' or 'n'."
        fi
    done
}
delete_from_table
