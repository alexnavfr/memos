#!/bin/bash

# Git Branch Manager 2.19
# Комплексный инструмент для управления локальными и удаленными ветками

SCRIPT_NAME="git-branch-manager"
VERSION="2.19"

# Функция для вывода справки
show_help() {
    cat << EOF
Использование: $SCRIPT_NAME [ОПЦИИ] [КОМАНДА] [АРГУМЕНТЫ]

Git Branch Manager $VERSION - Комплексный инструмент для управления ветками Git

ОСНОВНЫЕ КОМАНДЫ:
  list, ls                    Список всех веток (локальных и удаленных)
  list-local, ll              Список только локальных веток
  list-remote, lr             Список только удаленных веток
  create, c <name> [from]     Создать новую ветку (опционально из другой ветки)
  switch, s <name>            Переключиться на ветку
  delete, d <name>            Удалить локальную ветку
  delete-remote, dr <name>    Удалить удаленную ветку
  cleanup                      Удалить все слитые ветки
  sync                         Синхронизировать с удаленным репозиторием
  info <name>                 Подробная информация о ветке
  merge-info <name>           Показать информацию о слиянии с веткой

ОПЦИИ:
  -h, --help                  Показать эту справку
  -v, --version               Показать версию
  -f, --force                 Принудительное выполнение (для опасных операций)
  -q, --quiet                 Тихий режим (минимальный вывод)
  -v, --verbose               Подробный вывод

ПРИМЕРЫ:
  $SCRIPT_NAME list
  $SCRIPT_NAME create feature/new-feature main
  $SCRIPT_NAME switch feature/new-feature
  $SCRIPT_NAME delete-remote feature/old-branch
  $SCRIPT_NAME cleanup --force

СОСТОЯНИЕ ВЫХОДА:
  0  Успешное выполнение
  1  Ошибка в параметрах
  2  Ошибка Git
  3  Ветка не найдена
  4  Конфликт операции

СМ. ТАКЖЕ:
  git-branch(1), git-checkout(1), git-merge(1)
EOF
}

# Функция для вывода версии
show_version() {
    echo "$SCRIPT_NAME версия $VERSION"
    echo "Совместимость: Git 2.19+"
    echo "Автор: Git Branch Manager Team"
}

# Функция для вывода ошибки
error() {
    echo "Ошибка: $1" >&2
}

# Функция для проверки Git репозитория
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Текущая директория не является Git репозиторием"
        exit 2
    fi
}

# Функция для проверки существования ветки
branch_exists() {
    local branch_name="$1"
    git show-ref --verify --quiet "refs/heads/$branch_name"
}

# Функция для проверки существования удаленной ветки
remote_branch_exists() {
    local branch_name="$1"
    git ls-remote --exit-code --heads origin "$branch_name" > /dev/null 2>&1
}

# Функция для вывода списка всех веток
list_all_branches() {
    check_git_repo
    
    echo "Локальные ветки:"
    git branch --format='%(color:blue)%(align:15)%(refname:short)%(end) %(color:reset)%(objectname:short) %(contents:subject)' | head -10
    
    echo -e "\nУдаленные ветки:"
    git branch -r --format='%(color:red)%(align:15)%(refname:short)%(end) %(color:reset)%(objectname:short) %(contents:subject)' | head -10
}

# Функция для вывода списка локальных веток
list_local_branches() {
    check_git_repo
    git branch --format='%(color:blue)%(align:15)%(refname:short)%(end) %(color:reset)%(objectname:short) %(contents:subject)'
}

# Функция для вывода списка удаленных веток
list_remote_branches() {
    check_git_repo
    git branch -r --format='%(color:red)%(align:15)%(refname:short)%(end) %(color:reset)%(objectname:short) %(contents:subject)'
}

# Основная логика обработки параметров
main() {
    # Если нет параметров, показать справку
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    # Обработка опций и команд
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        list|ls)
            list_all_branches
            ;;
        list-local|ll)
            list_local_branches
            ;;
        list-remote|lr)
            list_remote_branches
            ;;
        create|c)
            if [ -z "$2" ]; then
                error "Не указано имя ветки для создания"
                echo "Использование: $SCRIPT_NAME create <имя_ветки> [исходная_ветка]"
                exit 1
            fi
            echo "Создание ветки: $2"
            # Здесь будет логика создания ветки
            ;;
        switch|s)
            if [ -z "$2" ]; then
                error "Не указано имя ветки для переключения"
                echo "Использование: $SCRIPT_NAME switch <имя_ветки>"
                exit 1
            fi
            echo "Переключение на ветку: $2"
            # Здесь будет логика переключения ветки
            ;;
        delete|d)
            if [ -z "$2" ]; then
                error "Не указано имя ветки для удаления"
                echo "Использование: $SCRIPT_NAME delete <имя_ветки>"
                exit 1
            fi
            echo "Удаление ветки: $2"
            # Здесь будет логика удаления ветки
            ;;
        delete-remote|dr)
            if [ -z "$2" ]; then
                error "Не указано имя удаленной ветки для удаления"
                echo "Использование: $SCRIPT_NAME delete-remote <имя_ветки>"
                exit 1
            fi
            echo "Удаление удаленной ветки: $2"
            # Здесь будет логика удаления удаленной ветки
            ;;
        cleanup)
            echo "Очистка слитых веток..."
            # Здесь будет логика очистки
            ;;
        sync)
            echo "Синхронизация с удаленным репозиторием..."
            # Здесь будет логика синхронизации
            ;;
        info)
            if [ -z "$2" ]; then
                error "Не указано имя ветки для получения информации"
                echo "Использование: $SCRIPT_NAME info <имя_ветки>"
                exit 1
            fi
            echo "Информация о ветке: $2"
            # Здесь будет логика получения информации
            ;;
        merge-info)
            if [ -z "$2" ]; then
                error "Не указано имя ветки для проверки слияния"
                echo "Использование: $SCRIPT_NAME merge-info <имя_ветки>"
                exit 1
            fi
            echo "Информация о слиянии с веткой: $2"
            # Здесь будет логика проверки слияния
            ;;
        *)
            error "Неизвестная команда: $1"
            echo "Используйте '$SCRIPT_NAME --help' для просмотра справки"
            exit 1
            ;;
    esac
}

# Запуск основной функции с всеми аргументами
main "$@"
