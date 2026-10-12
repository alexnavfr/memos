# Создание скриптов о старых ветках гит

## Prompt:
_Git v2.19.1. Давай напишем скрипт который создаст список веток которые старше двух лет. Строка должна содержать следующую информацию: дата создания ветки и её автор, время последнего изменения и автор этого изменения. Вариантов предложить несколько - вывод результата на консоль, второй вариант вывод результата в файл, цветной вывод_

Вот скрипт на Bash, который создаст список веток старше двух лет с указанием даты создания, автора, времени последнего изменения и автора изменения. Я предоставлю несколько вариантов вывода:

### Вариант 1: Вывод на консоль с цветным оформлением
```bash
#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Получаем текущую дату в секундах с эпохи
current_date=$(date +%s)
# Вычисляем дату два года назад (в секундах)
two_years_ago=$((current_date - 2*365*24*60*60))

echo -e "${YELLOW}Ветки старше двух лет:${NC}"

# Получаем список всех веток и обрабатываем каждую
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:iso) %(committerdate:unix) %(authorname) %(committername)' refs/heads/ | while read branch last_commit_date last_commit_unix author last_committer; do
    if [ "$last_commit_unix" -lt "$two_years_ago" ]; then
        # Получаем дату создания ветки
        create_date=$(git log --reverse --pretty=format:"%ai" "$branch" | head -1)
        create_unix=$(git log --reverse --pretty=format:"%at" "$branch" | head -1)
        create_author=$(git log --reverse --pretty=format:"%an" "$branch" | head -1)
        
        echo -e "${RED}Ветка: ${BLUE}$branch${NC}"
        echo -e "${GREEN}Создана: ${NC}$create_date (${YELLOW}$create_author${NC})"
        echo -e "${GREEN}Последнее изменение: ${NC}$last_commit_date (${YELLOW}$last_committer${NC})"
        echo "--------------------------------------------------"
    fi
done
```

### Вариант 2: Вывод в файл (без цветов)
```bash
#!/bin/bash

output_file="old_branches_report.txt"
current_date=$(date +%s)
two_years_ago=$((current_date - 2*365*24*60*60))

echo "Ветки старше двух лет:" > "$output_file"

git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:iso) %(committerdate:unix) %(authorname) %(committername)' refs/heads/ | while read branch last_commit_date last_commit_unix author last_committer; do
    if [ "$last_commit_unix" -lt "$two_years_ago" ]; then
        create_date=$(git log --reverse --pretty=format:"%ai" "$branch" | head -1)
        create_author=$(git log --reverse --pretty=format:"%an" "$branch" | head -1)
        
        echo "Ветка: $branch" >> "$output_file"
        echo "Создана: $create_date ($create_author)" >> "$output_file"
        echo "Последнее изменение: $last_commit_date ($last_committer)" >> "$output_file"
        echo "--------------------------------------------------" >> "$output_file"
    fi
done

echo "Отчёт сохранён в файл $output_file"
```

### Вариант 3: Комбинированный вариант (и консоль, и файл)
```bash
#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

output_file="old_branches_report.txt"
current_date=$(date +%s)
two_years_ago=$((current_date - 2*365*24*60*60))

echo "Ветки старше двух лет:" > "$output_file"
echo -e "${YELLOW}Ветки старше двух лет:${NC}"

git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:iso) %(committerdate:unix) %(authorname) %(committername)' refs/heads/ | while read branch last_commit_date last_commit_unix author last_committer; do
    if [ "$last_commit_unix" -lt "$two_years_ago" ]; then
        create_date=$(git log --reverse --pretty=format:"%ai" "$branch" | head -1)
        create_unix=$(git log --reverse --pretty=format:"%at" "$branch" | head -1)
        create_author=$(git log --reverse --pretty=format:"%an" "$branch" | head -1)
        
        # Вывод в консоль с цветами
        echo -e "${RED}Ветка: ${BLUE}$branch${NC}"
        echo -e "${GREEN}Создана: ${NC}$create_date (${YELLOW}$create_author${NC})"
        echo -e "${GREEN}Последнее изменение: ${NC}$last_commit_date (${YELLOW}$last_committer${NC})"
        echo "--------------------------------------------------"
        
        # Вывод в файл без цветов
        echo "Ветка: $branch" >> "$output_file"
        echo "Создана: $create_date ($create_author)" >> "$output_file"
        echo "Последнее изменение: $last_commit_date ($last_committer)" >> "$output_file"
        echo "--------------------------------------------------" >> "$output_file"
    fi
done

echo -e "${GREEN}Отчёт также сохранён в файл ${BLUE}$output_file${NC}"
```

### Как использовать:
1. Сохраните нужный скрипт в файл (например, `old_branches.sh`)
2. Сделайте его исполняемым: `chmod +x old_branches.sh`
3. Запустите: `./old_branches.sh`

### Примечания:
- Скрипт использует `git for-each-ref` для получения списка веток и их последних коммитов
- Для определения даты создания ветки используется первый коммит в истории ветки
- Цветной вывод работает в большинстве современных терминалов
- Временной интервал (2 года) можно изменить, отредактировав строку `two_years_ago=$((current_date - 2*365*24*60*60))`