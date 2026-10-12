# Git Branch 6 months

## Prompt:
_Git v2.19.1. Давай напишем скрипт который создаст список веток которые были изменены в последние 6 месяцев. Строка должна содержать следующую информацию: дата создания ветки и её создатель, время последнего изменения и автор этого изменения. Вариантов предложить несколько - вывод результата на консоль, второй вариант вывод результата в файл, цветной вывод_

Вот скрипт для Git v2.19.1, который создаст список веток, изменённых в последние 6 месяцев, с указанием даты создания, автора, времени последнего изменения и автора изменения. Предлагаю три варианта вывода:

### Вариант 1: Цветной вывод в консоль
```bash
#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Получаем текущую дату в секундах с эпохи
current_date=$(date +%s)
# Вычисляем дату 6 месяцев назад (в секундах)
six_months_ago=$((current_date - 183*24*60*60))

echo -e "${CYAN}Ветки, изменённые за последние 6 месяцев:${NC}"

# Получаем список веток, изменённых за последние 6 месяцев
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:iso) %(committerdate:unix) %(authorname) %(committername)' refs/heads/ | while read branch last_commit_date last_commit_unix author last_committer; do
    if [ "$last_commit_unix" -gt "$six_months_ago" ]; then
        # Получаем дату создания ветки
        create_date=$(git log --reverse --pretty=format:"%ai" "$branch" | head -1)
        create_author=$(git log --reverse --pretty=format:"%an" "$branch" | head -1)
        
        echo -e "${YELLOW}Ветка: ${BLUE}$branch${NC}"
        echo -e "${GREEN}Создана: ${NC}$create_date (${RED}$create_author${NC})"
        echo -e "${GREEN}Последнее изменение: ${NC}$last_commit_date (${RED}$last_committer${NC})"
        echo -e "${GREEN}--------------------------------------------------${NC}"
    fi
done
```

### Вариант 2: Вывод в файл (без цветов)
```bash
#!/bin/bash

output_file="recent_branches_report.txt"
current_date=$(date +%s)
six_months_ago=$((current_date - 183*24*60*60))

echo "Ветки, изменённые за последние 6 месяцев:" > "$output_file"

git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:iso) %(committerdate:unix) %(authorname) %(committername)' refs/heads/ | while read branch last_commit_date last_commit_unix author last_committer; do
    if [ "$last_commit_unix" -gt "$six_months_ago" ]; then
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
CYAN='\033[0;36m'
NC='\033[0m' # No Color

output_file="recent_branches_combined.txt"
current_date=$(date +%s)
six_months_ago=$((current_date - 183*24*60*60))

echo "Ветки, изменённые за последние 6 месяцев:" > "$output_file"
echo -e "${CYAN}Ветки, изменённые за последние 6 месяцев:${NC}"

git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:iso) %(committerdate:unix) %(authorname) %(committername)' refs/heads/ | while read branch last_commit_date last_commit_unix author last_committer; do
    if [ "$last_commit_unix" -gt "$six_months_ago" ]; then
        create_date=$(git log --reverse --pretty=format:"%ai" "$branch" | head -1)
        create_author=$(git log --reverse --pretty=format:"%an" "$branch" | head -1)
        
        # Цветной вывод в консоль
        echo -e "${YELLOW}Ветка: ${BLUE}$branch${NC}"
        echo -e "${GREEN}Создана: ${NC}$create_date (${RED}$create_author${NC})"
        echo -e "${GREEN}Последнее изменение: ${NC}$last_commit_date (${RED}$last_committer${NC})"
        echo -e "${GREEN}--------------------------------------------------${NC}"
        
        # Вывод в файл
        echo "Ветка: $branch" >> "$output_file"
        echo "Создана: $create_date ($create_author)" >> "$output_file"
        echo "Последнее изменение: $last_commit_date ($last_committer)" >> "$output_file"
        echo "--------------------------------------------------" >> "$output_file"
    fi
done

echo -e "${GREEN}Отчёт также сохранён в файл ${BLUE}$output_file${NC}"
```

### Дополнительные улучшения:

1. **Сортировка по дате последнего изменения** (уже реализовано через `--sort=-committerdate`)
2. **Фильтрация по автору** (можно добавить параметр скрипта)
3. **Подсчёт количества веток**:

```bash
#!/bin/bash

# ... (остальной код скрипта)

count=0
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:iso) %(committerdate:unix) %(authorname) %(committername)' refs/heads/ | while read branch last_commit_date last_commit_unix author last_committer; do
    if [ "$last_commit_unix" -gt "$six_months_ago" ]; then
        # ... (обработка ветки)
        ((count++))
    fi
done

echo -e "${CYAN}Всего найдено веток: ${RED}$count${NC}"
```

### Как использовать:
1. Сохраните нужный скрипт в файл (например, `recent_branches.sh`)
2. Сделайте его исполняемым: `chmod +x recent_branches.sh`
3. Запустите: `./recent_branches.sh`

### Особенности работы:
- Используется `git for-each-ref` для эффективного получения информации о ветках
- Дата создания определяется по первому коммиту в ветке
- Интервал (6 месяцев) можно изменить, отредактировав `six_months_ago=$((current_date - 183*24*60*60))`
- Цветной вывод делает информацию более наглядной в терминале
- 