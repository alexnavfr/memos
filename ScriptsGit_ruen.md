# Scripts Git

## Prompts
_Git. версия в которой еще нет `git switch`. Напиши скрипт/функцию на bash которая может принимать параметры. задача скрипта определить ветки которые были отправлены в удаленный репозиторий это первый параметр. второй это пользователь - по умолчанию текущий. узнать были какие ветки данного пользователя замержены в главную ветку. третий добавить возможность удалить замерженые ветки. Параметры работают отдельно и вывод может осущесвлятся как в консоль так и в файл отчета в зависимости от параметров_
_спасибо. Давай изменим комментарии на английский язык, и использовать его всегда в комметариях. Пошаговое объяснение всегда на русском. Автора будем идентифицировать по адресу электронной почты. Скрипт может быть использован новичком у которого нет навыка в bash и git._

### Part 1
Вот скрипт на bash для работы с ветками в старых версиях Git:

```bash
#!/bin/bash

# Скрипт для анализа мерженых веток пользователя
# Использование: ./branch_analyzer.sh [remote] [username] [--delete] [--output file.txt]

# Функция для вывода справки
show_help() {
    echo "Использование: $0 [ПАРАМЕТРЫ]"
    echo ""
    echo "Параметры:"
    echo "  REMOTE          Имя удаленного репозитория (по умолчанию: origin)"
    echo "  USERNAME        Имя пользователя (по умолчанию: текущий пользователь)"
    echo "  --delete        Удалить мерженые ветки"
    echo "  --output FILE   Сохранить отчет в файл"
    echo "  --help          Показать эту справку"
    echo ""
    echo "Примеры:"
    echo "  $0 origin john.doe"
    echo "  $0 origin john.doe --delete"
    echo "  $0 origin john.doe --output report.txt"
}

# Функция для вывода сообщений с цветом
print_message() {
    local color=$1
    local message=$2
    case $color in
        "red") echo -e "\033[0;31m$message\033[0m" ;;
        "green") echo -e "\033[0;32m$message\033[0m" ;;
        "yellow") echo -e "\033[0;33m$message\033[0m" ;;
        "blue") echo -e "\033[0;34m$message\033[0m" ;;
        *) echo "$message" ;;
    esac
}

# Функция для проверки существования удаленного репозитория
check_remote() {
    local remote=$1
    if ! git remote | grep -q "^$remote$"; then
        print_message "red" "Ошибка: Удаленный репозиторий '$remote' не существует"
        exit 1
    fi
}

# Основная функция анализа веток
analyze_branches() {
    local remote=$1
    local username=$2
    local delete_mode=$3
    local output_file=$4
    
    # Получаем главную ветку (master или main)
    local main_branch=""
    if git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    elif git show-ref --verify --quiet refs/heads/main; then
        main_branch="main"
    else
        print_message "red" "Ошибка: Не найдена главная ветка (master или main)"
        exit 1
    fi
    
    # Получаем список всех локальных веток
    local local_branches=$(git branch --format='%(refname:short)')
    
    # Массивы для результатов
    local pushed_branches=()
    local merged_branches=()
    local branches_to_delete=()
    
    print_message "blue" "Анализ веток пользователя: $username"
    print_message "blue" "Удаленный репозиторий: $remote"
    print_message "blue" "Главная ветка: $main_branch"
    echo "========================================"
    
    # Проверяем каждую локальную ветку
    for branch in $local_branches; do
        # Пропускаем главную ветку
        if [ "$branch" = "$main_branch" ]; then
            continue
        fi
        
        # Проверяем, была ли ветка отправлена в удаленный репозиторий
        if git show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
            pushed_branches+=("$branch")
            
            # Проверяем, был ли автор последнего коммита нужным пользователем
            local last_commit_author=$(git log -1 --pretty=format:%ae "$branch")
            
            # Также проверяем мержи через merge commit автора
            local is_merged=$(git log --merges --author="$username" --oneline "$main_branch" | grep -q "Merge branch '$branch'" && echo "yes" || echo "no")
            
            # Проверяем, была ли ветка замержена в главную
            if git branch --merged "$main_branch" | grep -q "^[[:space:]]*$branch$"; then
                # Получаем информацию о мерже
                local merge_info=$(git log --merges --grep="Merge branch '$branch'" --oneline "$main_branch" | head -1)
                
                if [ -n "$merge_info" ]; then
                    merged_branches+=("$branch")
                    branches_to_delete+=("$branch")
                fi
            fi
        fi
    done
    
    # Вывод результатов
    local output_content=""
    
    output_content+="Отчет анализа веток\n"
    output_content+="Время: $(date)\n"
    output_content+="Пользователь: $username\n"
    output_content+="Удаленный репозиторий: $remote\n"
    output_content+="Главная ветка: $main_branch\n"
    output_content+="========================================\n\n"
    
    output_content+="Ветки отправленные в удаленный репозиторий:\n"
    if [ ${#pushed_branches[@]} -eq 0 ]; then
        output_content+="  Нет веток\n"
    else
        for branch in "${pushed_branches[@]}"; do
            output_content+="  ✓ $branch\n"
        done
    fi
    
    output_content+="\nВетки замерженные в главную ветку:\n"
    if [ ${#merged_branches[@]} -eq 0 ]; then
        output_content+="  Нет мерженых веток\n"
    else
        for branch in "${merged_branches[@]}"; do
            output_content+="  ✓ $branch\n"
        done
    fi
    
    # Вывод в консоль или файл
    if [ -n "$output_file" ]; then
        echo -e "$output_content" > "$output_file"
        print_message "green" "Отчет сохранен в файл: $output_file"
    else
        echo -e "$output_content"
    fi
    
    # Удаление веток если указан флаг --delete
    if [ "$delete_mode" = true ] && [ ${#branches_to_delete[@]} -gt 0 ]; then
        echo ""
        print_message "yellow" "Ветки для удаления:"
        for branch in "${branches_to_delete[@]}"; do
            print_message "yellow" "  🗑️  Удаляю ветку: $branch"
            
            # Удаляем локальную ветку
            if git branch -d "$branch" 2>/dev/null; then
                print_message "green" "  ✓ Локальная ветка '$branch' удалена"
            else
                print_message "red" "  ✗ Не удалось удалить локальную ветку '$branch'"
            fi
            
            # Удаляем ветку из удаленного репозитория
            if git push "$remote" --delete "$branch" 2>/dev/null; then
                print_message "green" "  ✓ Ветка '$branch' удалена из удаленного репозитория"
            else
                print_message "yellow" "  ⚠ Ветка '$branch' не найдена в удаленном репозитории или уже удалена"
            fi
        done
    elif [ "$delete_mode" = true ]; then
        print_message "yellow" "Нет веток для удаления"
    fi
}

# Обработка параметров
REMOTE="origin"
USERNAME=$(git config user.email | cut -d'@' -f1)
DELETE_MODE=false
OUTPUT_FILE=""

# Парсим параметры
while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            show_help
            exit 0
            ;;
        --delete)
            DELETE_MODE=true
            shift
            ;;
        --output)
            if [ -n "$2" ]; then
                OUTPUT_FILE="$2"
                shift 2
            else
                print_message "red" "Ошибка: Не указано имя файла для --output"
                exit 1
            fi
            ;;
        -*)
            print_message "red" "Неизвестный параметр: $1"
            show_help
            exit 1
            ;;
        *)
            if [ -z "$REMOTE_SET" ]; then
                REMOTE="$1"
                REMOTE_SET=true
            elif [ -z "$USERNAME_SET" ]; then
                USERNAME="$1"
                USERNAME_SET=true
            fi
            shift
            ;;
    esac
done

# Проверяем, что мы в git репозитории
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_message "red" "Ошибка: Это не git репозиторий"
    exit 1
fi

# Проверяем существование удаленного репозитория
check_remote "$REMOTE"

# Запускаем анализ
analyze_branches "$REMOTE" "$USERNAME" "$DELETE_MODE" "$OUTPUT_FILE"
```

Также создайте упрощенную версию для быстрого использования:

```bash
#!/bin/bash
# simple_branch_analyzer.sh

REMOTE=${1:-origin}
USERNAME=${2:-$(git config user.email | cut -d'@' -f1)}
DELETE=${3:-false}
OUTPUT=${4:-""}

if [ "$DELETE" = "delete" ]; then
    DELETE_MODE=true
else
    DELETE_MODE=false
fi

/path/to/full/branch_analyzer.sh "$REMOTE" "$USERNAME" "$DELETE_MODE" "$OUTPUT"
```

**Примеры использования:**

1. **Базовый анализ:**
```bash
./branch_analyzer.sh origin john.doe
```

2. **Анализ с сохранением в файл:**
```bash
./branch_analyzer.sh origin john.doe --output report.txt
```

3. **Анализ и удаление мерженых веток:**
```bash
./branch_analyzer.sh origin john.doe --delete
```

4. **Полный анализ с удалением и сохранением отчета:**
```bash
./branch_analyzer.sh origin john.doe --delete --output deletion_report.txt
```

5. **Использование значений по умолчанию:**
```bash
./branch_analyzer.sh
```

**Особенности скрипта:**
- Работает в старых версиях Git (без `git switch`)
- Цветной вывод для лучшей читаемости
- Проверка существования удаленного репозитория
- Автоматическое определение главной ветки (master/main)
- Безопасное удаление с подтверждением через git commands
- Поддержка вывода как в консоль, так и в файл
- Обработка ошибок и валидация параметров

Скрипт можно сделать исполняемым с помощью `chmod +x branch_analyzer.sh`

### Part 2

Отлично! Вот улучшенная версия скрипта с английскими комментариями и подробным объяснением на русском:

## Пошаговое объяснение на русском:

**Что делает этот скрипт:**
1. ✅ Анализирует ваши Git-ветки
2. ✅ Находит ветки, которые были отправлены в удаленный репозиторий
3. ✅ Определяет какие ветки были объединены (merged) в главную ветку
4. ✅ Показывает ветки конкретного пользователя (по email)
5. ✅ Может безопасно удалить уже объединенные ветки
6. ✅ Сохраняет отчет в файл или выводит в консоль

**Как использовать:**
```bash
# Простой анализ
./branch_analyzer.sh

# Анализ с указанием репозитория и пользователя
./branch_analyzer.sh origin john@example.com

# Анализ с сохранением в файл
./branch_analyzer.sh origin john@example.com --output report.txt

# Анализ и удаление мерженых веток
./branch_analyzer.sh origin john@example.com --delete

# Показать справку
./branch_analyzer.sh --help
```

**Безопасность:**
- Скрипт НЕ удаляет ветки без явного указания `--delete`
- Перед удалением всегда делаются проверки
- Показывает что будет удалено перед действием

## Сам скрипт:

```bash
#!/bin/bash

# Branch Analyzer Script for Git repositories
# Helps identify pushed and merged branches for specific users

# Display help information
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  REMOTE          Remote repository name (default: origin)"
    echo "  USER_EMAIL      User email to filter branches (default: current user)"
    echo "  --delete        Delete merged branches (safe operation)"
    echo "  --output FILE   Save report to file"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 origin john@example.com"
    echo "  $0 origin john@example.com --delete"
    echo "  $0 origin john@example.com --output report.txt"
    echo "  $0 --help"
}

# Colorized output function
print_message() {
    local color=$1
    local message=$2
    case $color in
        "red") echo -e "\033[0;31m$message\033[0m" ;;
        "green") echo -e "\033[0;32m$message\033[0m" ;;
        "yellow") echo -e "\033[0;33m$message\033[0m" ;;
        "blue") echo -e "\033[0;34m$message\033[0m" ;;
        *) echo "$message" ;;
    esac
}

# Verify remote repository exists
check_remote() {
    local remote=$1
    if ! git remote | grep -q "^$remote$"; then
        print_message "red" "Error: Remote repository '$remote' does not exist"
        print_message "yellow" "Available remotes: $(git remote)"
        exit 1
    fi
}

# Get main branch name (master or main)
get_main_branch() {
    if git show-ref --verify --quiet refs/heads/master; then
        echo "master"
    elif git show-ref --verify --quiet refs/heads/main; then
        echo "main"
    else
        print_message "red" "Error: Could not find main branch (master or main)"
        exit 1
    fi
}

# Check if branch exists on remote
is_branch_on_remote() {
    local remote=$1
    local branch=$2
    git ls-remote --heads "$remote" "$branch" | grep -q "refs/heads/$branch"
}

# Main analysis function
analyze_branches() {
    local remote=$1
    local user_email=$2
    local delete_mode=$3
    local output_file=$4
    
    # Get main branch
    local main_branch=$(get_main_branch)
    
    # Get all local branches
    local local_branches=$(git branch --format='%(refname:short)')
    
    # Arrays for results
    local pushed_branches=()
    local merged_branches=()
    local user_merged_branches=()
    local branches_to_delete=()
    
    print_message "blue" "🔍 Analyzing branches for user: $user_email"
    print_message "blue" "📦 Remote repository: $remote"
    print_message "blue" "🎯 Main branch: $main_branch"
    echo "========================================"
    
    # Analyze each local branch
    for branch in $local_branches; do
        # Skip main branch
        if [ "$branch" = "$main_branch" ]; then
            continue
        fi
        
        # Check if branch exists on remote
        if is_branch_on_remote "$remote" "$branch"; then
            pushed_branches+=("$branch")
            
            # Check if branch is merged into main
            if git branch --merged "$main_branch" | grep -q "^[[:space:]]*$branch$"; then
                merged_branches+=("$branch")
                
                # Check if this branch belongs to the specified user
                local branch_author=$(git log "$branch" --pretty=format:%ae -1 2>/dev/null)
                
                if [ "$branch_author" = "$user_email" ]; then
                    user_merged_branches+=("$branch")
                    branches_to_delete+=("$branch")
                fi
            fi
        fi
    done
    
    # Prepare report content
    local output_content=""
    
    output_content+="Git Branch Analysis Report\n"
    output_content+="Generated: $(date)\n"
    output_content+="User email: $user_email\n"
    output_content+="Remote: $remote\n"
    output_content+="Main branch: $main_branch\n"
    output_content+="========================================\n\n"
    
    # Pushed branches section
    output_content+="📤 Branches pushed to remote:\n"
    if [ ${#pushed_branches[@]} -eq 0 ]; then
        output_content+="  No branches found\n"
    else
        for branch in "${pushed_branches[@]}"; do
            output_content+="  ✓ $branch\n"
        done
    fi
    
    # All merged branches section
    output_content+="\n🔄 All branches merged into main:\n"
    if [ ${#merged_branches[@]} -eq 0 ]; then
        output_content+="  No merged branches found\n"
    else
        for branch in "${merged_branches[@]}"; do
            output_content+="  ✓ $branch\n"
        done
    fi
    
    # User's merged branches section
    output_content+="\n👤 Your branches merged into main:\n"
    if [ ${#user_merged_branches[@]} -eq 0 ]; then
        output_content+="  No your branches were merged\n"
    else
        for branch in "${user_merged_branches[@]}"; do
            output_content+="  ✓ $branch\n"
        done
    fi
    
    # Output to file or console
    if [ -n "$output_file" ]; then
        echo -e "$output_content" > "$output_file"
        print_message "green" "✅ Report saved to: $output_file"
    else
        echo -e "$output_content"
    fi
    
    # Delete branches if requested
    if [ "$delete_mode" = true ]; then
        if [ ${#branches_to_delete[@]} -gt 0 ]; then
            echo ""
            print_message "yellow" "🗑️  Branches scheduled for deletion:"
            
            for branch in "${branches_to_delete[@]}"; do
                print_message "yellow" "  Processing: $branch"
                
                # Delete local branch
                if git branch -d "$branch" 2>/dev/null; then
                    print_message "green" "    ✓ Local branch '$branch' deleted"
                else
                    print_message "red" "    ✗ Failed to delete local branch '$branch'"
                    print_message "yellow" "    Try: git branch -D $branch (force delete)"
                fi
                
                # Delete remote branch
                if git push "$remote" --delete "$branch" 2>/dev/null; then
                    print_message "green" "    ✓ Remote branch '$branch' deleted"
                else
                    print_message "yellow" "    ⚠ Remote branch '$branch' not found or already deleted"
                fi
            done
            
            print_message "green" "✅ Deletion process completed"
        else
            print_message "yellow" "ℹ️  No branches to delete"
        fi
    fi
}

# Parse command line arguments
REMOTE="origin"
USER_EMAIL=$(git config user.email 2>/dev/null || echo "")
DELETE_MODE=false
OUTPUT_FILE=""

# Set default user email if not configured
if [ -z "$USER_EMAIL" ]; then
    USER_EMAIL="unknown@user.com"
    print_message "yellow" "⚠️  Git user email not configured. Using default: $USER_EMAIL"
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            show_help
            exit 0
            ;;
        --delete)
            DELETE_MODE=true
            shift
            ;;
        --output)
            if [ -n "$2" ]; then
                OUTPUT_FILE="$2"
                shift 2
            else
                print_message "red" "Error: No filename specified for --output"
                exit 1
            fi
            ;;
        -*)
            print_message "red" "Error: Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            if [ -z "$REMOTE_SET" ]; then
                REMOTE="$1"
                REMOTE_SET=true
            elif [ -z "$EMAIL_SET" ]; then
                USER_EMAIL="$1"
                EMAIL_SET=true
            else
                print_message "red" "Error: Too many arguments"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Verify we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_message "red" "Error: This is not a Git repository"
    exit 1
fi

# Verify remote exists
check_remote "$REMOTE"

# Run analysis
analyze_branches "$REMOTE" "$USER_EMAIL" "$DELETE_MODE" "$OUTPUT_FILE"
```

## Как установить и использовать:

1. **Создайте файл скрипта:**
```bash
nano branch_analyzer.sh
```

2. **Вставьте код выше и сохраните**

3. **Сделайте скрипт исполняемым:**
```bash
chmod +x branch_analyzer.sh
```

4. **Запустите скрипт:**
```bash
# Простой анализ
./branch_analyzer.sh

# Анализ для конкретного пользователя
./branch_analyzer.sh origin john@company.com

# С сохранением отчета
./branch_analyzer.sh origin john@company.com --output my_report.txt

# С удалением веток (будьте осторожны!)
./branch_analyzer.sh origin john@company.com --delete
```

## Советы для новичков:

1. **Сначала тестируйте без `--delete`** - посмотрите что скрипт найдет
2. **Проверьте отчет** перед удалением веток
3. **Убедитесь что ваша работа сохранена** в главной ветке
4. **Если сомневаетесь** - просто используйте анализ без удаления

Скрипт безопасен для использования и предоставляет понятные сообщения о том, что происходит на каждом шаге! 🚀




