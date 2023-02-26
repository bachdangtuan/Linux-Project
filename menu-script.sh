#!/bin/bash

# Variable Array Menu list level 1
menu=("Cat Dat Dich Vu" "Check He Thong" "Thoát")

# Variable Array Menu list level 2
menuService=("Prometheus/Grafana" "Rancher" "Zabbix" "Thoát")

# ################################




# Function list menu level1
print_menu_level1 () {
for (( i=0; i<${#menu[@]}; i++ )); do
    echo "                             $((i+1)). ${menu[$i]}                          "
done
}


# Function list menu level2
print_menu_level2 () {
        for (( i=0; i<${#menuService[@]}; i++ )); do
        echo "                             $((i+1)). ${menuService[$i]}                          "
        done
        
        read -p "Vui lòng chọn một lựa chọn dịch vụ montor [1-3]: " choice
        case $choice in
    1)
        echo "Cài đặt ${menuService[0]} "
        ;;
    2)
        echo "Cài đặt ${menuService[1]} "
        ;;
    3)
        echo "Cài đặt ${menuService[2]} "
        ;;

    4)
        echo "Cài đặt ${menuService[3]} "
        ;;    
    *)
        echo "Lựa chọn không hợp lệ. Vui lòng chọn lại."
        ;;
esac      
}










# Giao diện hiển thị


echo "#################################################################################"
echo "####                          Chương trình tự động LINUX                     ####"
echo "####                     Distribution Linux: Ubuntu/RHEL/CentOS              ####"
echo "####                                   ********                              ####"
echo "####                               CREATE BY DangTuan                        ####"
echo "####                                   version 1.0                           ####"
echo "--------------------------------------------------------------------------------"


print_menu_level1


echo "--------------------------------------------------------------------------------"
echo "##                                                                            ##"
echo "#####                                                                     ######"
echo "################################################################################"
echo "################################################################################"
read -p "Vui lòng chọn một lựa chọn [1-3]: " choice

case $choice in
    1)
        print_menu_level2
        ;;
    2)
        date
        ;;
    3)
        exit
        ;;
    *)
        echo "Lựa chọn không hợp lệ. Vui lòng chọn lại."
        ;;
esac



