#!/usr/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use
#
# This script performs system health checks for Yiimpool
#
# Author: Afiniel
# Date: 2024-07-15
#####################################################

source /etc/functions.sh
source /etc/yiimpool.conf
source /etc/yiimpoolversion.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

check_service() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        echo -e "${GREEN}[✓] $service is running${NC}"
    else
        echo -e "${RED}[✗] $service is not running${NC}"
    fi
}

check_disk_space() {
    print_header "Disk Space Usage"
    
    df -h / | awk 'NR==1 {print $0}; NR==2 {
        used=$5;
        sub(/%/,"",used);
        if (used > 90) 
            printf "'${RED}'%s'${NC}'\n", $0;
        else if (used > 75)
            printf "'${YELLOW}'%s'${NC}'\n", $0;
        else
            printf "'${GREEN}'%s'${NC}'\n", $0;
    }'
}

check_memory() {
    print_header "Memory Usage"
    
    total=$(free -m | awk 'NR==2 {printf "%.1f", $2/1024}')
    used=$(free -m | awk 'NR==2 {printf "%.1f", $3/1024}')
    free=$(free -m | awk 'NR==2 {printf "%.1f", $4/1024}')
    buffers=$(free -m | awk 'NR==2 {printf "%.1f", $6/1024}')
    available=$(free -m | awk 'NR==2 {printf "%.1f", $7/1024}')
    
    used_percent=$(free | awk 'NR==2 {printf "%.1f", $3/$2*100}')
    
    if (( $(echo "$used_percent > 90" | bc -l) )); then
        color=$RED
    elif (( $(echo "$used_percent > 75" | bc -l) )); then
        color=$YELLOW
    else
        color=$GREEN
    fi
    
    echo -e "Total Memory: ${total}G"
    echo -e "Used Memory: ${color}${used}G (${used_percent}%)${NC}"
    echo -e "Free Memory: ${GREEN}${free}G${NC}"
    echo -e "Buffers/Cache: ${buffers}G"
    echo -e "Available Memory: ${GREEN}${available}G${NC}"
}

check_cpu() {
    print_header "CPU Usage"
    
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d. -f1)
    cpu_usage=$((100 - cpu_idle))
    
    if [ $cpu_usage -gt 90 ]; then
        echo -e "${RED}CPU Usage: ${cpu_usage}%${NC}"
    elif [ $cpu_usage -gt 75 ]; then
        echo -e "${YELLOW}CPU Usage: ${cpu_usage}%${NC}"
    else
        echo -e "${GREEN}CPU Usage: ${cpu_usage}%${NC}"
    fi
    
    echo -e "\n${YELLOW}Top 5 CPU consuming processes:${NC}"
    ps aux --sort=-%cpu | head -6
}

check_critical_services() {
    print_header "Critical Services Status"
    
    check_service "nginx"
    check_service "mysql"
    check_service "php8.1-fpm"
}

check_database() {
    print_header "Database Status"
    
    if mysqladmin ping >/dev/null 2>&1; then
        echo -e "${GREEN}[✓] MySQL is responding${NC}"
        
        echo -e "\nDatabase Sizes:"
        mysql -N -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.tables GROUP BY table_schema;" 2>/dev/null | \
        while read db size; do
            if (( $(echo "$size > 1000" | bc -l) )); then
                echo -e "${RED}$db: $size MB${NC}"
            elif (( $(echo "$size > 500" | bc -l) )); then
                echo -e "${YELLOW}$db: $size MB${NC}"
            else
                echo -e "${GREEN}$db: $size MB${NC}"
            fi
        done
    else
        echo -e "${RED}[✗] MySQL is not responding${NC}"
    fi
}

check_ssl() {
    print_header "SSL Certificate Status"
    
    if [ -f "$STORAGE_ROOT/ssl/ssl_certificate.pem" ]; then
        CERT_FILE="$STORAGE_ROOT/ssl/ssl_certificate.pem"
    elif [ -f "/etc/letsencrypt/live/$DomainName/ssl_certificate.pem" ]; then
        CERT_FILE="/etc/letsencrypt/live/$DomainName/ssl_certificate.pem"
    else
        echo -e "${RED}[✗] SSL Certificate not found in either location:${NC}"
        echo -e "     $STORAGE_ROOT/ssl/ssl_certificate.pem"
        echo -e "     /etc/letsencrypt/live/$DomainName/ssl_certificate.pem"
        return
    fi
    
    expiry=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
    expiry_date=$(date -d "$expiry" +%s)
    current_date=$(date +%s)
    days_left=$(( ($expiry_date - $current_date) / 86400 ))
    
    if [ $days_left -lt 7 ]; then
        echo -e "${RED}[!] SSL Certificate expires in $days_left days${NC}"
    elif [ $days_left -lt 30 ]; then
        echo -e "${YELLOW}[!] SSL Certificate expires in $days_left days${NC}"
    else
        echo -e "${GREEN}[✓] SSL Certificate valid for $days_left days${NC}"
    fi
}

main() {
    echo -e "${YELLOW}Starting YiimPool Health Check...${NC}"
    echo -e "${YELLOW}Version: $VERSION${NC}"
    echo -e "${YELLOW}Date: $(date)${NC}"
    echo -e "${YELLOW}Hostname: $(hostname)${NC}"
    
    check_disk_space
    check_memory
    check_cpu
    check_critical_services
    check_database
    check_ssl
    
    print_header "Health Check Complete"
    echo -e "${YELLOW}Please review any warnings or errors above.${NC}"
}

main 