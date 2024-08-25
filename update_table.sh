#!/bin/bash

update_table() {
    while true; do
        read -r -p "Enter table name (or type 'exit' to cancel): " table_name
        if [[ "$table_name" == "exit" ]]; then
            clear
            echo "Operation canceled."
            . ./tables_menu.sh
            return
        fi

        table_path="$CURRENT_DB/$table_name"
        data_path="$table_path/data.txt"
        metadata_path="$table_path/metadata.txt"

        if [[ ! -d "$table_path" ]]; then
            echo "Table '$table_name' does not exist in database '$CURRENT_DB'. Please try again or type 'exit' to cancel."
        else
            break
        fi
    done

    if [[ ! -f "$metadata_path" ]]; then
        echo "Metadata file does not exist for table '$table_name'."
        exit 1
    fi

    # Check if the table has data
    if [[ ! -s "$data_path" ]]; then
        echo "Table '$table_name' is empty. No rows to update."
        echo "Press any key to go back to the tables menu..."
        read -n 1 -s
        clear
        . ./tables_menu.sh
        return
    fi

    while true; do
        read -r -p "Enter the primary key value of the row you want to update (or type 'exit' to cancel): " pk
        if [[ "$pk" == "exit" ]]; then
            clear
            echo "Operation canceled."
            . ./tables_menu.sh
            return
        fi

        row=$(awk -F ':' -v pk="$pk" '$1 == pk {print}' "$data_path")

        if [ -z "$row" ]; then
            echo "The primary key $pk does not exist. Please try again or type 'exit' to quit."
            continue
        fi

        IFS=':' read -r -a fields <<< "$row"

        declare -A column_types
        column_order=()
        while IFS=: read -r col_name col_type _; do
            column_types["$col_name"]="$col_type"
            column_order+=("$col_name")
        done < "$metadata_path"

        for (( i=0; i<${#column_order[@]}; i++ )); do
            col_name="${column_order[$i]}"
            col_type="${column_types[$col_name]}"
            current_val="${fields[$i]}"

            while true; do
                read -r -p "Set value for column '$col_name' (current: $current_val, enter to keep): " new_val

                if [ -z "$new_val" ]; then
                    new_val="$current_val"
                    break
                fi

                if [[ "$col_name" == "${column_order[0]}" ]]; then
                    if [[ "$new_val" != "$current_val" ]]; then
                        is_duplicate=false
                        if [[ -s "$data_path" ]]; then
                            while IFS= read -r line; do
                                pk_value=$(echo "$line" | cut -d':' -f1)
                                if [[ "$new_val" == "$pk_value" ]]; then
                                    echo "Duplicate entry for primary key $col_name. Please enter a new value."
                                    is_duplicate=true
                                    break
                                fi
                            done < "$data_path"
                        fi

                        if $is_duplicate; then
                            continue
                        fi
                    fi
                fi

                case "$col_type" in
                    integer)
                        if [[ "$new_val" =~ ^[0-9]+$ ]]; then
                            break
                        else
                            echo "Invalid value. Enter an integer."
                        fi
                        ;;
                    string)
                        if [[ "$new_val" =~ ^[a-zA-Z]+$ ]]; then
                            break
                        else
                            echo "Invalid value. Enter a string."
                        fi
                        ;;
                    *)
                        echo "Unexpected column type '$col_type'."
                        ;;
                esac
            done

            fields[$i]="$new_val"
        done

        updated_row=$(IFS=:; echo "${fields[*]}")

        temp_file=$(mktemp)
        awk -F ':' -v pk="$pk" '$1 != pk' "$data_path" > "$temp_file"
        echo "$updated_row" >> "$temp_file"
        mv "$temp_file" "$data_path"

        clear
        echo "Row updated successfully."
        echo "Updated data in $table_name:"
        awk -F ':' -v pk="${fields[0]}" '$1 == pk {print}' "$data_path"
        echo "Press any key to go to the tables menu..."
        read -n 1 -s
        clear
        . ./tables_menu.sh
        return
    done
}

update_table
