# Git branching policy

## Prompt:
_Git. Branching policy. Задача такая. Подготовь краткий, но точный пошаговый guide о работе с ветками гит. Необходимо рассмотреть политику создания новых веток их необходимость. Политику отслеживания старых и заброшенных веток. Критерии оценки "старости" (предложи несколько вариантов). Для каждого пункта предоставь необходимыу команды git с подробным объяснением._

 ### **Git Branching Policy: Step-by-Step Guide**  

This guide covers branch creation, tracking stale branches, and cleanup policies to maintain a clean and efficient Git repository.  

---

## **1. Branch Creation Policy**  
**Purpose:**  
- Feature development  
- Bug fixes  
- Hotfixes  
- Experiments (spikes)  

### **Step-by-Step Branch Creation**  
1. **Fetch latest changes from `main`/`master`:**  
   ```sh
   git checkout main
   git pull origin main
   ```  
   *Ensures you start from the latest code.*  

2. **Create a new branch with a descriptive name:**  
   ```sh
   git checkout -b feature/your-feature-name
   ```  
   *Follow naming conventions:*  
   - `feature/*` – New functionality  
   - `bugfix/*` – Bug corrections  
   - `hotfix/*` – Critical production fixes  
   - `spike/*` – Experimental code  

3. **Push the branch to remote:**  
   ```sh
   git push -u origin feature/your-feature-name
   ```  
   *The `-u` flag sets upstream tracking.*  

---

## **2. Tracking Old & Abandoned Branches**  
**Why?**  
- Avoid clutter in the repository.  
- Reduce merge conflicts and confusion.  

### **Criteria for "Stale" Branches**  
1. **Time-Based (e.g., 30+ days since last commit)**  
   ```sh
   git branch --remote --sort=-committerdate | grep -v 'main\|master\|dev' | head -n 10
   ```  
   *Lists oldest branches excluding `main`/`master`/`dev`.*  

2. **Merged vs. Unmerged**  
   ```sh
   git branch --remote --merged main  # Branches merged into main (safe to delete)
   git branch --remote --no-merged main  # Branches NOT merged (may need review)
   ```  

3. **Activity-Based (no commits in X days)**  
   ```sh
   git for-each-ref --format='%(committerdate:iso8601) %(refname:short)' --sort=-committerdate refs/remotes | grep -v 'main\|master'
   ```  
   *Shows branches sorted by last commit date.*  

---

## **3. Cleaning Up Old Branches**  
### **Option 1: Delete Locally**  
```sh
git branch -d old-branch          # Safe delete (checks merge status)
git branch -D old-branch          # Force delete (unmerged changes)
```  

### **Option 2: Delete Remote Branches**  
```sh
git push origin --delete old-branch
```  

### **Option 3: Bulk Cleanup (Merged Branches)**  
```sh
git branch --remote --merged main | grep -v 'main\|master\|dev' | xargs -n 1 git push origin --delete
```  
*Deletes all merged branches except protected ones.*  

---

## **4. Best Practices**  
✅ **Regular Audits** – Monthly checks for stale branches.  
✅ **Naming Conventions** – Clear prefixes (`feature/`, `bugfix/`).  
✅ **Documentation** – Keep a `BRANCH_POLICY.md` in the repo.  
✅ **Automation** – Use CI/CD to flag inactive branches.  

---

### **Summary of Key Commands**  
| Action | Command |
|--------|---------|
| Create & switch branch | `git checkout -b feature/name` |
| List old branches | `git branch --remote --sort=-committerdate` |
| List merged branches | `git branch --remote --merged main` |
| Delete remote branch | `git push origin --delete branch-name` |
| Bulk delete merged branches | `git branch --remote --merged main \| grep -v 'main\|master' \| xargs -n 1 git push origin --delete` |

This policy ensures a clean, manageable Git workflow. 🚀

##  Prompt.
_Отлично. Теперь сосредоточимся на уже существующих ветках которых стало много. Давай последовательно разберем как нам действовать. Вводные такие:
- изменения из данной ветки полностью перенесены в главную ветку.
- изменения проверены. Перенос в основную ветку в порядке очереди
- ветка заброшена. Изменения потеряли актуальность.
- изменения проверены и работают. Перенос в основную ветку отложен на неопределённый срок. Рассмотреть вариант с метками.
Для каждого шага укажи команды 'git'. Ответ подготовь в форматах "документ для обсуждения" и "инструкция к выполнению". Язык русский и английский. _

# **Документ для обсуждения: Политика управления существующими ветками Git**  

## **1. Введение**  
В репозитории накопилось много веток, часть из которых:  
- Уже влиты в `main` и не нужны.  
- Заброшены и устарели.  
- Готовы к влитию, но отложены.  

Необходимо определить порядок действий для каждой категории.  

## **2. Категории веток и действия**  

### **2.1. Ветки, полностью перенесённые в `main`**  
**Действие:** Удалить (локально и на сервере).  
**Команды:**  
```sh
git branch -d branch-name          # Локальное удаление (проверка слияния)
git push origin --delete branch-name  # Удаление из удаленного репозитория
```  

### **2.2. Ветки, проверенные, но ждущие очереди на влитие**  
**Действие:** Оставить, но добавить метку (`git tag`) для контроля.  
**Команды:**  
```sh
git tag ready-to-merge/branch-name branch-name  # Создание метки
git push origin ready-to-merge/branch-name      # Отправка метки на сервер
```  

### **2.3. Заброшенные ветки (изменения устарели)**  
**Действие:** Удалить после подтверждения команды.  
**Команды:**  
```sh
git branch -D old-branch          # Принудительное удаление (если не слита)
git push origin --delete old-branch
```  

### **2.4. Ветки, готовые, но отложенные на неопределённый срок**  
**Действие:**  
- **Вариант 1:** Оставить, но добавить метку (`on-hold/branch-name`).  
- **Вариант 2:** Архивировать (перенести в отдельный репозиторий).  

**Команды:**  
```sh
git tag on-hold/branch-name branch-name  # Метка для отложенных веток
git push origin on-hold/branch-name
```  

## **3. Рекомендации**  
✅ **Регулярный аудит** – Раз в месяц проверять ветки.  
✅ **Метки вместо веток** – Для отложенных изменений.  
✅ **Документирование** – В `README.md` или `BRANCH_POLICY.md`.  

---  

# **Инструкция к выполнению: Управление существующими ветками Git**  

## **1. Удаление веток, уже влитых в `main`**  
1. Проверить, что ветка слита:  
   ```sh
   git branch --merged main
   ```  
2. Удалить локально:  
   ```sh
   git branch -d branch-name
   ```  
3. Удалить на сервере:  
   ```sh
   git push origin --delete branch-name
   ```  

## **2. Ветки, проверенные, но ждущие очереди**  
1. Добавить метку:  
   ```sh
   git tag ready-to-merge/branch-name branch-name
   ```  
2. Отправить метку:  
   ```sh
   git push origin ready-to-merge/branch-name
   ```  

## **3. Удаление заброшенных веток**  
1. Проверить последний коммит:  
   ```sh
   git show branch-name --quiet
   ```  
2. Удалить (если уверены):  
   ```sh
   git branch -D old-branch
   git push origin --delete old-branch
   ```  

## **4. Отложенные ветки (метки)**  
1. Добавить метку:  
   ```sh
   git tag on-hold/branch-name branch-name
   ```  
2. Отправить метку:  
   ```sh
   git push origin on-hold/branch-name
   ```  

---  

# **Discussion Document: Git Branch Management Policy**  

## **1. Introduction**  
The repository has accumulated many branches, some of which:  
- Already merged into `main` and are no longer needed.  
- Abandoned and outdated.  
- Reviewed but delayed for merging.  

We need a clear action plan for each category.  

## **2. Branch Categories & Actions**  

### **2.1. Branches Fully Merged into `main`**  
**Action:** Delete (locally & remotely).  
**Commands:**  
```sh
git branch -d branch-name          # Local delete (checks merge status)
git push origin --delete branch-name  # Remote delete
```  

### **2.2. Reviewed Branches Awaiting Merge**  
**Action:** Keep but tag (`git tag`) for tracking.  
**Commands:**  
```sh
git tag ready-to-merge/branch-name branch-name
git push origin ready-to-merge/branch-name
```  

### **2.3. Abandoned Branches (Outdated)**  
**Action:** Delete after team confirmation.  
**Commands:**  
```sh
git branch -D old-branch          # Force delete (unmerged)
git push origin --delete old-branch
```  

### **2.4. Ready but Postponed Branches**  
**Action:**  
- **Option 1:** Tag (`on-hold/branch-name`).  
- **Option 2:** Archive (move to a separate repo).  

**Commands:**  
```sh
git tag on-hold/branch-name branch-name
git push origin on-hold/branch-name
```  

## **3. Recommendations**  
✅ **Regular Audits** – Monthly branch reviews.  
✅ **Tags Instead of Branches** – For postponed changes.  
✅ **Documentation** – In `README.md` or `BRANCH_POLICY.md`.  

---  

# **Execution Guide: Managing Existing Git Branches**  

## **1. Deleting Already Merged Branches**  
1. Check if merged:  
   ```sh
   git branch --merged main
   ```  
2. Delete locally:  
   ```sh
   git branch -d branch-name
   ```  
3. Delete remotely:  
   ```sh
   git push origin --delete branch-name
   ```  

## **2. Reviewed Branches Awaiting Merge**  
1. Add a tag:  
   ```sh
   git tag ready-to-merge/branch-name branch-name
   ```  
2. Push the tag:  
   ```sh
   git push origin ready-to-merge/branch-name
   ```  

## **3. Deleting Abandoned Branches**  
1. Check last commit:  
   ```sh
   git show branch-name --quiet
   ```  
2. Delete (if confirmed):  
   ```sh
   git branch -D old-branch
   git push origin --delete old-branch
   ```  

## **4. Postponed Branches (Tagging)**  
1. Add a tag:  
   ```sh
   git tag on-hold/branch-name branch-name
   ```  
2. Push the tag:  
   ```sh
   git push origin on-hold/branch-name
   ```  

---  

### **Final Notes**  
- 🔄 **Automation:** Consider scripts for bulk cleanup.  
- 📅 **Schedule:** Set reminders for branch reviews.  
- 📜 **Logging:** Keep a changelog of deleted branches.  

This ensures a clean, maintainable Git repository. 🚀

