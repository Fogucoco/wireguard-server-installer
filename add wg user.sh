#!/bin/sh

# root check
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root " 
    exit 1
fi

