#!/bin/bash

#Идея скрипта - реагировать на изменения, но не дергать синхронизацию на каждое событие

#Директория обсидиан
OBS_DIR="/home/$USER/obsidian"
#удаленная папка из настроек rclone
REMOTE="obsidian:obsidian"
#время ожидания
WAIT=10
#Файл-флаг о первой синхронизации
STAMP="obsidian-bisync.init"


#Файл межпроцессороной блокировки. В один момент запускается один процесс
#Сам файл не важен и может быть пустым. Необходим какой либо вообще файл, в качестве якоря для flock на который он будет смотерть
#Это нужно для определения выполнения операции: идет она или не идет
#Имя файла и его путь неважен, но лучше его создавать в директории для временных файлов с очевидной пометкой и названием
LOCK="/tmp/obsidian-bisync.lock"


#Команда синхронизации папки. Ввиде массива, чтобы не использовать под процесс bash -c
CMD="rclone bisync \"$OBS_DIR\" \"$REMOTE\" --verbose --progress --conflict-resolve newer --max-delete=25 --exclude \".obsidian/cache/**\" --exclude \".trash/**\" --exclude \"$STAMP\""
# количество циклов для проверки
CycleChecking=1

#Проверка синхронизации
# -ge - greater or equal, то есть больше или равно
while [ $CycleChecking -ge 0 ]; do
    
    if pacman -Qi rclone >/dev/null 2>&1; then
        
        echo "rclone Installed"
        CONF_PATH="$(rclone config file | tail -n 1)"
        
        # -n - non empty - то есть если строка не пустая
        if [ -n "$CONF_PATH" ]; then
            echo "Path to config rclone: $CONF_PATH"
            # Прерываем цикл, если rclone существует и у него есть конфиг
            break

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


#Синхронизация файлов
if [ ! -f "$STAMP" ]; then
  # Первый запуск: инициализация bisync'а (создаёт базы сравнения)
    /usr/bin/flock -n "$LOCK" -c "$CMD --resync"

     # помечаем: инициализация выполнена
    touch "$STAMP"
else

echo "Запускаем подписку на событие"
#Пока событие на изменение не применяется скрипт висит
while true; do

    #Мы ловим наши события на изменения
    inotifywait -q -r -e modify,create,delete,move "$OBS_DIR" >/dev/null 2>&1

    echo "ожидаем $WAIT секунд дальнеших изменение"

    #Небольшая задержка в ожидании изменений, чтобы не дергать постоянно синхронизацию, пока я печатаю
    # sleep "$WAIT"


    while inotifywait -q -t "$WAIT" -r -e modify,create,delete,move "$OBS_DIR" >/dev/null 2>&1; do
        :
    done


    #flock - межпроцессорный замок, который гарантирует, что код не запуститься в нескольких экземплярах
    #К примеру cron на каждые 10 секунд и начинается новый, пока не запуститься старый
    # -n - non-blocking - скрипт не ждем, пока блокировка снимется, а просто выдает exit 0
    # без n - он будет ожидать пока блокировка сниметься
    # можно указать -w 24 - чтобы подождать 24 секунды

    #bash -c "" - запускает новый процесс bash - который выполнит строку как команду
    # -- стандарный разделитель, чтобы команда не трактовалась, как аргумент

    #     Синтаксис flock примерно такой:
    #     LOCK=/tmp/myjob.lock
    #     flock -n "$LOCK" -- /usr/local/bin/my-long-job

    if /usr/bin/flock -n "$LOCK" -c "$CMD"; then
        #Если лок поставился и команда выполнилась успехом
        echo "Синк завершен"
    else
        # Если лок уже есть и новый не был взят, то завершаем с ошибкой
        echo "Синк уже идет"
    fi

done

fi



