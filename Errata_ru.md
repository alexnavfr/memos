# исправление скрипта

## Prompt:
_Git 2.19. Bash. Представленный ниже скрипт содержит ошибку. При использовании опции "--console" мы получаем цветовой вывод информации, при использовании опции "--silent" мы просто пишем информацию в файл. Но когда единственным параметром является дата, например "2y" данные одновременно пишутся в файл и выводятся на консоль. В нашем случае ошибка в том что вывод на консоль происходит без цветов. Исправь её и подробно объясни изменения._

Анализируя скрипт, я вижу основную проблему: когда используется только параметр времени (без `--console` или `--silent`), данные выводятся на консоль, но без цветов. Это происходит потому, что в функции `get_branch_info` цветной вывод зависит только от переменной `CONSOLE`, которая в этом случае равна `false`.

Вот исправленная версия скрипта с подробными объяснениями:

```bash
#!/bin/bash

# Script for searching for outdated branches based on specified time
# Parameters:
#   --silent         Only write to file
#   --console        Only output to console
#   --help           Show this help message
#   --delete         Delete branches after confirmation
#   --delete-force   Delete branches without confirmation
#   time             Time period (2y, 1y, 6m, 3m)
#   (no parameters)  show this help message

OUTPUT_FILE="outdated_branches_$(date +%Y%m%d).txt"

# Function to calculate the timestamp based on the input time parameter
calculate_time() {
    local period=$1
    case $period in
        2y) date -d "2 years ago" +%s ;;
        1y) date -d "1 year ago" +%s ;;
        6m) date -d "6 months ago" +%s ;;
        3m) date -d "3 months ago" +%s ;;
        *) return 1 ;;  # Invalid period
    esac
}

# ANSI color codes
COLOR_BRANCH="\033[1;34m"    # Blue for branch name
COLOR_CREATOR="\033[1;32m"   # Green for creator
COLOR_COMMIT_COUNT="\033[1;33m" # Yellow for commit count
COLOR_LAST_COMMIT="\033[1;35m" # Magenta for last commit
COLOR_RESET="\033[0m"        # Reset to default color

# Function for obtaining information about a branch
get_branch_info() {
    local branch=$1
    local use_color=$2
    local creator=$(git log --format="%an <%ae>" "$branch" | tail -1)
    local last_commit=$(git log -1 --format="%cd %an <%ae>" --date=short "$branch")
    local commit_count=$(git rev-list --count "$branch")

    # Color output if use_color is true
    if [ "$use_color" = true ]; then
        echo -e "${COLOR_BRANCH}$branch${COLOR_RESET}, ${COLOR_CREATOR}$creator${COLOR_RESET}, ${COLOR_COMMIT_COUNT}$commit_count${COLOR_RESET}, ${COLOR_LAST_COMMIT}$last_commit${COLOR_RESET}"
    else
        echo "$branch,$creator,$commit_count,$last_commit"
    fi
}

# Function to display help information
show_help() {
    echo "Usage: $0 <time> [options]"
    echo
    echo "Desc: Script for searching for outdated branches based on specified time"
    echo
    echo "Time options:"
    echo "  2y              2 years"
    echo "  1y              1 year"
    echo "  6m              6 months"
    echo "  3m              3 months"
    echo "Options:"
    echo "  --silent         Only write to file"
    echo "  --console        Only output to console"
    echo "  --help           Show this help message"
    echo "  --delete         Delete branches after confirmation"
    echo "  --delete-force   Delete branches without confirmation"
    echo "  (no params)      Show this help message"
}

# Parameter processing
SILENT=false
CONSOLE=false
DELETE=false
DELETE_FORCE=false

# Check for time parameter
if [[ $# -lt 1 ]]; then
    show_help
    exit 1
fi

# Get the time parameter and calculate the timestamp
TIME_PERIOD=$1
TWO_YEARS_AGO=$(calculate_time "$TIME_PERIOD")

# Validate the time parameter
if [ $? -ne 0 ]; then
    echo "Invalid time parameter."
    show_help
    exit 1
fi

shift  # Remove the time parameter for further options

while [[ $# -gt 0 ]]; do
    case $1 in
        --silent) SILENT=true; shift ;;
        --console) CONSOLE=true; shift ;;
        --help) show_help; exit 0 ;;
        --delete) DELETE=true; shift ;;
        --delete-force) DELETE_FORCE=true; shift ;;
        *) echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

# Determine if we should use color output
USE_COLOR=false
if [ "$CONSOLE" = true ] || ([ "$SILENT" = false ] && [ "$CONSOLE" = false ]); then
    # Use color if outputting to console (either with --console or default behavior)
    if [ -t 1 ]; then  # Check if stdout is a terminal
        USE_COLOR=true
    fi
fi

# Main process
echo "Search for outdated branches (older than specified time)..." >&2

BRANCHES=$(git branch -r --no-merged | grep -v HEAD | sed 's/origin\///')

TOTAL=0
RESULTS=""

for branch in $BRANCHES; do
    LAST_COMMIT_DATE=$(git log -1 --format="%at" "origin/$branch")
    if [ "$LAST_COMMIT_DATE" -lt "$TWO_YEARS_AGO" ]; then
        INFO=$(get_branch_info "origin/$branch" "$USE_COLOR")
        if [ "$SILENT" = false ]; then
            echo -e "$INFO"
        fi
        # Store plain text version for file output
        PLAIN_INFO=$(get_branch_info "origin/$branch" false)
        RESULTS="${RESULTS}${PLAIN_INFO}\n"
        ((TOTAL++))

        # Handle deletion if requested
        if [ "$DELETE" = true ]; then
            read -p "Are you sure you want to delete branch 'origin/$branch'? (y/N): " confirm
            if [[ "$confirm" == [yY] ]]; then
                git push origin --delete "$branch"
                echo "Deleted branch 'origin/$branch'."
            fi
        elif [ "$DELETE_FORCE" = true ]; then
            git push origin --delete "$branch"
            echo "Force deleted branch 'origin/$branch'."
        fi
    fi
done

# Write to file if not only console
if [ "$CONSOLE" = false ]; then
    echo -e "Branch, Creator, Number of commits, Last commit (date author email)\n" > "$OUTPUT_FILE"
    echo -e "$RESULTS" >> "$OUTPUT_FILE"
    echo "Total number of obsolete branches found: $TOTAL" >> "$OUTPUT_FILE"
fi

# Output final results
echo "Total number of obsolete branches found: $TOTAL"
```

## Основные изменения и объяснения:

### 1. **Изменение функции `get_branch_info`**
- Добавлен параметр `use_color`, который явно указывает, использовать ли цветной вывод
- Вместо проверки `CONSOLE` теперь проверяется переданный параметр `use_color`

### 2. **Добавлена логика определения использования цветов**
```bash
USE_COLOR=false
if [ "$CONSOLE" = true ] || ([ "$SILENT" = false ] && [ "$CONSOLE" = false ]); then
    # Use color if outputting to console (either with --console or default behavior)
    if [ -t 1 ]; then  # Check if stdout is a terminal
        USE_COLOR=true
    fi
fi
```

Эта логика:
- Использует цвет, если вывод идет на консоль (с `--console` или по умолчанию)
- Проверяет `[ -t 1 ]` чтобы убедиться, что stdout является терминалом (это предотвращает использование цветовых кодов при перенаправлении вывода)

### 3. **Разделение вывода для консоли и файла**
```bash
INFO=$(get_branch_info "origin/$branch" "$USE_COLOR")
if [ "$SILENT" = false ]; then
    echo -e "$INFO"
fi
# Store plain text version for file output
PLAIN_INFO=$(get_branch_info "origin/$branch" false)
RESULTS="${RESULTS}${PLAIN_INFO}\n"
```

Теперь:
- `INFO` содержит цветной или простой текст для вывода на консоль
- `PLAIN_INFO` всегда содержит простой текст (без цветовых кодов) для записи в файл

### 4. **Почему это исправляет проблему**

В оригинальном скрипте проблема была в том, что при использовании только параметра времени:
- `CONSOLE=false` и `SILENT=false`
- Функция `get_branch_info` видела `CONSOLE=false` и выводила простой текст
- Но вывод все равно шел на консоль, где мы хотели бы видеть цвета

В исправленной версии:
- Мы определяем, нужно ли использовать цвета на основе того, куда идет вывод
- Даже без `--console`, если вывод идет в терминал, используются цвета
- При этом файл всегда получает чистый текст без цветовых кодов

Это решение обеспечивает корректное поведение во всех сценариях использования.
