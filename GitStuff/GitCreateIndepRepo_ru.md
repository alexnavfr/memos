# Создание независимого репозитория с историей

## Prompt:
_Git. Существует структура типа:
root_proj/
│ .git
├── proj1/
│ ├── dir1/
│ └── dir2/
├── proj2/
│ ├── dir1/
│ ├── dir2/
Необходимо сделать проект `proj1` независимым. С сохраниением истории изменений. Финальная структура должна выглядеть так:
root_proj/
│ .git
├── proj2/
│ ├── dir1/
│ ├── dir2/
proj1/
│ .git
├── dir1/
└── dir2/
Объясни необходимые действия. Дай пошаговую инструкцию._

Чтобы сделать проект `proj1` независимым репозиторием с сохранением истории изменений, нужно выполнить следующие шаги. Мы будем использовать `git filter-repo` — мощный инструмент для перезаписи истории Git (альтернатива `git filter-branch`).

### Пошаговая инструкция:

#### 1. **Склонируйте исходный репозиторий (если ещё не склонирован)**
   ```bash
   git clone <original-repo-url> root_proj
   cd root_proj
   ```

#### 2. **Установите `git-filter-repo` (если ещё не установлен)**
   ```bash
   pip install git-filter-repo
   ```
   (или через `brew install git-filter-repo` на macOS)

#### 3. **Извлеките `proj1` в отдельный репозиторий**
   ```bash
   git filter-repo --subdirectory-filter proj1
   ```
   Эта команда:
   - Оставит только файлы из `proj1/` (теперь они будут в корне).
   - Сохранит всю историю, относящуюся только к `proj1`.

#### 4. **Переименуйте репозиторий (опционально)**
   Теперь `proj1` стал самостоятельным репозиторием. Перейдите в его папку:
   ```bash
   cd ..
   mv root_proj proj1
   ```

#### 5. **Вернитесь к исходному репозиторию (`root_proj`)**
   Склонируйте его заново (так как `filter-repo` перезаписывает историю):
   ```bash
   git clone <original-repo-url> root_proj_new
   cd root_proj_new
   ```

#### 6. **Удалите `proj1` из исходного репозитория**
   ```bash
   git filter-repo --path proj1 --invert-paths
   ```
   Эта команда удалит все упоминания `proj1` из истории, оставив только `proj2/`.

#### 7. **Проверьте структуру**
   Теперь у вас должно быть:
   - `proj1/` (отдельный репозиторий с историей только для `proj1`).
   - `root_proj_new/` (исходный репозиторий, но без `proj1`).

#### 8. **Обновите удалённые репозитории (если нужно)**
   Для `proj1`:
   ```bash
   cd ../proj1
   git remote set-url origin <new-repo-url-for-proj1>
   git push -u origin main
   ```

   Для `root_proj_new`:
   ```bash
   cd ../root_proj_new
   git remote set-url origin <original-repo-url>
   git push -u origin main --force
   ```
   (используйте `--force`, так как история была перезаписана).

### Итоговая структура:
```
root_proj/       (бывший root_proj_new)
│ .git
└── proj2/
    ├── dir1/
    └── dir2/

proj1/
│ .git
├── dir1/
└── dir2/
```

### Важные замечания:
1. **Резервное копирование**: Перед операциями с `filter-repo` сделайте backup репозитория.
2. **Совместная работа**: Если репозиторий общий, предупредите команду, так как перезапись истории требует принудительного пуша (`--force`).
3. **Альтернатива**: Если `git-filter-repo` недоступен, можно использовать `git subtree split`:
   ```bash
   git subtree split --prefix=proj1 -b proj1-only
   cd ..
   mkdir proj1
   cd proj1
   git init
   git pull ../root_proj proj1-only
   ```

Теперь `proj1` — самостоятельный репозиторий с сохранённой историей!

_Спасибо. Ответ точен. Прошу уточнить пункт 8. как определить значения `<new-repo-url-for-proj1>`и `<original-repo-url>`._

Отличный вопрос! Давайте разберёмся, как определить значения `<new-repo-url-for-proj1>` и `<original-repo-url>` в пункте 8.  

### **1. `<original-repo-url>`**
Это URL исходного репозитория (`root_proj`), из которого мы выделяем `proj1`.  

#### **Как его узнать?**
- Если вы клонировали репозиторий, то URL можно посмотреть командой:  
  ```bash
  git remote -v
  ```
  Вывод будет примерно таким:  
  ```
  origin  git@github.com:user/root_proj.git (fetch)
  origin  git@github.com:user/root_proj.git (push)
  ```
  Здесь `<original-repo-url>` = `git@github.com:user/root_proj.git` (или HTTPS-версия).  

- Если вы работаете с локальным репозиторием и не добавляли `remote`, то `<original-repo-url>` — это просто путь к новому удалённому репозиторию, куда вы хотите залить изменённую версию `root_proj` (без `proj1`).  

### **2. `<new-repo-url-for-proj1>`**
Это URL **нового** репозитория, куда будет перемещён `proj1`.  

#### **Как его получить?**
1. **Создайте новый пустой репозиторий** на GitHub/GitLab/Bitbucket (или другом хосте):  
   - Например, зайдите на GitHub → `New repository` → `proj1`.  
   - Не добавляйте `README`, `.gitignore` или `LICENSE` (чтобы не было конфликтов при первом пуше).  

2. **Скопируйте URL нового репозитория**:  
   - SSH: `git@github.com:user/proj1.git`  
   - HTTPS: `https://github.com/user/proj1.git`  

   Это и будет `<new-repo-url-for-proj1>`.  

### **Пример для пункта 8**
Допустим:  
- Исходный репозиторий: `git@github.com:user/root_proj.git`  
- Новый репозиторий для `proj1`: `git@github.com:user/proj1.git`  

Тогда команды будут выглядеть так:  

#### **Для `proj1` (новый репозиторий)**
```bash
cd proj1
git remote remove origin  # если был старый remote
git remote add origin git@github.com:user/proj1.git
git push -u origin main
```

#### **Для `root_proj_new` (обновлённый исходный репозиторий)**
```bash
cd root_proj_new
git remote remove origin  # если нужно
git remote add origin git@github.com:user/root_proj.git
git push -u origin main --force
```

### **Важно!**
- Если в `root_proj` были другие ветки (не `main`), их тоже нужно передать в новые репозитории.  
- `--force` нужен только если история была изменена (как после `filter-repo`).  
- Если `proj1` должен оставаться в том же хосте (например, GitHub), просто создайте там новый репозиторий и задайте его URL.  

Теперь `proj1` и `root_proj` — два независимых репозитория с корректной историей! 🚀



