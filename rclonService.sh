
if [ -n "pacman -Qi rclone" ]; then 
echo "rclone установлен"
else 
echo "rclone не установлен"

exit 1
fi