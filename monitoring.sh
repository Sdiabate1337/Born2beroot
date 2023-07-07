#!/bin/bash
    # Informations système
    os_architecture=$(uname -m)
    kernel_version=$(uname -r)
    physical_processors=$(grep 'physical id' /proc/cpuinfo | sort -u | wc -l)
    virtual_processors=$(grep '^processor' /proc/cpuinfo | wc -l)

    memory_total=$(free -h | awk '/^Mem:/ {print $2}')
    memory_used=$(free -h | awk '/^Mem:/ {print $3}')
    memory_percentage=$(free | awk '/^Mem:/ {printf "%.2f", $3/$2 * 100}')
    memory_available=$(free -h | awk '/^Mem:/ {print $7}')

    disk_total=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
    disk_used=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
    pdisk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft+= $2} END {printf("%d"), ut/ft*100}')

    cpu_usage=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')

    last_reboot=$(uptime -s)
    lvm_status=$(sudo lvs >/dev/null 2>&1 && echo "Active" || echo "Inactive")
    active_connections=$(sudo ss -a | grep -c ESTAB)
    active_users=$(who | cut -d " " -f 1 | sort -u | wc -l)
    ipv4_address=$(hostname -I | awk '{print $1}')
    mac_address=$(ip link show | awk '/ether/ {print $2}')
    sudo_commands=$(sudo grep -c 'COMMAND=' /var/log/sudo/sudo.log)

    # Construire le message avec les informations récupérées
    message="
            Architecture: $os_architecture\n
            Kernel version: $kernel_version\n
            Physical processors: $physical_processors\n
            Virtual processors: $virtual_processors\n
            Memory usage: $memory_used/$memory_total  ($memory_percentage%)\n
            Memory available: $memory_available \n
            CPU usage: $cpu_usage%\n
            Disk Usage: $disk_used/${disk_total}Gb ($pdisk%)
            Last reboot: $last_reboot\n
            LVM status: $lvm_status\n
            Active connections: $active_connections\n
            Active users: $active_users\n
            IPv4 address: $ipv4_address\n
            MAC address: $mac_address\n
            Sudo commands executed: $sudo_commands"

    # Afficher le message sur tous les terminaux avec wall
    echo -e "$message" | wall >/dev/null 2>&1


