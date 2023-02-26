#!/bin/bash

# Variable Array Menu list level 1

# shellcheck disable=SC2207
# shellcheck disable=SC2068

menu=("${arrayMenu[@]}")

# Print the imported array


# Variable Array Menu list level 2
menuService=("Prometheus" "Prometheus Exporter" "Grafana" "Zabbix" "Zabbix Agent" "Thoát")

# ################################

# Function list menu level1
print_menu_level1() {
  for ((i = 0; i < ${#menu[@]}; i++)); do
    echo "                             $((i + 1)). ${menu[$i]}                          "
  done
}

# Function list menu level2
print_menu_level2() {
  for ((i = 0; i < ${#menuService[@]}; i++)); do
    echo "                             $((i + 1)). ${menuService[$i]}                          "
  done

  read -p "Vui lòng chọn một lựa chọn dịch vụ montor: " choice
  case $choice in
  1)
    echo "Cài đặt ${menuService[0]} "
    source ./setup/prometheus-grafana/install-prometheus.sh

    ;;
  2)
    echo "Cài đặt ${menuService[1]} "
    source ./setup/prometheus-grafana/install-prometheus-exporter.sh
    ;;
  3)
    echo "Cài đặt ${menuService[2]} "
    source ./setup/zabbis/install-zabbix.sh
    ;;

  4)
    echo "Cài đặt ${menuService[3]} "
    ;;

  5)
    echo "Cài đặt ${menuService[4]} "
    ;;

  6)
    echo "Thank you, See again !"
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
read -p "Vui lòng chọn một lựa chọn [1-4]: " choice

case $choice in
1)
  print_menu_level2
  ;;
2)
  echo "Hệ thống cài đặt máy chủ mới bắt đầu......."
  source ./setup/setup-new-server/setup-new-server.sh
  ;;
3)
  echo "Chương trình hệ thống......."
  ;;
4)
  exit
  ;;
*)
  echo "Lựa chọn không hợp lệ. Vui lòng chọn lại."
  ;;
esac
