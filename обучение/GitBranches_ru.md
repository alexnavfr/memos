# Git Branches.

## Prompt:
_Git.Bash. Создай скрипт который в зависимости от введенных параметров показывает информацию о:
первое - локальых и удаленных ветках текушего пользователя
второе - всегда добавлять возможнось получить информацию зная email пользователя
третье - всегда показывать help если скрипт запущен без параметров.
четвертое - параметр help необходим по умолчанию
пятое - дата обязательна для нижней границы поиска
шестое - локальные и удаленные ветки могут быть показаны отдельно или вместе. При показе вместе различать по цветам типы ветокы. Параметры --all,--local,--remote
седьмое - добавить возможность инерактивно удалять ветки которые уже были замержены в основую ветку `main/master`_

Окей 👍
Ниже пример скрипта для **Git Bash** (`git-branches.sh`), который реализует все указанные требования:

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
    echo "  --cleanup       интерактивно удалить локальные ветки, уже слитые в main/master"
    echo "  --help          показать эту справку"
    echo
    echo "Примеры:"
    echo "  $0 --all"
    echo "  $0 --email user@example.com --since '2024-01-01'"
    echo "  $0 --cleanup"
}

# Если без параметров → показать help
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

ACTION=""

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
if [ -n "$EMAIL" ]; then
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
```

---

📌 **Что реализовано:**

1. `--all`, `--local`, `--remote` — вывод веток с цветами.
2. `--email <mail> --since <date>` — поиск коммитов автора с нижней границей по дате.
3. `--help` и запуск без параметров — вывод справки.
4. `--cleanup` — интерактивное удаление замерженных веток в `main` или `master`.

---

Хотите, я сделаю так, чтобы **при выводе веток одновременно (`--all`) локальные и удалённые показывались в одном списке вперемешку**, но с разными цветами?

## Prompt2:
_без указания электронного адреса работаем с пользователем который запустил скрипт_

Ага, понял 👍
То есть если параметр `--email` не указан, то скрипт должен использовать email текущего Git-пользователя (`git config user.email`).

Я обновлю кусок кода для поиска по коммитам, чтобы это учитывалось:

```bash
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
```

---

📌 Теперь:

* Если указаны `--email` и `--since` → берём явно заданный email.
* Если указан только `--since` → берём email из `git config user.email`.
* Если email определить не удалось → ошибка.

---

Хочешь, я соберу полный скрипт уже с этим исправлением, чтобы у тебя была готовая версия?

## Prompt3 :
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

Окей 🚀 Я доработал скрипт так, чтобы при `--all` локальные и удалённые ветки показывались **в одном списке**, но подсвечивались разными цветами (зелёный для локальных, синий для удалённых).

Вот полный скрипт `git-branches.sh`:

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
    echo "  --all           показать локальные и удаленные ветки (одним списком, цветами)"
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
    echo "Все ветки:"
    {
        git branch --format="local:%(refname:short)"
        git branch -r --format="remote:%(refname:short)"
    } | sort | while IFS= read -r line; do
        if [[ $line == local:* ]]; then
            echo -e "${GREEN}${line#local:}${RESET}"
        else
            echo -e "${BLUE}${line#remote:}${RESET}"
        fi
    done
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

### 🔧 Теперь при `--all` результат будет таким:

```
Все ветки:
main              ← зелёным (локальная)
feature-xyz       ← зелёным (локальная)
origin/main       ← синим (удалённая)
origin/feature-xyz← синим (удалённая)
```

---

Хочешь, я ещё добавлю подсветку **активной ветки звёздочкой** (например, `* main` зелёным жирным)?

