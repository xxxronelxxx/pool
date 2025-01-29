#!/bin/bash
##################################################################
# Current Modified by Afiniel for Daemon coin & addport & stratum
##################################################################
source /etc/functions.sh
source /etc/yiimpool.conf
source /etc/yiimpoolversion.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf

path_stratum=$STORAGE_ROOT/yiimp/site/stratum
absolutepath=/home/crypto-data

installtoserver=daemon_builder
daemonname=daemonbuilder