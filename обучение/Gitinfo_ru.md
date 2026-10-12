# Git info

## Prompt:
_Дай полный скрипт который будет работать._

Отлично 🚀 Ниже даю полный готовый скрипт `git-branches.sh`, который соответствует всем твоим условиям:

```bash
#!/usr/bin/env bash

# Цвета для вывода
RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
RESET="\033[0m"

show_help() {
    echo "Использование: $0 [параметры]"
    echo
    echo "Параметры:"
    echo "  --all           показать локальные и удаленные ветки (с цветами)"
    echo "  --local         показать только локальные ветки"
    echo "  --remote        показать только удаленные ветки"
    echo "  --email <mail>  показать коммиты пользователя с указанным email (требуется --since)"
    echo "  --since <date>  дата начала поиска (обязательна для поиска по email)"
    echo "                  если email не указан, используется git config user.email"
    echo "  --cleanup       интерактивно удалить локальные ветки, уже слитые в main/master"
    echo "  --help          показать эту справку"
    echo
    echo "Примеры:"
    echo "  $0 --all"
    echo "  $0 --since '2024-01-01'"
    echo "  $0 --email user@example.com --since '2024-01-01'"
    echo "  $0 --cleanup"
}

# Если без параметров → показать help
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

ACTION=""
EMAIL=""
SINCE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            ACTION="all"
            shift
            ;;
        --local)
            ACTION="local"
            shift
            ;;
        --remote)
            ACTION="remote"
            shift
            ;;
        --email)
            EMAIL="$2"
            shift 2
            ;;
        --since)
            SINCE="$2"
            shift 2
            ;;
        --cleanup)
            ACTION="cleanup"
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Неизвестный параметр: $1"
            show_help
            exit 1
            ;;
    esac
done

### 1. Показ веток
if [ "$ACTION" = "all" ]; then
    echo -e "${GREEN}Локальные ветки:${RESET}"
    git branch --color=always
    echo
    echo -e "${BLUE}Удаленные ветки:${RESET}"
    git branch -r --color=always
    exit 0
elif [ "$ACTION" = "local" ]; then
    echo -e "${GREEN}Локальные ветки:${RESET}"
    git branch --color=always
    exit 0
elif [ "$ACTION" = "remote" ]; then
    echo -e "${BLUE}Удаленные ветки:${RESET}"
    git branch -r --color=always
    exit 0
fi

### 2. Поиск по email (с датой)
if [ -n "$EMAIL" ] || [ -n "$SINCE" ]; then
    # если email не указан, берём текущего пользователя
    if [ -z "$EMAIL" ]; then
        EMAIL=$(git config user.email)
        if [ -z "$EMAIL" ]; then
            echo "Ошибка: не удалось определить email пользователя (git config user.email пуст)"
            exit 1
        fi
    fi

    if [ -z "$SINCE" ]; then
        echo "Ошибка: для поиска по email необходимо указать --since <дата>"
        exit 1
    fi

    echo "Коммиты пользователя с email $EMAIL начиная с $SINCE:"
    git log --since="$SINCE" --author="$EMAIL" --pretty=format:"%h %ad | %s [%an]" --date=short
    exit 0
fi

### 3. Очистка замерженных веток
if [ "$ACTION" = "cleanup" ]; then
    MAIN_BRANCH=""
    if git show-ref --verify --quiet refs/heads/main; then
        MAIN_BRANCH="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        MAIN_BRANCH="master"
    else
        echo "Не найдена основная ветка (main/master)"
        exit 1
    fi

    echo "Проверяем ветки, слитые в $MAIN_BRANCH..."
    git checkout "$MAIN_BRANCH" >/dev/null 2>&1 || exit 1
    git fetch --all --prune

    MERGED_BRANCHES=$(git branch --merged "$MAIN_BRANCH" | grep -vE "^\*|$MAIN_BRANCH")

    if [ -z "$MERGED_BRANCHES" ]; then
        echo "Нет веток для удаления."
        exit 0
    fi

    echo "Найденные ветки:"
    echo "$MERGED_BRANCHES"
    echo
    read -p "Удалить эти ветки? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "$MERGED_BRANCHES" | xargs -r git branch -d
    else
        echo "Отмена."
    fi
    exit 0
fi

# Если ничего не подошло — показать help
show_help
```

---

### 🔧 Как использовать:

1. Сохрани как `git-branches.sh`
2. Сделай исполняемым:

   ```bash
   chmod +x git-branches.sh
   ```
3. Запускай внутри любого Git-репозитория:

   ```bash
   ./git-branches.sh --all
   ./git-branches.sh --since "2024-01-01"
   ./git-branches.sh --email someone@example.com --since "2024-01-01"
   ./git-branches.sh --cleanup
   ```

---

Хочешь, я ещё сделаю вариант, где при `--all` локальные и удалённые ветки будут **в одном списке вперемешку**, но с подсветкой разными цветами?


