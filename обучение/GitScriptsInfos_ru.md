# Варианты получения информации о ветках Git

## Prompt:
_Git.Bash. создаем скрипт по шагам и с параметрами. для начала "--help" где потом укажем как параметр дату "--date". Нужно показать все локальные и удаленные ветки(параметер). Нужен создатель,дата последнего коммита и пользователь_

Я создам для вас Bash скрипт для работы с Git, который включает параметры `--help` и `--date`. Вот полное решение:

## 1. Создаем скрипт `git-branch-info.sh`

```bash
#!/bin/bash

# Функция для отображения справки
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help          Show this help message"
    echo "  --date DATE     Show branches information for specific date (format: YYYY-MM-DD)"
    echo "  --all           Show both local and remote branches (default)"
    echo "  --local         Show only local branches"
    echo "  --remote        Show only remote branches"
    echo ""
    echo "Examples:"
    echo "  $0 --help"
    echo "  $0 --date 2024-01-15"
    echo "  $0 --local"
    echo "  $0 --remote --date 2024-01-10"
}

# Функция для получения информации о ветках
get_branch_info() {
    local branch_type=$1
    local target_date=$2
    
    echo "=== $branch_type BRANCHES ==="
    echo ""
    
    # Получаем список веток в зависимости от типа
    if [ "$branch_type" == "LOCAL" ]; then
        branches=$(git branch --format='%(refname:short)')
    else
        branches=$(git branch -r --format='%(refname:short)' | grep -v 'HEAD')
    fi
    
    # Проходим по всем веткам
    while read -r branch; do
        # Пропускаем пустые строки
        if [ -z "$branch" ]; then
            continue
        fi
        
        # Для удаленных веток убираем origin/ если нужно
        display_branch=$branch
        if [ "$branch_type" == "REMOTE" ]; then
            display_branch=$(echo "$branch" | sed 's/^origin\///')
        fi
        
        # Получаем информацию о последнем коммите
        if [ -n "$target_date" ]; then
            # Ищем коммит на конкретную дату
            commit_info=$(git log -1 --since="$target_date 00:00:00" --until="$target_date 23:59:59" \
                --pretty=format:"%h|%an|%ad|%s" --date=short "$branch" 2>/dev/null)
        else
            # Последний коммит в ветке
            commit_info=$(git log -1 --pretty=format:"%h|%an|%ad|%s" --date=short "$branch" 2>/dev/null)
        fi
        
        if [ -n "$commit_info" ]; then
            IFS='|' read -r commit_hash author commit_date subject <<< "$commit_info"
            
            echo "Branch: $display_branch"
            echo "  Last Commit: $commit_hash"
            echo "  Author:      $author"
            echo "  Date:        $commit_date"
            echo "  Message:     $subject"
            echo "----------------------------------------"
        else
            if [ -n "$target_date" ]; then
                echo "Branch: $display_branch"
                echo "  No commits found for date: $target_date"
                echo "----------------------------------------"
            else
                echo "Branch: $display_branch"
                echo "  No commits found"
                echo "----------------------------------------"
            fi
        fi
    done <<< "$branches"
}

# Основная логика скрипта
main() {
    local show_local=true
    local show_remote=true
    local target_date=""
    
    # Парсим аргументы
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --date)
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    target_date="$2"
                    shift 2
                else
                    echo "Error: --date requires a date parameter"
                    exit 1
                fi
                ;;
            --all)
                show_local=true
                show_remote=true
                shift
                ;;
            --local)
                show_local=true
                show_remote=false
                shift
                ;;
            --remote)
                show_local=false
                show_remote=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Проверяем, что мы в git репозитории
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: This is not a git repository"
        exit 1
    fi
    
    # Получаем информацию о ветках
    if [ "$show_local" = true ]; then
        get_branch_info "LOCAL" "$target_date"
    fi
    
    if [ "$show_remote" = true ]; then
        get_branch_info "REMOTE" "$target_date"
    fi
}

# Запускаем основную функцию
main "$@"
```

## 2. Делаем скрипт исполняемым

```bash
chmod +x git-branch-info.sh
```

## 3. Примеры использования

### Показать справку:
```bash
./git-branch-info.sh --help
```

### Показать все ветки (локальные и удаленные):
```bash
./git-branch-info.sh --all
```

### Показать только локальные ветки:
```bash
./git-branch-info.sh --local
```

### Показать только удаленные ветки:
```bash
./git-branch-info.sh --remote
```

### Показать ветки с коммитами за определенную дату:
```bash
./git-branch-info.sh --date 2024-01-15
```

### Комбинированные параметры:
```bash
./git-branch-info.sh --local --date 2024-01-15
./git-branch-info.sh --remote --date 2024-01-10
```

## 4. Пример вывода

```
=== LOCAL BRANCHES ===

Branch: main
  Last Commit: a1b2c3d
  Author:      John Doe
  Date:        2024-01-15
  Message:     Fix security issue
----------------------------------------
Branch: feature/login
  Last Commit: e4f5g6h
  Author:      Jane Smith
  Date:        2024-01-14
  Message:     Add login functionality
----------------------------------------

=== REMOTE BRANCHES ===

Branch: origin/main
  Last Commit: a1b2c3d
  Author:      John Doe
  Date:        2024-01-15
  Message:     Fix security issue
----------------------------------------
```

## Особенности скрипта:

1. **Параметры**: `--help`, `--date`, `--all`, `--local`, `--remote`
2. **Информация о ветках**: имя ветки, хэш коммита, автор, дата, сообщение
3. **Фильтрация по дате**: показывает коммиты только за указанную дату
4. **Обработка ошибок**: проверка git репозитория, валидация параметров
5. **Форматированный вывод**: читабельный вывод с разделителями

Скрипт готов к использованию в Git Bash на Windows или в любой Unix-подобной системе с установленным Git.

## Prompt 2:
_Прекрасно. Для начала сделаем так что при запуске без параметров будет отрабатывать вариант `--help` по умолчанию._

Отлично! Добавим обработку случая, когда скрипт запускается без параметров. Вот обновленная версия:

## Обновленный скрипт `git-branch-info.sh`

```bash
#!/bin/bash

# Функция для отображения справки
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help          Show this help message"
    echo "  --date DATE     Show branches information for specific date (format: YYYY-MM-DD)"
    echo "  --all           Show both local and remote branches (default)"
    echo "  --local         Show only local branches"
    echo "  --remote        Show only remote branches"
    echo ""
    echo "Examples:"
    echo "  $0 --help"
    echo "  $0 --date 2024-01-15"
    echo "  $0 --local"
    echo "  $0 --remote --date 2024-01-10"
    echo "  $0              # Shows this help message"
}

# Функция для получения информации о ветках
get_branch_info() {
    local branch_type=$1
    local target_date=$2
    
    echo "=== $branch_type BRANCHES ==="
    echo ""
    
    # Получаем список веток в зависимости от типа
    if [ "$branch_type" == "LOCAL" ]; then
        branches=$(git branch --format='%(refname:short)')
    else
        branches=$(git branch -r --format='%(refname:short)' | grep -v 'HEAD')
    fi
    
    # Если нет веток, выводим сообщение
    if [ -z "$branches" ]; then
        echo "No $branch_type branches found"
        echo "----------------------------------------"
        return
    fi
    
    # Проходим по всем веткам
    while read -r branch; do
        # Пропускаем пустые строки
        if [ -z "$branch" ]; then
            continue
        fi
        
        # Для удаленных веток убираем origin/ если нужно
        display_branch=$branch
        if [ "$branch_type" == "REMOTE" ]; then
            display_branch=$(echo "$branch" | sed 's/^origin\///')
        fi
        
        # Получаем информацию о последнем коммите
        if [ -n "$target_date" ]; then
            # Ищем коммит на конкретную дату
            commit_info=$(git log -1 --since="$target_date 00:00:00" --until="$target_date 23:59:59" \
                --pretty=format:"%h|%an|%ad|%s" --date=short "$branch" 2>/dev/null)
        else
            # Последний коммит в ветке
            commit_info=$(git log -1 --pretty=format:"%h|%an|%ad|%s" --date=short "$branch" 2>/dev/null)
        fi
        
        if [ -n "$commit_info" ]; then
            IFS='|' read -r commit_hash author commit_date subject <<< "$commit_info"
            
            echo "Branch: $display_branch"
            echo "  Last Commit: $commit_hash"
            echo "  Author:      $author"
            echo "  Date:        $commit_date"
            echo "  Message:     $subject"
            echo "----------------------------------------"
        else
            if [ -n "$target_date" ]; then
                echo "Branch: $display_branch"
                echo "  No commits found for date: $target_date"
                echo "----------------------------------------"
            else
                echo "Branch: $display_branch"
                echo "  No commits found"
                echo "----------------------------------------"
            fi
        fi
    done <<< "$branches"
}

# Основная логика скрипта
main() {
    local show_local=true
    local show_remote=true
    local target_date=""
    
    # Если нет аргументов, показываем справку
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    # Парсим аргументы
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --date)
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    target_date="$2"
                    shift 2
                else
                    echo "Error: --date requires a date parameter"
                    exit 1
                fi
                ;;
            --all)
                show_local=true
                show_remote=true
                shift
                ;;
            --local)
                show_local=true
                show_remote=false
                shift
                ;;
            --remote)
                show_local=false
                show_remote=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Проверяем, что мы в git репозитории
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: This is not a git repository"
        exit 1
    fi
    
    # Получаем информацию о ветках
    if [ "$show_local" = true ]; then
        get_branch_info "LOCAL" "$target_date"
    fi
    
    if [ "$show_remote" = true ]; then
        get_branch_info "REMOTE" "$target_date"
    fi
}

# Запускаем основную функцию
main "$@"
```

## Теперь скрипт работает так:

### Запуск без параметров (новое поведение):
```bash
./git-branch-info.sh
```
Выведет справку по использованию.

### Все остальные варианты работают как раньше:
```bash
# Справка
./git-branch-info.sh --help

# Все ветки
./git-branch-info.sh --all

# Только локальные ветки
./git-branch-info.sh --local

# Только удаленные ветки
./git-branch-info.sh --remote

# С фильтрацией по дате
./git-branch-info.sh --date 2024-01-15
./git-branch-info.sh --local --date 2024-01-15
```

## Ключевые изменения:

1. **Добавлена проверка**: `if [ $# -eq 0 ]; then` в начале функции `main()`
2. **Обновлена справка**: добавлен пример использования без параметров
3. **Улучшена обработка ошибок**: добавлена проверка на наличие веток

Теперь скрипт более user-friendly - при запуске без параметров пользователь сразу видит, как правильно использовать утилиту.

## Prompt 3:
_По умолчанию работаем с текущим пользователем. Иначе добавляем параметр  `--email name@domaine` что-бы работать с любым пользователем._

Отлично! Добавим параметр `--email` для фильтрации по пользователю. Вот обновленная версия скрипта:

## Обновленный скрипт `git-branch-info.sh`

```bash
#!/bin/bash

# Функция для отображения справки
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help          Show this help message"
    echo "  --date DATE     Show branches information for specific date (format: YYYY-MM-DD)"
    echo "  --email EMAIL   Filter by specific user email (default: current user)"
    echo "  --all           Show both local and remote branches (default)"
    echo "  --local         Show only local branches"
    echo "  --remote        Show only remote branches"
    echo ""
    echo "Examples:"
    echo "  $0 --help"
    echo "  $0 --date 2024-01-15"
    echo "  $0 --email john@example.com"
    echo "  $0 --local --email jane@example.com --date 2024-01-10"
    echo "  $0              # Shows current user's branches"
}

# Функция для получения текущего пользователя Git
get_current_user_email() {
    git config user.email 2>/dev/null
}

# Функция для получения информации о ветках
get_branch_info() {
    local branch_type=$1
    local target_date=$2
    local user_email=$3
    
    echo "=== $branch_type BRANCHES ==="
    if [ -n "$user_email" ]; then
        echo "Filtered by user: $user_email"
    fi
    if [ -n "$target_date" ]; then
        echo "Filtered by date: $target_date"
    fi
    echo ""
    
    # Получаем список веток в зависимости от типа
    if [ "$branch_type" == "LOCAL" ]; then
        branches=$(git branch --format='%(refname:short)')
    else
        branches=$(git branch -r --format='%(refname:short)' | grep -v 'HEAD')
    fi
    
    # Если нет веток, выводим сообщение
    if [ -z "$branches" ]; then
        echo "No $branch_type branches found"
        echo "----------------------------------------"
        return
    fi
    
    local found_branches=0
    
    # Проходим по всем веткам
    while read -r branch; do
        # Пропускаем пустые строки
        if [ -z "$branch" ]; then
            continue
        fi
        
        # Для удаленных веток убираем origin/ если нужно
        display_branch=$branch
        if [ "$branch_type" == "REMOTE" ]; then
            display_branch=$(echo "$branch" | sed 's/^origin\///')
        fi
        
        # Формируем команду git log с фильтрами
        local log_cmd="git log -1 --pretty=format:\"%h|%an|%ae|%ad|%s\" --date=short \"$branch\""
        
        if [ -n "$target_date" ]; then
            log_cmd="$log_cmd --since=\"$target_date 00:00:00\" --until=\"$target_date 23:59:59\""
        fi
        
        if [ -n "$user_email" ]; then
            log_cmd="$log_cmd --author=\"$user_email\""
        fi
        
        # Получаем информацию о коммите
        commit_info=$(eval "$log_cmd" 2>/dev/null)
        
        if [ -n "$commit_info" ]; then
            IFS='|' read -r commit_hash author author_email commit_date subject <<< "$commit_info"
            
            echo "Branch: $display_branch"
            echo "  Last Commit: $commit_hash"
            echo "  Author:      $author ($author_email)"
            echo "  Date:        $commit_date"
            echo "  Message:     $subject"
            echo "----------------------------------------"
            found_branches=$((found_branches + 1))
        fi
    done <<< "$branches"
    
    if [ $found_branches -eq 0 ]; then
        echo "No branches found matching the criteria"
        if [ -n "$user_email" ]; then
            echo "User: $user_email"
        fi
        if [ -n "$target_date" ]; then
            echo "Date: $target_date"
        fi
        echo "----------------------------------------"
    fi
}

# Основная логика скрипта
main() {
    local show_local=true
    local show_remote=true
    local target_date=""
    local user_email=""
    
    # Получаем email текущего пользователя по умолчанию
    local current_user=$(get_current_user_email)
    
    # Если нет аргументов, показываем справку
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    # Парсим аргументы
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --date)
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    target_date="$2"
                    shift 2
                else
                    echo "Error: --date requires a date parameter"
                    exit 1
                fi
                ;;
            --email)
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    user_email="$2"
                    shift 2
                else
                    echo "Error: --email requires an email parameter"
                    exit 1
                fi
                ;;
            --all)
                show_local=true
                show_remote=true
                shift
                ;;
            --local)
                show_local=true
                show_remote=false
                shift
                ;;
            --remote)
                show_local=false
                show_remote=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Если email не указан, используем текущего пользователя
    if [ -z "$user_email" ] && [ -n "$current_user" ]; then
        user_email="$current_user"
        echo "Using current user: $user_email"
        echo ""
    elif [ -z "$user_email" ]; then
        echo "Warning: No user email specified and cannot detect current user"
        echo "Please use --email parameter or set git user.email"
        echo ""
    fi
    
    # Проверяем, что мы в git репозитории
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: This is not a git repository"
        exit 1
    fi
    
    # Получаем информацию о ветках
    if [ "$show_local" = true ]; then
        get_branch_info "LOCAL" "$target_date" "$user_email"
    fi
    
    if [ "$show_remote" = true ]; then
        get_branch_info "REMOTE" "$target_date" "$user_email"
    fi
}

# Запускаем основную функцию
main "$@"
```

## Примеры использования:

### По умолчанию (текущий пользователь):
```bash
./git-branch-info.sh --local
# Автоматически использует email из git config user.email
```

### С указанием конкретного пользователя:
```bash
./git-branch-info.sh --email john@example.com
./git-branch-info.sh --local --email jane@example.com
```

### Комбинированные фильтры:
```bash
./git-branch-info.sh --email john@example.com --date 2024-01-15
./git-branch-info.sh --remote --email jane@example.com --date 2024-01-10
```

### Все ветки текущего пользователя:
```bash
./git-branch-info.sh --all
```

## Ключевые изменения:

1. **Добавлен параметр `--email`**: для фильтрации по email пользователя
2. **Автоматическое определение текущего пользователя**: функция `get_current_user_email()`
3. **Улучшенный вывод**: показывает фильтры (пользователь, дата)
4. **Расширенная информация о коммите**: теперь включает email автора
5. **Сообщения об отсутствии результатов**: если ветки не найдены по критериям

Теперь скрипт по умолчанию работает с текущим пользователем, но позволяет фильтровать по любому пользователю с помощью параметра `--email`.

## Prompt v4 :
_Отлично. Теперь разделяем разным цветом удаленные и локальные ветки. Помечаем ветки которые были уже замерджены в основную ветку зелёной меткой "merged"._

Отлично! Добавим цветовое выделение и метки для мерженых веток. Вот обновленная версия скрипта:

## Обновленный скрипт `git-branch-info.sh`

```bash
#!/bin/bash

# Цветовые коды
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Функция для отображения справки
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help          Show this help message"
    echo "  --date DATE     Show branches information for specific date (format: YYYY-MM-DD)"
    echo "  --email EMAIL   Filter by specific user email (default: current user)"
    echo "  --all           Show both local and remote branches (default)"
    echo "  --local         Show only local branches"
    echo "  --remote        Show only remote branches"
    echo ""
    echo "Examples:"
    echo "  $0 --help"
    echo "  $0 --date 2024-01-15"
    echo "  $0 --email john@example.com"
    echo "  $0 --local --email jane@example.com --date 2024-01-10"
    echo "  $0              # Shows current user's branches"
}

# Функция для получения текущего пользователя Git
get_current_user_email() {
    git config user.email 2>/dev/null
}

# Функция для проверки, мержена ли ветка в основную
is_merged_to_main() {
    local branch=$1
    local main_branch="main"
    
    # Пробуем найти основную ветку (main или master)
    if git show-ref --verify --quiet refs/heads/main; then
        main_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    else
        return 1
    fi
    
    # Проверяем, мержена ли ветка в основную
    if git branch --contains "$branch" | grep -q "$main_branch"; then
        return 0
    else
        return 1
    fi
}

# Функция для получения информации о ветках
get_branch_info() {
    local branch_type=$1
    local target_date=$2
    local user_email=$3
    
    # Выбираем цвет в зависимости от типа ветки
    local branch_color=""
    if [ "$branch_type" == "LOCAL" ]; then
        branch_color=$BLUE
    else
        branch_color=$MAGENTA
    fi
    
    echo -e "${branch_color}=== $branch_type BRANCHES ===${NC}"
    if [ -n "$user_email" ]; then
        echo -e "${YELLOW}Filtered by user: $user_email${NC}"
    fi
    if [ -n "$target_date" ]; then
        echo -e "${YELLOW}Filtered by date: $target_date${NC}"
    fi
    echo ""
    
    # Получаем список веток в зависимости от типа
    if [ "$branch_type" == "LOCAL" ]; then
        branches=$(git branch --format='%(refname:short)')
    else
        branches=$(git branch -r --format='%(refname:short)' | grep -v 'HEAD')
    fi
    
    # Если нет веток, выводим сообщение
    if [ -z "$branches" ]; then
        echo -e "${YELLOW}No $branch_type branches found${NC}"
        echo "----------------------------------------"
        return
    fi
    
    local found_branches=0
    
    # Проходим по всем веткам
    while read -r branch; do
        # Пропускаем пустые строки
        if [ -z "$branch" ]; then
            continue
        fi
        
        # Для удаленных веток убираем origin/ если нужно
        display_branch=$branch
        if [ "$branch_type" == "REMOTE" ]; then
            display_branch=$(echo "$branch" | sed 's/^origin\///')
        fi
        
        # Формируем команду git log с фильтрами
        local log_cmd="git log -1 --pretty=format:\"%h|%an|%ae|%ad|%s\" --date=short \"$branch\""
        
        if [ -n "$target_date" ]; then
            log_cmd="$log_cmd --since=\"$target_date 00:00:00\" --until=\"$target_date 23:59:59\""
        fi
        
        if [ -n "$user_email" ]; then
            log_cmd="$log_cmd --author=\"$user_email\""
        fi
        
        # Получаем информацию о коммите
        commit_info=$(eval "$log_cmd" 2>/dev/null)
        
        if [ -n "$commit_info" ]; then
            IFS='|' read -r commit_hash author author_email commit_date subject <<< "$commit_info"
            
            # Проверяем, мержена ли ветка
            local merged_status=""
            if [ "$branch_type" == "LOCAL" ] && is_merged_to_main "$branch"; then
                merged_status="${GREEN} [MERGED]${NC}"
            fi
            
            # Выводим информацию о ветке с цветом
            echo -e "${branch_color}Branch: $display_branch${merged_status}${NC}"
            echo -e "  Last Commit: ${CYAN}$commit_hash${NC}"
            echo -e "  Author:      ${GREEN}$author${NC} (${YELLOW}$author_email${NC})"
            echo -e "  Date:        ${YELLOW}$commit_date${NC}"
            echo -e "  Message:     ${NC}$subject"
            echo "----------------------------------------"
            found_branches=$((found_branches + 1))
        fi
    done <<< "$branches"
    
    if [ $found_branches -eq 0 ]; then
        echo -e "${YELLOW}No branches found matching the criteria${NC}"
        if [ -n "$user_email" ]; then
            echo -e "${YELLOW}User: $user_email${NC}"
        fi
        if [ -n "$target_date" ]; then
            echo -e "${YELLOW}Date: $target_date${NC}"
        fi
        echo "----------------------------------------"
    fi
}

# Основная логика скрипта
main() {
    local show_local=true
    local show_remote=true
    local target_date=""
    local user_email=""
    
    # Получаем email текущего пользователя по умолчанию
    local current_user=$(get_current_user_email)
    
    # Если нет аргументов, показываем справку
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    # Парсим аргументы
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --date)
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    target_date="$2"
                    shift 2
                else
                    echo "Error: --date requires a date parameter"
                    exit 1
                fi
                ;;
            --email)
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    user_email="$2"
                    shift 2
                else
                    echo "Error: --email requires an email parameter"
                    exit 1
                fi
                ;;
            --all)
                show_local=true
                show_remote=true
                shift
                ;;
            --local)
                show_local=true
                show_remote=false
                shift
                ;;
            --remote)
                show_local=false
                show_remote=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Если email не указан, используем текущего пользователя
    if [ -z "$user_email" ] && [ -n "$current_user" ]; then
        user_email="$current_user"
        echo -e "${GREEN}Using current user: $user_email${NC}"
        echo ""
    elif [ -z "$user_email" ]; then
        echo -e "${YELLOW}Warning: No user email specified and cannot detect current user${NC}"
        echo -e "${YELLOW}Please use --email parameter or set git user.email${NC}"
        echo ""
    fi
    
    # Проверяем, что мы в git репозитории
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: This is not a git repository${NC}"
        exit 1
    fi
    
    # Получаем информацию о ветках
    if [ "$show_local" = true ]; then
        get_branch_info "LOCAL" "$target_date" "$user_email"
    fi
    
    if [ "$show_remote" = true ]; then
        get_branch_info "REMOTE" "$target_date" "$user_email"
    fi
}

# Запускаем основную функцию
main "$@"
```

## Пример вывода:

```
[0;34m=== LOCAL BRANCHES ===[0m
[0;32mUsing current user: john@example.com[0m

[0;34mBranch: main[0m
  Last Commit: [0;36ma1b2c3d[0m
  Author:      [0;32mJohn Doe[0m ([1;33mjohn@example.com[0m)
  Date:        [1;33m2024-01-15[0m
  Message:     Fix security issue
----------------------------------------
[0;34mBranch: feature/login[0;32m [MERGED][0m
  Last Commit: [0;36me4f5g6h[0m
  Author:      [0;32mJohn Doe[0m ([1;33mjohn@example.com[0m)
  Date:        [1;33m2024-01-14[0m
  Message:     Add login functionality
----------------------------------------

[0;35m=== REMOTE BRANCHES ===[0m
[0;32mUsing current user: john@example.com[0m

[0;35mBranch: origin/main[0m
  Last Commit: [0;36ma1b2c3d[0m
  Author:      [0;32mJohn Doe[0m ([1;33mjohn@example.com[0m)
  Date:        [1;33m2024-01-15[0m
  Message:     Fix security issue
----------------------------------------
```

## Ключевые изменения:

1. **Цветовое выделение**:
   - 🔵 **Синий** - локальные ветки
   - 🟣 **Фиолетовый** - удаленные ветки
   - 🟢 **Зеленый** - метка "MERGED" и авторы
   - 🟡 **Желтый** - фильтры, даты, email
   - 🔵 **Голубой** - хэши коммитов

2. **Метка "MERGED"**:
   - Зеленая метка `[MERGED]` для веток, которые уже вмержены в основную ветку
   - Автоматически определяет основную ветку (main или master)
   - Работает только для локальных веток

3. **Улучшенный визуальный вывод**:
   - Цветные заголовки разделов
   - Цветное выделение ключевой информации
   - Сообщения об ошибках выделены красным

Теперь скрипт предоставляет наглядную визуальную информацию о статусе веток с цветовым кодированием!

## Prompt 5:
_Ошибка. Не в какую ветку были замерджены изменения а ИЗ которой. Отмечать ветку из которой все изменения были перенесены_

Понял! Нужно отмечать ветки, ИЗ которых все изменения были перенесены в основную ветку. Исправляем логику:

## Исправленный скрипт `git-branch-info.sh`

```bash
#!/bin/bash

# Цветовые коды
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Функция для отображения справки
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help          Show this help message"
    echo "  --date DATE     Show branches information for specific date (format: YYYY-MM-DD)"
    echo "  --email EMAIL   Filter by specific user email (default: current user)"
    echo "  --all           Show both local and remote branches (default)"
    echo "  --local         Show only local branches"
    echo "  --remote        Show only remote branches"
    echo ""
    echo "Examples:"
    echo "  $0 --help"
    echo "  $0 --date 2024-01-15"
    echo "  $0 --email john@example.com"
    echo "  $0 --local --email jane@example.com --date 2024-01-10"
    echo "  $0              # Shows current user's branches"
}

# Функция для получения текущего пользователя Git
get_current_user_email() {
    git config user.email 2>/dev/null
}

# Функция для проверки, полностью ли мержена ветка в основную
is_fully_merged_from() {
    local branch=$1
    local main_branch="main"
    
    # Пробуем найти основную ветку (main или master)
    if git show-ref --verify --quiet refs/heads/main; then
        main_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    else
        return 1
    fi
    
    # Пропускаем саму основную ветку
    if [ "$branch" == "$main_branch" ]; then
        return 1
    fi
    
    # Проверяем, содержит ли основная ветка все коммиты из этой ветки
    # Это означает, что ветка полностью вмержена в основную
    if git merge-base --is-ancestor "$branch" "$main_branch" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Функция для получения информации о ветках
get_branch_info() {
    local branch_type=$1
    local target_date=$2
    local user_email=$3
    
    # Выбираем цвет в зависимости от типа ветки
    local branch_color=""
    if [ "$branch_type" == "LOCAL" ]; then
        branch_color=$BLUE
    else
        branch_color=$MAGENTA
    fi
    
    echo -e "${branch_color}=== $branch_type BRANCHES ===${NC}"
    if [ -n "$user_email" ]; then
        echo -e "${YELLOW}Filtered by user: $user_email${NC}"
    fi
    if [ -n "$target_date" ]; then
        echo -e "${YELLOW}Filtered by date: $target_date${NC}"
    fi
    echo ""
    
    # Получаем список веток в зависимости от типа
    if [ "$branch_type" == "LOCAL" ]; then
        branches=$(git branch --format='%(refname:short)')
    else
        branches=$(git branch -r --format='%(refname:short)' | grep -v 'HEAD')
    fi
    
    # Если нет веток, выводим сообщение
    if [ -z "$branches" ]; then
        echo -e "${YELLOW}No $branch_type branches found${NC}"
        echo "----------------------------------------"
        return
    fi
    
    local found_branches=0
    
    # Проходим по всем веткам
    while read -r branch; do
        # Пропускаем пустые строки
        if [ -z "$branch" ]; then
            continue
        fi
        
        # Для удаленных веток убираем origin/ если нужно
        display_branch=$branch
        remote_branch_name=$branch
        if [ "$branch_type" == "REMOTE" ]; then
            display_branch=$(echo "$branch" | sed 's/^origin\///')
            remote_branch_name=$display_branch
        fi
        
        # Формируем команду git log с фильтрами
        local log_cmd="git log -1 --pretty=format:\"%h|%an|%ae|%ad|%s\" --date=short \"$branch\""
        
        if [ -n "$target_date" ]; then
            log_cmd="$log_cmd --since=\"$target_date 00:00:00\" --until=\"$target_date 23:59:59\""
        fi
        
        if [ -n "$user_email" ]; then
            log_cmd="$log_cmd --author=\"$user_email\""
        fi
        
        # Получаем информацию о коммите
        commit_info=$(eval "$log_cmd" 2>/dev/null)
        
        if [ -n "$commit_info" ]; then
            IFS='|' read -r commit_hash author author_email commit_date subject <<< "$commit_info"
            
            # Проверяем, полностью ли мержена ветка В основную
            local merged_status=""
            if [ "$branch_type" == "LOCAL" ] && is_fully_merged_from "$branch"; then
                merged_status="${GREEN} [FULLY MERGED]${NC}"
            elif [ "$branch_type" == "REMOTE" ]; then
                # Для удаленных веток проверяем соответствующую локальную ветку
                if git show-ref --verify --quiet "refs/heads/$remote_branch_name" 2>/dev/null; then
                    if is_fully_merged_from "$remote_branch_name"; then
                        merged_status="${GREEN} [FULLY MERGED]${NC}"
                    fi
                fi
            fi
            
            # Выводим информацию о ветке с цветом
            echo -e "${branch_color}Branch: $display_branch${merged_status}${NC}"
            echo -e "  Last Commit: ${CYAN}$commit_hash${NC}"
            echo -e "  Author:      ${GREEN}$author${NC} (${YELLOW}$author_email${NC})"
            echo -e "  Date:        ${YELLOW}$commit_date${NC}"
            echo -e "  Message:     ${NC}$subject"
            echo "----------------------------------------"
            found_branches=$((found_branches + 1))
        fi
    done <<< "$branches"
    
    if [ $found_branches -eq 0 ]; then
        echo -e "${YELLOW}No branches found matching the criteria${NC}"
        if [ -n "$user_email" ]; then
            echo -e "${YELLOW}User: $user_email${NC}"
        fi
        if [ -n "$target_date" ]; then
            echo -e "${YELLOW}Date: $target_date${NC}"
        fi
        echo "----------------------------------------"
    fi
}

# Основная логика скрипта
main() {
    local show_local=true
    local show_remote=true
    local target_date=""
    local user_email=""
    
    # Получаем email текущего пользователя по умолчанию
    local current_user=$(get_current_user_email)
    
    # Если нет аргументов, показываем справку
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    # Парсим аргументы
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --date)
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    target_date="$2"
                    shift 2
                else
                    echo "Error: --date requires a date parameter"
                    exit 1
                fi
                ;;
            --email)
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    user_email="$2"
                    shift 2
                else
                    echo "Error: --email requires an email parameter"
                    exit 1
                fi
                ;;
            --all)
                show_local=true
                show_remote=true
                shift
                ;;
            --local)
                show_local=true
                show_remote=false
                shift
                ;;
            --remote)
                show_local=false
                show_remote=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Если email не указан, используем текущего пользователя
    if [ -z "$user_email" ] && [ -n "$current_user" ]; then
        user_email="$current_user"
        echo -e "${GREEN}Using current user: $user_email${NC}"
        echo ""
    elif [ -z "$user_email" ]; then
        echo -e "${YELLOW}Warning: No user email specified and cannot detect current user${NC}"
        echo -e "${YELLOW}Please use --email parameter or set git user.email${NC}"
        echo ""
    fi
    
    # Проверяем, что мы в git репозитории
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: This is not a git repository${NC}"
        exit 1
    fi
    
    # Получаем информацию о ветках
    if [ "$show_local" = true ]; then
        get_branch_info "LOCAL" "$target_date" "$user_email"
    fi
    
    if [ "$show_remote" = true ]; then
        get_branch_info "REMOTE" "$target_date" "$user_email"
    fi
}

# Запускаем основную функцию
main "$@"
```

## Ключевые изменения:

1. **Исправленная логика проверки мержа**:
   - Функция `is_fully_merged_from()` теперь использует `git merge-base --is-ancestor`
   - Это проверяет, является ли ветка предком основной ветки (т.е. все коммиты из ветки присутствуют в основной)

2. **Метка `[FULLY MERGED]`**:
   - Показывается для веток, ИЗ которых все изменения были перенесены в основную ветку
   - Работает как для локальных, так и для удаленных веток (через проверку соответствующих локальных веток)

3. **Исключение основной ветки**:
   - Основная ветка (main/master) не помечается как мерженая

4. **Улучшенная обработка удаленных веток**:
   - Для удаленных веток проверяется соответствующая локальная ветка
   - Если локальная ветка полностью вмержена, то и удаленная помечается соответствующим образом

Теперь скрипт правильно отмечает ветки, ИЗ которых все изменения были перенесены в основную ветку!

## Prompt 6:
_Ок. Теперь добавим возможность интерактивно удалить ветки для указанного пользователя. Только если пользователь находится на основной ветке `main/master` в противном случае сообщение о необходимости перейти на основную ветку_

Отлично! Добавим интерактивное удаление веток. Вот обновленная версия скрипта:

## Обновленный скрипт `git-branch-info.sh`

```bash
#!/bin/bash

# Цветовые коды
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Функция для отображения справки
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help          Show this help message"
    echo "  --date DATE     Show branches information for specific date (format: YYYY-MM-DD)"
    echo "  --email EMAIL   Filter by specific user email (default: current user)"
    echo "  --all           Show both local and remote branches (default)"
    echo "  --local         Show only local branches"
    echo "  --remote        Show only remote branches"
    echo "  --delete        Interactive deletion of fully merged branches"
    echo ""
    echo "Examples:"
    echo "  $0 --help"
    echo "  $0 --date 2024-01-15"
    echo "  $0 --email john@example.com --delete"
    echo "  $0 --local --email jane@example.com --date 2024-01-10"
    echo "  $0 --delete      # Interactive deletion for current user"
}

# Функция для получения текущего пользователя Git
get_current_user_email() {
    git config user.email 2>/dev/null
}

# Функция для получения основной ветки
get_main_branch() {
    if git show-ref --verify --quiet refs/heads/main; then
        echo "main"
    elif git show-ref --verify --quiet refs/heads/master; then
        echo "master"
    else
        echo ""
    fi
}

# Функция для проверки текущей ветки
is_on_main_branch() {
    local main_branch=$(get_main_branch)
    local current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    
    if [ "$current_branch" = "$main_branch" ]; then
        return 0
    else
        return 1
    fi
}

# Функция для проверки, полностью ли мержена ветка в основную
is_fully_merged_from() {
    local branch=$1
    local main_branch=$(get_main_branch)
    
    if [ -z "$main_branch" ]; then
        return 1
    fi
    
    # Пропускаем саму основную ветку
    if [ "$branch" == "$main_branch" ]; then
        return 1
    fi
    
    # Проверяем, содержит ли основная ветка все коммиты из этой ветки
    if git merge-base --is-ancestor "$branch" "$main_branch" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Функция для интерактивного удаления веток
interactive_delete() {
    local user_email=$1
    local main_branch=$(get_main_branch)
    
    if [ -z "$main_branch" ]; then
        echo -e "${RED}Error: Cannot determine main branch (main/master)${NC}"
        return 1
    fi
    
    # Проверяем, что находимся на основной ветке
    if ! is_on_main_branch; then
        local current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        echo -e "${RED}Error: You must be on the main branch ('$main_branch') to delete branches${NC}"
        echo -e "${YELLOW}Current branch: $current_branch${NC}"
        echo -e "${YELLOW}Please run: git checkout $main_branch${NC}"
        return 1
    fi
    
    echo -e "${GREEN}=== INTERACTIVE BRANCH DELETION ===${NC}"
    echo -e "${GREEN}User: $user_email${NC}"
    echo -e "${GREEN}Main branch: $main_branch${NC}"
    echo ""
    
    # Получаем все локальные ветки пользователя, которые полностью вмержены
    local branches_to_delete=$(git branch --format='%(refname:short)' | while read -r branch; do
        if [ "$branch" != "$main_branch" ] && is_fully_merged_from "$branch"; then
            # Проверяем, принадлежит ли ветка пользователю
            local author_email=$(git log -1 --pretty=format:"%ae" "$branch" 2>/dev/null)
            if [ "$author_email" = "$user_email" ]; then
                echo "$branch"
            fi
        fi
    done)
    
    if [ -z "$branches_to_delete" ]; then
        echo -e "${YELLOW}No fully merged branches found for user: $user_email${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Found fully merged branches for deletion:${NC}"
    echo -e "${CYAN}$branches_to_delete${NC}"
    echo ""
    
    # Запрашиваем подтверждение
    read -p "Do you want to delete these branches? (y/N): " confirm
    case "$confirm" in
        [yY][eE][sS]|[yY])
            echo -e "${GREEN}Starting deletion process...${NC}"
            echo ""
            
            local deleted_count=0
            local error_count=0
            
            while read -r branch; do
                if [ -n "$branch" ]; then
                    echo -e "${BLUE}Deleting branch: $branch${NC}"
                    if git branch -D "$branch" 2>/dev/null; then
                        echo -e "${GREEN}✓ Successfully deleted: $branch${NC}"
                        deleted_count=$((deleted_count + 1))
                    else
                        echo -e "${RED}✗ Failed to delete: $branch${NC}"
                        error_count=$((error_count + 1))
                    fi
                    echo ""
                fi
            done <<< "$branches_to_delete"
            
            echo -e "${GREEN}Deletion completed!${NC}"
            echo -e "${GREEN}Successfully deleted: $deleted_count branches${NC}"
            if [ $error_count -gt 0 ]; then
                echo -e "${RED}Failed to delete: $error_count branches${NC}"
            fi
            ;;
        *)
            echo -e "${YELLOW}Deletion cancelled${NC}"
            ;;
    esac
}

# Функция для получения информации о ветках
get_branch_info() {
    local branch_type=$1
    local target_date=$2
    local user_email=$3
    local delete_mode=$4
    
    # Выбираем цвет в зависимости от типа ветки
    local branch_color=""
    if [ "$branch_type" == "LOCAL" ]; then
        branch_color=$BLUE
    else
        branch_color=$MAGENTA
    fi
    
    if [ "$delete_mode" != "true" ]; then
        echo -e "${branch_color}=== $branch_type BRANCHES ===${NC}"
        if [ -n "$user_email" ]; then
            echo -e "${YELLOW}Filtered by user: $user_email${NC}"
        fi
        if [ -n "$target_date" ]; then
            echo -e "${YELLOW}Filtered by date: $target_date${NC}"
        fi
        echo ""
    fi
    
    # Получаем список веток в зависимости от типа
    if [ "$branch_type" == "LOCAL" ]; then
        branches=$(git branch --format='%(refname:short)')
    else
        branches=$(git branch -r --format='%(refname:short)' | grep -v 'HEAD')
    fi
    
    # Если нет веток, выводим сообщение
    if [ -z "$branches" ]; then
        if [ "$delete_mode" != "true" ]; then
            echo -e "${YELLOW}No $branch_type branches found${NC}"
            echo "----------------------------------------"
        fi
        return
    fi
    
    local found_branches=0
    
    # Проходим по всем веткам
    while read -r branch; do
        # Пропускаем пустые строки
        if [ -z "$branch" ]; then
            continue
        fi
        
        # Для удаленных веток убираем origin/ если нужно
        display_branch=$branch
        remote_branch_name=$branch
        if [ "$branch_type" == "REMOTE" ]; then
            display_branch=$(echo "$branch" | sed 's/^origin\///')
            remote_branch_name=$display_branch
        fi
        
        # Формируем команду git log с фильтрами
        local log_cmd="git log -1 --pretty=format:\"%h|%an|%ae|%ad|%s\" --date=short \"$branch\""
        
        if [ -n "$target_date" ]; then
            log_cmd="$log_cmd --since=\"$target_date 00:00:00\" --until=\"$target_date 23:59:59\""
        fi
        
        if [ -n "$user_email" ]; then
            log_cmd="$log_cmd --author=\"$user_email\""
        fi
        
        # Получаем информацию о коммите
        commit_info=$(eval "$log_cmd" 2>/dev/null)
        
        if [ -n "$commit_info" ]; then
            IFS='|' read -r commit_hash author author_email commit_date subject <<< "$commit_info"
            
            # Проверяем, полностью ли мержена ветка В основную
            local merged_status=""
            if [ "$branch_type" == "LOCAL" ] && is_fully_merged_from "$branch"; then
                merged_status="${GREEN} [FULLY MERGED]${NC}"
            elif [ "$branch_type" == "REMOTE" ]; then
                # Для удаленных веток проверяем соответствующую локальную ветку
                if git show-ref --verify --quiet "refs/heads/$remote_branch_name" 2>/dev/null; then
                    if is_fully_merged_from "$remote_branch_name"; then
                        merged_status="${GREEN} [FULLY MERGED]${NC}"
                    fi
                fi
            fi
            
            if [ "$delete_mode" != "true" ]; then
                # Выводим информацию о ветке с цветом
                echo -e "${branch_color}Branch: $display_branch${merged_status}${NC}"
                echo -e "  Last Commit: ${CYAN}$commit_hash${NC}"
                echo -e "  Author:      ${GREEN}$author${NC} (${YELLOW}$author_email${NC})"
                echo -e "  Date:        ${YELLOW}$commit_date${NC}"
                echo -e "  Message:     ${NC}$subject"
                echo "----------------------------------------"
            fi
            found_branches=$((found_branches + 1))
        fi
    done <<< "$branches"
    
    if [ "$delete_mode" != "true" ] && [ $found_branches -eq 0 ]; then
        echo -e "${YELLOW}No branches found matching the criteria${NC}"
        if [ -n "$user_email" ]; then
            echo -e "${YELLOW}User: $user_email${NC}"
        fi
        if [ -n "$target_date" ]; then
            echo -e "${YELLOW}Date: $target_date${NC}"
        fi
        echo "----------------------------------------"
    fi
}

# Основная логика скрипта
main() {
    local show_local=true
    local show_remote=true
    local target_date=""
    local user_email=""
    local delete_mode=false
    
    # Получаем email текущего пользователя по умолчанию
    local current_user=$(get_current_user_email)
    
    # Если нет аргументов, показываем справку
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    # Парсим аргументы
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --date)
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    target_date="$2"
                    shift 2
                else
                    echo "Error: --date requires a date parameter"
                    exit 1
                fi
                ;;
            --email)
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    user_email="$2"
                    shift 2
                else
                    echo "Error: --email requires an email parameter"
                    exit 1
                fi
                ;;
            --all)
                show_local=true
                show_remote=true
                shift
                ;;
            --local)
                show_local=true
                show_remote=false
                shift
                ;;
            --remote)
                show_local=false
                show_remote=true
                shift
                ;;
            --delete)
                delete_mode=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Если email не указан, используем текущего пользователя
    if [ -z "$user_email" ] && [ -n "$current_user" ]; then
        user_email="$current_user"
        if [ "$delete_mode" != "true" ]; then
            echo -e "${GREEN}Using current user: $user_email${NC}"
            echo ""
        fi
    elif [ -z "$user_email" ]; then
        echo -e "${YELLOW}Warning: No user email specified and cannot detect current user${NC}"
        echo -e "${YELLOW}Please use --email parameter or set git user.email${NC}"
        echo ""
    fi
    
    # Проверяем, что мы в git репозитории
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: This is not a git repository${NC}"
        exit 1
    fi
    
    # Режим удаления
    if [ "$delete_mode" = true ]; then
        interactive_delete "$user_email"
        exit $?
    fi
    
    # Обычный режим просмотра
    if [ "$show_local" = true ]; then
        get_branch_info "LOCAL" "$target_date" "$user_email" "$delete_mode"
    fi
    
    if [ "$show_remote" = true ]; then
        get_branch_info "REMOTE" "$target_date" "$user_email" "$delete_mode"
    fi
}

# Запускаем основную функцию
main "$@"
```

## Примеры использования:

### Интерактивное удаление веток текущего пользователя:
```bash
./git-branch-info.sh --delete
```

### Удаление веток конкретного пользователя:
```bash
./git-branch-info.sh --email john@example.com --delete
```

### Просмотр + удаление:
```bash
# Сначала посмотреть ветки
./git-branch-info.sh --email john@example.com --local

# Затем удалить
./git-branch-info.sh --email john@example.com --delete
```

## Ключевые особенности:

1. **Параметр `--delete`**: включает режим интерактивного удаления
2. **Проверка основной ветки**: 
   - Скрипт проверяет, что пользователь находится на main/master
   - Если нет - показывает сообщение с инструкцией
3. **Безопасное удаление**: 
   - Удаляются только полностью вмерженные ветки
   - Только ветки указанного пользователя
   - Подтверждение перед удалением
4. **Подробный отчет**: 
   - Показывает какие ветки будут удалены
   - Отчет об успешных/неуспешных удалениях
5. **Цветовой вывод**: наглядное отображение процесса

Теперь скрипт безопасно удаляет ветки с проверкой условий!



