# Типы комитов в git.

## Prompt:
_Git. Conventional Commits. Перечисли типы комитов(like fix,feat) в виде списка с кратким определения каждого типа и когда использовать._

Вот список основных типов коммитов согласно **Conventional Commits**, с краткими определениями и примерами использования:  

### 📌 Основные типы:
1. **`feat`** (feature) – Новая функциональность.  
   *Пример:* `feat: add user registration`  

2. **`fix`** – Исправление ошибки в коде.  
   *Пример:* `fix: resolve login page crash`  

### 🔧 Дополнительные типы:
3. **`docs`** (documentation) – Изменения в документации.  
   *Пример:* `docs: update API usage guide`  

4. **`style`** – Правки форматирования (пробелы, отступы, точки с запятой), не влияющие на логику.  
   *Пример:* `style: format code with Prettier`  

5. **`refactor`** – Рефакторинг кода без изменения поведения.  
   *Пример:* `refactor: simplify data fetching logic`  

6. **`perf`** (performance) – Изменения, улучшающие производительность.  
   *Пример:* `perf: optimize image loading`  

7. **`test`** – Добавление или изменение тестов.  
   *Пример:* `test: add unit tests for auth service`  

8. **`build`** – Сборка проекта или изменения зависимостей (npm, webpack, docker).  
   *Пример:* `build: update Dockerfile`  

9. **`ci`** (continuous integration) – Настройка CI/CD (GitHub Actions, Travis, Jenkins).  
   *Пример:* `ci: add GitHub Actions workflow`  

10. **`chore`** – Вспомогательные изменения (обновление конфигов, линтеров).  
    *Пример:* `chore: update eslint config`  

11. **`revert`** – Отмена предыдущего коммита.  
    *Пример:* `revert: remove experimental feature`  

### ⚠️ Особые случаи:
- **`BREAKING CHANGE`** – Если изменения ломают обратную совместимость (указывается в теле коммита или через `!` после типа).  
  *Пример:*  
  ```  
  feat!: drop support for Node 12  
  ```  

### 📝 Когда что использовать?
- **`feat`/`fix`** – Основные изменения.  
- **`refactor`/`perf`** – Оптимизации без новых возможностей.  
- **`docs`/`test`** – Всё, что не касается кода.  
- **`build`/`ci`/`chore`** – Технические правки.  

Этот стандарт помогает автоматизировать **CHANGELOG**, версионирование (**SemVer**) и анализ истории Git. 🚀
