# Git Scripts

## Prompt:
_Git 2.19. Цель такая нужно подготовить набор скриптов для:
- first cleaning
 - obsoleted branches ( 2 years old)
 - merged branches.
Скрипты должны быть :
для первого
- формат: имя ветки, создатель+email, количество commits, дата последнего+автор+email . В конце общее количество найденных веток отвечающих критерию
- вывод 3 типов: silent - to result file (показывать только прогресс); to console; и совмещенный. 
для второго в формат добавить дату merge+автор+email._

Вот набор скриптов для очистки устаревших и мердженных веток в Git 2.19:

### 1. Скрипт для поиска устаревших веток (старше 2 лет)

```bash
#!/bin/bash

# Скрипт для поиска устаревших веток (старше 2 лет)
# Параметры:
#   --silent - только запись в файл
#   --console - только вывод в консоль
#   (без параметров) - и вывод в консоль, и запись в файл

OUTPUT_FILE="obsolete_branches_$(date +%Y%m%d).txt"
TWO_YEARS_AGO=$(date -d "2 years ago" +%s)

# Функция для получения информации о ветке
get_branch_info() {
    local branch=$1
    local creator=$(git log --format="%an <%ae>" "$branch" | tail -1)
    local last_commit=$(git log -1 --format="%cd %an <%ae>" --date=short "$branch")
    local commit_count=$(git rev-list --count "$branch")
    echo "$branch,$creator,$commit_count,$last_commit"
}

# Обработка параметров
SILENT=false
CONSOLE=false

case $1 in
    --silent) SILENT=true ;;
    --console) CONSOLE=true ;;
esac

# Основной процесс
echo "Поиск устаревших веток (старше 2 лет)..." >&2

BRANCHES=$(git branch -r --no-merged | grep -v HEAD | sed 's/origin\///')

TOTAL=0
RESULTS=""

for branch in $BRANCHES; do
    LAST_COMMIT_DATE=$(git log -1 --format="%at" "origin/$branch")
    if [ "$LAST_COMMIT_DATE" -lt "$TWO_YEARS_AGO" ]; then
        INFO=$(get_branch_info "origin/$branch")
        if [ "$CONSOLE" = true ] || [ "$SILENT" = false ] && [ "$CONSOLE" = false ]; then
            echo "$INFO"
        fi
        RESULTS="${RESULTS}${INFO}\n"
        ((TOTAL++))
    fi
done

# Запись в файл если не только консоль
if [ "$CONSOLE" = false ]; then
    echo -e "Ветка,Создатель,Количество коммитов,Последний коммит (дата автор email)\n" > "$OUTPUT_FILE"
    echo -e "$RESULTS" >> "$OUTPUT_FILE"
    echo "Всего найдено: $TOTAL" >> "$OUTPUT_FILE"
fi

# Вывод итогов
if [ "$SILENT" = false ]; then
    echo "Всего найдено устаревших веток: $TOTAL"
fi
```

### 2. Скрипт для поиска мердженных веток

```bash
#!/bin/bash

# Скрипт для поиска мердженных веток
# Параметры:
#   --silent - только запись в файл
#   --console - только вывод в консоль
#   (без параметров) - и вывод в консоль, и запись в файл

OUTPUT_FILE="merged_branches_$(date +%Y%m%d).txt"

# Функция для получения информации о ветке
get_merged_branch_info() {
    local branch=$1
    local creator=$(git log --format="%an <%ae>" "$branch" | tail -1)
    local last_commit=$(git log -1 --format="%cd %an <%ae>" --date=short "$branch")
    local commit_count=$(git rev-list --count "$branch")
    local merge_info=$(git log --merges --first-parent --format="%cd %an <%ae>" --date=short | grep -A 5 -m 1 "Merge branch '$branch'")
    local merge_date=$(echo "$merge_info" | head -1)
    echo "$branch,$creator,$commit_count,$last_commit,$merge_date"
}

# Обработка параметров
SILENT=false
CONSOLE=false

case $1 in
    --silent) SILENT=true ;;
    --console) CONSOLE=true ;;
esac

# Основной процесс
echo "Поиск мердженных веток..." >&2

BRANCHES=$(git branch -r --merged | grep -v HEAD | sed 's/origin\///')

TOTAL=0
RESULTS=""

for branch in $BRANCHES; do
    INFO=$(get_merged_branch_info "origin/$branch")
    if [ "$CONSOLE" = true ] || [ "$SILENT" = false ] && [ "$CONSOLE" = false ]; then
        echo "$INFO"
    fi
    RESULTS="${RESULTS}${INFO}\n"
    ((TOTAL++))
done

# Запись в файл если не только консоль
if [ "$CONSOLE" = false ]; then
    echo -e "Ветка,Создатель,Количество коммитов,Последний коммит (дата автор email),Дата мерджа (автор email)\n" > "$OUTPUT_FILE"
    echo -e "$RESULTS" >> "$OUTPUT_FILE"
    echo "Всего найдено: $TOTAL" >> "$OUTPUT_FILE"
fi

# Вывод итогов
if [ "$SILENT" = false ]; then
    echo "Всего найдено мердженных веток: $TOTAL"
fi
```

### Инструкция по использованию:

1. Сохраните скрипты в файлы, например `find_obsolete.sh` и `find_merged.sh`
2. Сделайте их исполняемыми: `chmod +x find_obsolete.sh find_merged.sh`
3. Запускайте с разными параметрами:
   - `./find_obsolete.sh` - вывод и в консоль, и в файл
   - `./find_obsolete.sh --silent` - только запись в файл
   - `./find_obsolete.sh --console` - только вывод в консоль
   - Аналогично для скрипта `find_merged.sh`

### Примечания:
1. Скрипты работают с remote-ветками (origin)
2. Для устаревших веток проверяется последний коммит старше 2 лет
3. Для мердженных веток ищется информация о мердже
4. Формат вывода: CSV с запятыми в качестве разделителей
5. Результаты сохраняются в файлы с датой в названии

Вы можете модифицировать скрипты под свои нужды, например изменить формат даты или добавить дополнительные поля.
