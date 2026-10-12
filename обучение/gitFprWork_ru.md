#

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