#$() - подстановка вывода команды
#${} - подстановка переменной
SCRIPT_PATH="$(readlink -f "$0")"
# Проверяем существует ли такая директория для systemd сервисов пользователя
if [ -d ~/.config/systemd/user ]; then
    echo "User systemd directory exists"
else
    mkdir -p ~/.config/systemd/user
    echo "User systemd directory was created"
fi

# Проверяем, создан ли user systemd service для синхронизации Obsidian

if [ -f ~/.config/systemd/user/obsSync.service ]; then

echo "Synchronization service exists in user systemd"

else

echo " Creating synchronization service in user systemd..."

cat > ~/.config/systemd/user/obsSync.service << EOF
[Unit]
Description= Скрипт для синхронизации Obsidian с внешним хранилищем. Настраивается посредством rclone.
After=network.target
Documentation=https://github.com/DeryKams/obsSync

[Service]
Type=simple
ExecStart=$SCRIPT_PATH
Restart=always
RestartSec=10

NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=%h/obsidian /tmp

MemoryLimit=100M
CPUQuota=10%

[Install]
WantedBy=default.target
EOF

#[Unit] - секция для описания и зависимостей
#Description - человекочитаемое описание сервиса
#After=network.target - запускать после загрузки сети
#network.target - системная точка, которая достигается после запуска сети
#Documentations


#[Service] - настройки выполнения
#type=simple - тип сервиса
# simple - основная команда запускается как главный процесс
# forking - для демонов, которые создают дочерние процессы
# oneshot - для скриптов которые один раз выполняются и завершаются
#ExecStart = - команда для запуска
# %h - автоматически заменяется на домашнюю директорию пользоватля (/home/user)
# можно использовать абсолютный путь
#Restart - политика запуска
# always - перезапускать всегда, независимо от вывода
# on-failure - перезапускать только при ошибках
# no - не перезапускать
# RestartSec = 10 - ждать перед запуском 10 секунд

#Ограничения по безопасности

#Запрещаем процессу повышать привелегии
# NoNewPrivileges=yes
#Защита системных файлов - доступны только для чтения. Запрещена запись в системные директории
# ProtectSystem=strict
#Домашняя директория доступна только для чтения
# ProtectHome=read-only
# Исключения для записи и чтения
# ReadWritePaths=%h/obsidian /tmp

#Ограничения по памяти и процессору
# MemoryLimit=500M
# CPUQuota=10%

fi


fi

# Проверяем загружена ли служба в systemd
if systemctl --user list-unit-files | grep -q obsSync.service; then
    echo "Service is loaded in systemd"
else

echo "The startup service needs to be started."
systemctl --user daemon-reload
systemctl --user enable --now obsSync.service
fi