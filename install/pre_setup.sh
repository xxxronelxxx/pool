#!/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
# Source https://mailinabox.email/     https://github.com/mail-in-a-box/mailinabox   #
# Updated by Afiniel for yiimpool use...                                         #
##################################################################################

source /etc/functions.sh
clear
echo -e "$YELLOW => Setting our global variables <= ${NC}"

# === ЖЁСТКО ЗАДАЁМ ВНЕШНИЙ IP (ваш публичный адрес) ===
# Это обходит всю логику автоопределения и предотвращает ошибки.
PUBLIC_IP="109.202.50.104"

# === ПОЛНОСТЬЮ ОТКЛЮЧАЕМ IPv6 ===
PUBLIC_IPV6=""

# Экспортируем для других скриптов
export PUBLIC_IP
export PUBLIC_IPV6

# Ниже — сохранение логики "auto" на случай, если другие части системы её используют.
# Но мы переопределяем значения, чтобы они не вызывали сетевые запросы.

if [ "${PUBLIC_IP:-}" = "auto" ]; then
	PUBLIC_IP="109.202.50.104"
fi

if [ "${PUBLIC_IPV6:-}" = "auto" ]; then
	PUBLIC_IPV6=""
fi

# Информируем пользователя
echo "✅ PUBLIC_IP set to: $PUBLIC_IP"
echo "🚫 PUBLIC_IPV6 disabled"
