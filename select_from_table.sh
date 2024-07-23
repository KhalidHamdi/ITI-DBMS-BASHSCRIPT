#!/bin/bash


echo 'Enter the primary key for the record you want to display.'
echo -n 'The PK: '
read pk

row=$(awk -F ' ' -v pk="$pk" '$2 == pk {print $1,$ 2, $3}' input.txt)


flag=0
while [ $flag -eq 0 ];do
        if [ -z "$row" ];then
                echo "Primary key Not found"
        echo -n "please enter a valid primary key: "
                read pk
                row=$(awk -F ' ' -v pk="$pk" '$2 == pk {print $1, $2, $3}' input.txt)

        else
            flag=1

            echo "Do you want to select by column or by raw: "
            read select_type
            if [ "$select_type" = "raw" ]; then
                row=$(awk -F ' ' -v pk="$pk" '$2 == pk {print $1, $2, $3}' input.txt)
                echo "The Record(s) is: $row"

                

            else 
                echo "Do you want to display the full column(y/n): "
                read choice
                if [ "$choice" = "y" ]; then
                   echo "Enter the column name: "
                   read column_name
                   case "$column_name" in
                        name) column_number=1;;
                        age) column_number=2;;
                        edu) column_number=3;;
                        *) echo "Inavlid column name, please enter a valid name"
                   esac
                   awk -v col="$column_number" '{print $col}' input.txt

                else 
                     echo "Enter the column name: "
                   read column_name
                   case "$column_name" in
                        name) column_number=1;;
                        age) column_number=2;;
                        edu) column_number=3;;
                        *) echo "Inavlid column name, please enter a valid name"
                   esac
                   field=$(awk -F ' ' -v pk="$pk" -v col="$column_number" '$2 == pk {print $col}' input.txt)
                   echo "The field value is: $field"
                fi
             
            fi
        fi 
done

