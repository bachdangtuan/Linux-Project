#!/bin/bash

echo "Luu y chi duoc nhap so khong duoc nhap cai j khac"
# read -t 5 -p "Enter your name in 5 seconds: " num

echo "Enter a number:"
read num
if [[ $num =~ ^[0-9]+$ ]]
then
    echo "The input is a number"
else
    echo "The input is not a number"
fi


echo "Hello, $num!"