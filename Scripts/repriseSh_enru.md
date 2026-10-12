Я создам Bash-скрипт на основе вашего описания и подробно объясню каждый шаг.

## Prompt:
_To search inside the SRM_Relaunch table the list of filter name and effect to relaunch.

```sql
select taskid from SRM_Relaunch where AsofDate = <dateof> and JobName = 'M32DRelaunchHypo';
```

```sql
select filtername, effect from SRM_task_CPNL where Active= 1 and ID in ( select tskid from SRM_Relaunch where AsofDate = <dateof> and JobName = 'M32DRelaunchHypo')
```
Use it as a egrep to search the "hypo_compute_pnl.pl" in the "travaux" directory.
for exemple in this directory:
/slpafr32ba07/appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS/travaux
Take into account the "--copy-to" parameter in the HYPO relauch file by relying on the "--effect-name" + "--filter" combination.

Exemple doing a grep for "--filter CPNL_06211" and "--effect-name=correltaux"
of if it return nothing do the following grep

 "--filter CPNL_06211" and "--copy-to correltaux"
because some effect or just a copy of another one.
after that 
it will return this line

```bash
hypo_compute_pnl.pl --effect-name=spreadtaux --filter=CPNL_06193 --cvid=MOJSPRE --xydate=130226 --report-date=20260216 --pnl-args="-XML -FR..." --utput-dir=/slpafr32ba07/appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS/cft/NSDCVFT.wait/ --copy-to voltaux/MOJVOL --copy-to smiletaux/MOJSMILE --copy-to correltaux/MOJCOR --copy-to smilefx/MOJSMIFX --copy-to fx/MOJFX --copy-to volfx/MOJVFX 1> slpafr32ba07/appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS//logs/XFRDCalcPNLSpredTaux/PNL_COMPUTE_CPNL_06193_EFFECT_SPREADTAUX.log
```
The JobName must be replaced by M32DRelaunchHypo so XFRDCalcPNLSpredTaux will become M32DRelaunchHypo

```bash
appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS/cft/NSDCVFT.wait/ --copy-to voltaux/MOJVOL --copy-to smiletaux/MOJSMILE --copy-to correltaux/MOJCOR --copy-to smilefx/MOJSMIFX --copy-to fx/MOJFX --copy-to volfx/MOJVFX 1> slpafr32ba07/appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS//logs/M32DRelaunchHypo/PNL_COMPUTE_CPNL_06193_EFFECT_SPREADTAUX.log
```

Then we add it in a temporary file of reprise.cmd for closing PARIS
And execute the reprise.cmd with script of environment

```bash
appSetEnv M32_PROD_HYPO
```

When reprise.cmd is finished we must delete the line in SRM_Relaunch table to avoide re-execution of the script._

```bash
#!/bin/bash

# Скрипт для поиска и выполнения команд перерасчета HYPO
# Основан на описании задачи по работе с SRM_Relaunch таблицей

# Конфигурация
SCRIPT_NAME=$(basename "$0")
DATE_PARAM="$1"  # Дата в формате, ожидаемом базой данных
TMP_REPRISE_FILE="/tmp/reprise_$$.cmd"
WORK_DIR="/slpafr32ba07/appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS/travaux"
DB_CONNECTION="your_db_connection_string"  # Замените на реальные параметры подключения к БД
ENV_SCRIPT="appSetEnv M32_PROD_HYPO"

# Проверка аргументов
if [ -z "$DATE_PARAM" ]; then
    echo "Ошибка: Не указана дата"
    echo "Использование: $SCRIPT_NAME <date>"
    exit 1
fi

echo "=== Запуск скрипта перезапуска HYPO для даты: $DATE_PARAM ==="

# Шаг 1: Получение списка taskid из SRM_Relaunch
echo "Шаг 1: Получение списка taskid из SRM_Relaunch..."
TASK_IDS=$(sqlplus -s "$DB_CONNECTION" <<EOF
set pagesize 0
set feedback off
set heading off
select taskid from SRM_Relaunch 
where AsofDate = '$DATE_PARAM' 
and JobName = 'M32DRelaunchHypo';
EOF
)

if [ -z "$TASK_IDS" ]; then
    echo "Не найдено задач для перезапуска с датой $DATE_PARAM"
    exit 0
fi

echo "Найдены taskid: $TASK_IDS"

# Шаг 2: Получение списка filtername и effect для найденных taskid
echo "Шаг 2: Получение списка filtername и effect из SRM_task_CPNL..."
FILTER_EFFECT_PAIRS=$(sqlplus -s "$DB_CONNECTION" <<EOF
set pagesize 0
set feedback off
set colsep '|'
select filtername, effect from SRM_task_CPNL 
where Active = 1 
and ID in (
    select tskid from SRM_Relaunch 
    where AsofDate = '$DATE_PARAM' 
    and JobName = 'M32DRelaunchHypo'
);
EOF
)

if [ -z "$FILTER_EFFECT_PAIRS" ]; then
    echo "Не найдено активных CPNL для указанных taskid"
    exit 0
fi

echo "Найдены пары filtername|effect:"
echo "$FILTER_EFFECT_PAIRS"

# Шаг 3: Поиск команд в файлах travaux и формирование reprise.cmd
echo "Шаг 3: Поиск команд в директории $WORK_DIR..."

# Очищаем временный файл
> "$TMP_REPRISE_FILE"

# Переходим в рабочую директорию
cd "$WORK_DIR" || {
    echo "Ошибка: Не удалось перейти в директорию $WORK_DIR"
    exit 1
}

# Обрабатываем каждую пару filter-effect
echo "$FILTER_EFFECT_PAIRS" | while IFS='|' read -r FILTER EFFECT; do
    # Убираем пробелы
    FILTER=$(echo "$FILTER" | xargs)
    EFFECT=$(echo "$EFFECT" | xargs)
    
    echo "  Обработка: filter=$FILTER, effect=$EFFECT"
    
    # Пытаемся найти команду с --effect-name
    COMMAND=$(grep -l -r "hypo_compute_pnl.pl" . | xargs grep -l "--filter $FILTER" | xargs grep -l "--effect-name=$EFFECT" 2>/dev/null | head -1)
    
    # Если не нашли, пробуем найти с --copy-to
    if [ -z "$COMMAND" ]; then
        echo "    Не найдено с --effect-name, пробуем поиск с --copy-to $EFFECT..."
        COMMAND=$(grep -l -r "hypo_compute_pnl.pl" . | xargs grep -l "--filter $FILTER" | xargs grep -l "--copy-to.*$EFFECT" 2>/dev/null | head -1)
    fi
    
    # Если нашли файл с командой, извлекаем полную команду
    if [ -n "$COMMAND" ]; then
        FULL_COMMAND=$(grep -h "hypo_compute_pnl.pl" "$COMMAND" | grep -- "--filter $FILTER" | head -1)
        
        if [ -n "$FULL_COMMAND" ]; then
            echo "    Найдена команда:"
            echo "    $FULL_COMMAND"
            
            # Модифицируем путь в логах - заменяем XFRDCalcPNLSpredTaux на M32DRelaunchHypo
            MODIFIED_COMMAND=$(echo "$FULL_COMMAND" | sed 's|XFRDCalcPNLSpredTaux|M32DRelaunchHypo|g')
            
            # Добавляем команду в файл перезапуска
            echo "$MODIFIED_COMMAND" >> "$TMP_REPRISE_FILE"
            echo "    Команда добавлена в $TMP_REPRISE_FILE"
        else
            echo "    Не удалось извлечь полную команду из файла $COMMAND"
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
cat "$TMP_REPRISE_FILE"

# Шаг 5: Установка окружения и выполнение команд
echo "Шаг 5: Установка окружения и выполнение команд..."

# Устанавливаем окружение
echo "  Выполняем: $ENV_SCRIPT"
eval "$ENV_SCRIPT"
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось установить окружение"
    exit 1
fi

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
TASK_IDS_TO_DELETE=$(sqlplus -s "$DB_CONNECTION" <<EOF
set pagesize 0
set feedback off
set heading off
select taskid from SRM_Relaunch 
where AsofDate = '$DATE_PARAM' 
and JobName = 'M32DRelaunchHypo';
EOF
)

if [ -n "$TASK_IDS_TO_DELETE" ]; then
    echo "  Удаляем записи с taskid: $TASK_IDS_TO_DELETE"
    
    sqlplus -s "$DB_CONNECTION" <<EOF
    delete from SRM_Relaunch 
    where AsofDate = '$DATE_PARAM' 
    and JobName = 'M32DRelaunchHypo';
    commit;
EOF
    
    if [ $? -eq 0 ]; then
        echo "  Записи успешно удалены из SRM_Relaunch"
    else
        echo "  Ошибка при удалении записей из SRM_Relaunch"
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

## Пошаговое объяснение скрипта:

### Шаг 1: Проверка аргументов и настройка
- Скрипт проверяет, передана ли дата как аргумент
- Определяются переменные конфигурации: пути, файлы, параметры подключения к БД

### Шаг 2: Получение taskid из SRM_Relaunch
- Выполняется SQL-запрос для получения всех taskid из таблицы `SRM_Relaunch` 
- Условия: `AsofDate` равна переданной дате и `JobName = 'M32DRelaunchHypo'`
- Результат сохраняется в переменную `TASK_IDS`

### Шаг 3: Получение пар filter-effect из SRM_task_CPNL
- Для найденных taskid получаем соответствующие записи из `SRM_task_CPNL`
- Выбираем только активные записи (`Active = 1`)
- Получаем пары `filtername` и `effect`, разделенные символом '|'

### Шаг 4: Поиск команд в директории travaux
- Переходим в рабочую директорию `/slpafr32ba07/appli/M32_SUMMIT_FRONT/XFR_DCALCUL_HYPO-PARIS/travaux`
- Для каждой пары filter-effect:
  - Сначала ищем файлы, содержащие одновременно `--filter FILTER` и `--effect-name=EFFECT`
  - Если не найдено, ищем комбинацию `--filter FILTER` и `--copy-to EFFECT`
  - Из найденного файла извлекаем полную команду с `hypo_compute_pnl.pl`
  - Модифицируем путь в логах: заменяем `XFRDCalcPNLSpredTaux` на `M32DRelaunchHypo`
  - Добавляем модифицированную команду во временный файл `reprise.cmd`

### Шаг 5: Выполнение команд
- Устанавливаем окружение с помощью `appSetEnv M32_PROD_HYPO`
- Запускаем все собранные команды из временного файла
- Сохраняем код возврата для проверки успешности выполнения

### Шаг 6: Очистка таблицы SRM_Relaunch
- После успешного (или неуспешного) выполнения удаляем обработанные записи из таблицы
- Используем те же условия: `AsofDate` и `JobName = 'M32DRelaunchHypo'`
- Выполняем commit для фиксации изменений

### Шаг 7: Очистка временных файлов
- Удаляем созданный временный файл с командами

## Важные замечания:

1. **Параметры подключения к БД**: В скрипте используется переменная `DB_CONNECTION`, которую нужно заменить на реальные параметры подключения к вашей базе данных.

2. **Безопасность**: Скрипт использует временные файлы с PID в имени (`reprise_$$.cmd`), что предотвращает конфликты при параллельном запуске.

3. **Обработка ошибок**: Скрипт проверяет наличие данных на каждом этапе и завершается с соответствующим сообщением, если данные не найдены.

4. **Гибкость поиска**: Реализован двухэтапный поиск команд: сначала по точному соответствию effect-name, затем по copy-to, как требовалось в описании.

5. **Логирование**: Скрипт выводит подробную информацию о каждом шаге, что помогает в отладке.