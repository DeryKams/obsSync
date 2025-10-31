#!/bin/bash

CycleChecking=2

# -ge - greater or equal, то есть больше или равно
while [ $CycleChecking -ge 0 ]; do
    
    if pacman -Qi rclone >/dev/null 2>&1; then
        
        echo "rclone Installed"
        CONF_PATH="$(rclone config file | tail -n 1)"
        
        # -n - non empty - то есть если строка не пустая
        if [ -n "$CONF_PATH" ]; then
            echo "Path to config rclone: $CONF_PATH"
        else
            echo "config is empty $CONF_PATH"
        fi
        
    else
        
        echo "rclone dont istalled"
        echo "installing rclone"
        
        sudo pacman -Syu rclone
        
    fi
    
    #$(()) - арифметическая подстановка в bash
    CycleChecking=$((CycleChecking - 1))
    
done