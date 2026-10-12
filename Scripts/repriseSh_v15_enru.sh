Вот модифицированный скрипт с заменой `DB_CONNECTION` на отдельные параметры подключения:

```bash
#!/bin/bash

# Скрипт для поиска и выполнения команд перерасчета HYPO
# Основан на описании задачи по работе с SRM_Relaunch таблицей

# Конфигурация
SCRIPT_NAME=$(basename "$0")
DATE_PARAM="$1"  # Дата в формате, ожидаемом базой данных
TMP_REPRISE_FILE="/tmp/reprise_$$.cmd"
WORK_DIR="/slpafr32ba07/appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS/travaux"
ENV_SCRIPT="appSetEnv M32_PROD_HYPO"

# Параметры подключения к БД - замените на реальные значения
DB_LOGIN="your_username"
DB_PASS="your_password"
ORACLE_SID="your_sid"  # или ORACLE_SID="your_service_name"

# Альтернативный вариант: можно задать через переменные окружения
# DB_LOGIN=${DB_USER:-"default_user"}
# DB_PASS=${DB_PASSWORD:-"default_pass"}
# ORACLE_SID=${ORACLE_SID:-"default_sid"}

# Функция для выполнения SQL запросов
execute_sql() {
    local sql_query="$1"
    
    # Вариант 1: Использование sqlplus с полными параметрами
    echo "$sql_query" | sqlplus -s "${DB_LOGIN}/${DB_PASS}@${ORACLE_SID}"
    
    # Вариант 2: Если нужно установить ORACLE_SID через environment
    # ORACLE_SID="${ORACLE_SID}" sqlplus -s "${DB_LOGIN}/${DB_PASS}"
    
    # Вариант 3: Использование подключения через TNS-алиас
    # echo "$sql_query" | sqlplus -s "${DB_LOGIN}/${DB_PASS}@${TNS_ALIAS}"
}

# Функция для проверки подключения к БД
check_db_connection() {
    echo "Проверка подключения к базе данных..."
    if execute_sql "select 1 from dual;" > /dev/null 2>&1; then
        echo "  Подключение к БД успешно установлено"
        return 0
    else
        echo "  ОШИБКА: Не удалось подключиться к БД"
        return 1
    fi
}

# Проверка аргументов
if [ -z "$DATE_PARAM" ]; then
    echo "Ошибка: Не указана дата"
    echo "Использование: $SCRIPT_NAME <date>"
    echo "Пример: $SCRIPT_NAME 20260216"
    exit 1
fi

# Проверка подключения к БД перед началом работы
check_db_connection || exit 1

echo "=== Запуск скрипта перезапуска HYPO для даты: $DATE_PARAM ==="

# Шаг 1: Получение списка taskid из SRM_Relaunch
echo "Шаг 1: Получение списка taskid из SRM_Relaunch..."
TASK_IDS=$(execute_sql "
set pagesize 0
set feedback off
set heading off
select taskid from SRM_Relaunch 
where AsofDate = '$DATE_PARAM' 
and JobName = 'M32DRelaunchHypo';
")

if [ -z "$TASK_IDS" ]; then
    echo "Не найдено задач для перезапуска с датой $DATE_PARAM"
    exit 0
fi

echo "Найдены taskid:"
echo "$TASK_IDS" | sed 's/^/  /'

# Шаг 2: Получение списка filtername и effect для найденных taskid
echo "Шаг 2: Получение списка filtername и effect из SRM_task_CPNL..."
FILTER_EFFECT_PAIRS=$(execute_sql "
set pagesize 0
set feedback off
set colsep '|'
set heading off
select filtername, effect from SRM_task_CPNL 
where Active = 1 
and ID in (
    select tskid from SRM_Relaunch 
    where AsofDate = '$DATE_PARAM' 
    and JobName = 'M32DRelaunchHypo'
);
")

if [ -z "$FILTER_EFFECT_PAIRS" ]; then
    echo "Не найдено активных CPNL для указанных taskid"
    exit 0
fi

echo "Найдены пары filtername|effect:"
echo "$FILTER_EFFECT_PAIRS" | sed 's/^/  /'

# Шаг 3: Поиск команд в файлах travaux и формирование reprise.cmd
echo "Шаг 3: Поиск команд в директории $WORK_DIR..."

# Проверка существования рабочей директории
if [ ! -d "$WORK_DIR" ]; then
    echo "Ошибка: Директория $WORK_DIR не существует"
    exit 1
fi

# Очищаем временный файл
> "$TMP_REPRISE_FILE"

# Переходим в рабочую директорию
cd "$WORK_DIR" || {
    echo "Ошибка: Не удалось перейти в директорию $WORK_DIR"
    exit 1
}

# Обрабатываем каждую пару filter-effect
echo "$FILTER_EFFECT_PAIRS" | while IFS='|' read -r FILTER EFFECT; do
    # Убираем пробелы в начале и конце
    FILTER=$(echo "$FILTER" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    EFFECT=$(echo "$EFFECT" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    
    # Пропускаем пустые строки
    if [ -z "$FILTER" ] || [ -z "$EFFECT" ]; then
        continue
    fi
    
    echo "  Обработка: filter=$FILTER, effect=$EFFECT"
    
    # Пытаемся найти команду с --effect-name
    COMMAND_FILE=$(grep -l -r "hypo_compute_pnl.pl" . 2>/dev/null | \
                   xargs grep -l "--filter $FILTER" 2>/dev/null | \
                   xargs grep -l "--effect-name=$EFFECT" 2>/dev/null | \
                   head -1)
    
    # Если не нашли, пробуем найти с --copy-to
    if [ -z "$COMMAND_FILE" ]; then
        echo "    Не найдено с --effect-name, пробуем поиск с --copy-to $EFFECT..."
        COMMAND_FILE=$(grep -l -r "hypo_compute_pnl.pl" . 2>/dev/null | \
                       xargs grep -l "--filter $FILTER" 2>/dev/null | \
                       xargs grep -l "--copy-to.*$EFFECT" 2>/dev/null | \
                       head -1)
    fi
    
    # Если нашли файл с командой, извлекаем полную команду
    if [ -n "$COMMAND_FILE" ]; then
        echo "    Найден файл: $COMMAND_FILE"
        FULL_COMMAND=$(grep -h "hypo_compute_pnl.pl" "$COMMAND_FILE" | \
                      grep -- "--filter $FILTER" | \
                      head -1)
        
        if [ -n "$FULL_COMMAND" ]; then
            echo "    Найдена команда:"
            echo "    $FULL_COMMAND"
            
            # Модифицируем путь в логах - заменяем XFRDCalcPNLSpredTaux на M32DRelaunchHypo
            MODIFIED_COMMAND=$(echo "$FULL_COMMAND" | sed 's|XFRDCalcPNLSpredTaux|M32DRelaunchHypo|g')
            
            # Добавляем команду в файл перезапуска
            echo "$MODIFIED_COMMAND" >> "$TMP_REPRISE_FILE"
            echo "    Команда добавлена в $TMP_REPRISE_FILE"
        else
            echo "    Не удалось извлечь полную команду из файла $COMMAND_FILE"
        fi
    else
        echo "    Не найдена команда для filter=$FILTER и effect=$EFFECT"
    fi
done

# Шаг 4: Проверка, есть ли команды для выполнения
if [ ! -s "$TMP_REPRISE_FILE" ]; then
    echo "Не найдено команд для выполнения. Выход."
    rm -f "$TMP_REPRISE_FILE"
    exit 0
fi

echo "Шаг 4: Сформирован файл перезапуска: $TMP_REPRISE_FILE"
echo "Содержимое файла:"
cat "$TMP_REPRISE_FILE" | sed 's/^/  /'

# Шаг 5: Установка окружения и выполнение команд
echo "Шаг 5: Установка окружения и выполнение команд..."

# Устанавливаем окружение
echo "  Выполняем: $ENV_SCRIPT"
eval "$ENV_SCRIPT"
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось установить окружение"
    exit 1
fi

# Делаем файл исполняемым (на всякий случай)
chmod +x "$TMP_REPRISE_FILE"

# Выполняем команды из файла перезапуска
echo "  Выполняем команды из $TMP_REPRISE_FILE..."
bash "$TMP_REPRISE_FILE"
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "  Команды успешно выполнены"
else
    echo "  Внимание: Некоторые команды завершились с ошибкой (код: $EXIT_CODE)"
fi

# Шаг 6: Удаление выполненных записей из таблицы SRM_Relaunch
echo "Шаг 6: Удаление выполненных записей из SRM_Relaunch..."

# Получаем taskid для удаления (снова, чтобы быть уверенными)
TASK_IDS_TO_DELETE=$(execute_sql "
set pagesize 0
set feedback off
set heading off
select taskid from SRM_Relaunch 
where AsofDate = '$DATE_PARAM' 
and JobName = 'M32DRelaunchHypo';
")

if [ -n "$TASK_IDS_TO_DELETE" ]; then
    echo "  Удаляем записи с taskid:"
    echo "$TASK_IDS_TO_DELETE" | sed 's/^/    /'
    
    DELETE_RESULT=$(execute_sql "
    delete from SRM_Relaunch 
    where AsofDate = '$DATE_PARAM' 
    and JobName = 'M32DRelaunchHypo';
    commit;
    ")
    
    if [ $? -eq 0 ]; then
        echo "  Записи успешно удалены из SRM_Relaunch"
    else
        echo "  Ошибка при удалении записей из SRM_Relaunch"
        echo "  Результат: $DELETE_RESULT"
    fi
else
    echo "  Нет записей для удаления (возможно, уже удалены)"
fi

# Шаг 7: Очистка временных файлов
echo "Шаг 7: Очистка временных файлов..."
rm -f "$TMP_REPRISE_FILE"
echo "  Временный файл удален"

echo "=== Скрипт перезапуска HYPO завершен ==="
exit 0
```

## Ключевые изменения:

### 1. **Разделение параметров подключения**
```bash
DB_LOGIN="your_username"
DB_PASS="your_password"
ORACLE_SID="your_sid"
```

### 2. **Создание функции execute_sql**
Функция принимает SQL-запрос и выполняет его через sqlplus с использованием всех трех параметров:
```bash
execute_sql() {
    local sql_query="$1"
    echo "$sql_query" | sqlplus -s "${DB_LOGIN}/${DB_PASS}@${ORACLE_SID}"
}
```

### 3. **Добавление проверки подключения**
```bash
check_db_connection() {
    echo "Проверка подключения к базе данных..."
    if execute_sql "select 1 from dual;" > /dev/null 2>&1; then
        echo "  Подключение к БД успешно установлено"
        return 0
    else
        echo "  ОШИБКА: Не удалось подключиться к БД"
        return 1
    fi
}
```

### 4. **Альтернативные варианты подключения**

В зависимости от конфигурации Oracle, вы можете использовать разные форматы:

**Вариант A: Через переменную окружения ORACLE_SID**
```bash
ORACLE_SID="${ORACLE_SID}" sqlplus -s "${DB_LOGIN}/${DB_PASS}"
```

**Вариант B: Через TNS-алиас**
```bash
TNS_ALIAS="MYDB"
sqlplus -s "${DB_LOGIN}/${DB_PASS}@${TNS_ALIAS}"
```

**Вариант C: Через полный connection string**
```bash
CONN_STRING="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=hostname)(PORT=1521))(CONNECT_DATA=(SID=${ORACLE_SID})))"
sqlplus -s "${DB_LOGIN}/${DB_PASS}@${CONN_STRING}"
```

### 5. **Использование переменных окружения (рекомендуемый способ)**

Для повышения безопасности, рекомендуется читать параметры из переменных окружения:

```bash
# В начале скрипта
DB_LOGIN=${DB_USER:-"default_user"}
DB_PASS=${DB_PASSWORD:-"default_pass"}
ORACLE_SID=${ORACLE_SID:-"default_sid"}

# Тогда запуск будет:
export DB_USER="username"
export DB_PASSWORD="password"
export ORACLE_SID="sid"
./script.sh 20260216
```

### 6. **Улучшенная обработка ошибок**

Добавлены проверки:
- Существование рабочей директории
- Успешность подключения к БД
- Обработка пустых строк при парсинге

### 7. **Улучшенное форматирование вывода**

Добавлены отступы для лучшей читаемости вывода:
```bash
echo "$TASK_IDS" | sed 's/^/  /'  # Добавляет отступ в 2 пробела перед каждой строкой
```