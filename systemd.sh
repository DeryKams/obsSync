SYSTEMD_CFG="
#[Unit] - секция для описания и зависимостей
#Description - человекочитаемое описание сервиса
#After=network.target - запускать после загрузки сети
#network.target - системная точка, которая достигается после запуска сети
#Documentations
[Unit]
Description= Скрипт для синхронизации Obsidian с внешним хранилищем. Настраевтся посредством rclon
After=network.target
Documentation=https://github.com/DeryKams/obsSync

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

[Service]
Type=simple
ExecStart=$SCRIPT_PATH
Restart=always
RestartSec=10

#Ограничения по безопасности

#Запрещаем процессу повышать привелегии
NoNewPrivileges=yes
#Защита системных файлов - доступны только для чтения. Запрещена запись в системные директории
ProtectSystem=strict
#Домашняя директория доступна только для чтения
ProtectHome=read-only
# Исключения для записи и чтения
ReadWritePaths=%h/obsidian /tmp

#Ограничения по памяти и процессору
MemoryLimit=500M
CPUQuota=10%

[Install]
WantedBy=default.target
"

# Проверяем существует ли такая директория для systemd сервисов пользователя
if [ -d ~/.config/systemd/$USER ]; then
    echo "User systemd directory exists"
else
    mkdir ~/.config/systemd/$USER
    echo "User systemd directory was created"
fi

# Проверяем, созад ли user systemd service для синхронизации Obsidian

if [ -f ~/.config/systemd/$USER/obsSync.service ]; then

echo "Synchronization service exists in user systemd"

else 

echo " Creating synchronization service in user systemd..."

cat > ~/.config/systemd/$USER/obsSync.service << "$SYSTEMD_CFG"

fi