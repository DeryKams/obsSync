if pacman -Qi rclone >/dev/null 2>&1; then
    
    echo "rclone Installed"
    CONF_PATH="$(rclone config file | tail -n 1)"
    
    if [ -n $CONF_PATH ]; then
        echo "Path to config rclone: $CONF_PATH"
    else
        echo "config is empty $CONF_PATH"
    fi
else
    echo "rclone dont istalled"
    
    exit 1
fi