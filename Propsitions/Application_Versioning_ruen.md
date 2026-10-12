# Application Versioning

## Prompt:
_Application.Versioning. Итак версия приложения состоит из 4 цифр - Major, Minor, Patch, Hotfix. Первые две цифры предлагается не трогать. Третью заменить годом. А вот с четвертой возникли разногласия. Предположим в git есть 2 ветки разработки fixJira1 и fixJira2 они обе изменяют код приложения, соответсвенно 4 цифра должна быть разной но постоянной которая говорит о внесенном изменении. Как в основной ветке master можно узнать на основании четвертой цифры что в нее интегрированы оба изменения или какое-то одно из них. Как вести нумерацию?_

Отличный вопрос! Это классическая проблема управления версиями при интеграции нескольких фич-веток. Давайте разберем решение.

Основная идея: **четвертый номер (Hotfix/Build) должен быть уникальным идентификатором для *каждого изменения* (каждой задачи Jira), а не просто последовательным номером для ветки `master`**.

Вот несколько практичных подходов, от самого простого к более продвинутому:

### Подход 1: Использование номера задачи из Jira (Рекомендуется)

Это самый простой, понятный и информативный способ.

*   **Как это работает:** Четвертая цифра версии становится не просто числом, а **номером задачи из Jира** (или любой другой системы задач).
*   **Пример:**
    *   Ветка `fixJira1` решает задачу **PROJ-123**. Версия в этой ветке становится `1.2.2024.123`.
    *   Ветка `fixJira2` решает задачу **PROJ-456**. Версия в этой ветке становится `1.2.2024.456`.
*   **Слияние в `master`:**
    *   Когда вы сливаете `fixJira1` в `master`, версия в `master` становится `1.2.2024.123`. Это явно говорит: "В `master` есть изменение из задачи PROJ-123".
    *   Когда вы *позже* сливаете `fixJira2` в `master`, возникает конфликт. **Нельзя просто взять версию из одной ветки.** Нужно **признать, что в `master` теперь два изменения**.

**Проблема:** Четвертая цифра — это одно число, а изменений два.

**Решение для `master`:** После слияния второй ветки версия в `master` **должна стать комплексной, отражающей оба изменения**. Есть варианты:

1.  **Список через разделитель (лучшая наглядность):** `1.2.2024.[123,456]` или `1.2.2024.123+456`. Это требует изменения формата версии со строго 4 цифр на более гибкий.
2.  **Использовать максимальный номер задачи (просто, но теряет информацию):** `1.2.2024.456`. Вы теряете факт, что изменение `123` тоже внутри.
3.  **Генерировать новый агрегированный номер (сложно для отслеживания):** Например, `1.2.2024.789`. Нужно где-то хранить маппинг: "версия 789 = изменения из 123 и 456".

### Подход 2: Использование монотонно возрастающего номера сборки (Build Number)

Это более классический CI/CD подход.

*   **Как это работает:** Четвертая цифра — это **уникальный номер сборки (build number)**, который автоматически увеличивается при каждой сборке (особенно в `master`). Его генерирует система CI/CD (Jenkins, GitLab CI, GitHub Actions).
*   **Ветки фич:** В ветках `fixJira1` и `fixJira2` можно оставлять версию "разработческой", например `1.2.2024.0` или `1.2.2024.SNAPSHOT`.
*   **Слияние в `master`:**
    *   Собирается `master` после слияния `fixJira1` → CI/CD присваивает новой сборке следующий номер, например, `1.2.2024.1051`.
    *   Позже сливается `fixJira2` → новая сборка `master` получает номер `1.2.2024.1052`.
*   **Как узнать, что внутри?** **По тегам и истории Git!** Вы помечаете (tag) каждую сборку в Git с её версией. Чтобы понять, какие изменения (Jira-задачи) вошли в `1.2.2024.1052`, вы смотрите:
    1.  История коммитов между тегом `v1.2.2024.1051` и `v1.2.2024.1052`.
    2.  В сообщениях коммитов или в именах веток будут ссылки на `Jira1` и `Jira2`.
*   **Преимущество:** Номер сборки в `master` всегда уникален и возрастает. Легко отследить порядок выпусков.
*   **Недостаток:** Номер сам по себе не несет информации о содержании. Требует дисциплины ведения коммитов и тегов.

### Подход 3: Семантическое версионирование с метаданными (Самый правильный)

Фактически, вы пытаетесь впихнуть в четвертый номер информацию, которая туда не помещается. По стандарту **SemVer** (Semantic Versioning), для таких целей служит **метаданная сборки (build metadata)**.

*   **Как это работает:** Версия выглядит так: `MAJOR.MINOR.PATCH+BUILD_METADATA`.
    *   `MAJOR.MINOR.PATCH` — это ваши "первые три цифры" (где PATCH = год).
    *   `+BUILD_METADATA` — это не номер, а строка. Она **не влияет на порядок версий**, но несет информацию.
*   **Ваш случай:**
    *   `master` после слияния `fixJira1`: `1.2.2024+JIRA-123`
    *   `master` после слияния `fixJira1` и `fixJira2`: `1.2.2024+JIRA-123.JIRA-456`
*   **Преимущество:** Четко, стандартно, машиночитаемо. Вся необходимая информация присутствует прямо в строке версии.
*   **Недостаток:** Требует смены парадигмы и, возможно, доработки инструментов.

---

### Практическая рекомендация для вашего случая

1.  **В ветках фич (`fixJira1`, `fixJira2`):**
    *   Устанавливайте версию, включающую номер задачи. Например, `1.2.2024.123`. Это сразу видно, для чего эта сборка.

2.  **При слиянии в `master` (стратегия для CI/CD):**
    *   **Не берите версию из сливаемой ветки.** Это ключевой момент.
    *   **Автоматически генерируйте новую версию для `master`**, исходя из:
        *   **Патч (третья цифра):** Текущий год.
        *   **Билд (четвертая цифра):** **Уникальный монотонно возрастающий номер сборки (Build Number)**. Этот номер должен храниться в CI/CD и увеличиваться с каждой сборкой `master`.
    *   **Обязательно тегируйте (tag) коммит в Git** с этой новой версией (`v1.2.2024.1052`).

3.  **Как узнать, что внутри версии `master`?**
    *   **Основной способ:** Используйте историю Git. Сравните теги или коммиты.
    *   **Дополнительно:** В метаданные сборки (description, release notes) вашего CI/CD/артефакта записывайте список номеров задач (Jira-123, Jira-456), которые вошли в эту сборку. Это можно автоматизировать, анализируя коммиты между тегами.

**Итог:** Не пытайтесь заставить четвертую цифру быть одновременно и уникальным идентификатором сборки `master`, и идентификатором задачи. Разделите эти понятия:
*   **Четвертая цифра в `master` — это Build Number** (уникальный, растущий).
*   **Идентификатор задачи — это метаинформация**, которая хранится в истории Git, релизных нотах и может быть выведена в виде строки метаданных (`+jira123.jira456`).

---
## English version

Excellent question! This is a classic versioning challenge when integrating multiple feature branches. Let's break down the solution.

The core idea: **The fourth number (Hotfix/Build) must be a unique identifier for *each change* (each Jira task), not just a sequential number for the `master` branch.**

Here are several practical approaches, from simplest to more advanced:

### Approach 1: Use the Jira Task Number (Recommended)

This is the simplest, most understandable, and informative method.

*   **How it works:** The fourth version digit becomes not just a number, but the **task number from Jira** (or any other task tracking system).
*   **Example:**
    *   Branch `fixJira1` addresses task **PROJ-123**. The version in this branch becomes `1.2.2024.123`.
    *   Branch `fixJira2` addresses task **PROJ-456**. The version in this branch becomes `1.2.2024.456`.
*   **Merging into `master`:**
    *   When you merge `fixJira1` into `master`, the version in `master` becomes `1.2.2024.123`. This clearly states: "`master` contains the change from task PROJ-123".
    *   When you *later* merge `fixJira2` into `master`, a conflict arises. **You cannot simply take the version from one branch.** You need to **acknowledge that `master` now contains two changes.**

**Problem:** The fourth digit is a single number, but there are two changes.

**Solution for `master`:** After merging the second branch, the version in `master` **must become composite, reflecting both changes.** There are options:

1.  **List with a separator (best clarity):** `1.2.2024.[123,456]` or `1.2.2024.123+456`. This requires changing the version format from strictly 4 digits to a more flexible one.
2.  **Use the highest task number (simple, but loses information):** `1.2.2024.456`. You lose the fact that change `123` is also included.
3.  **Generate a new aggregated number (hard to track):** For example, `1.2.2024.789`. You would need to store a mapping somewhere: "version 789 = changes from 123 and 456".

### Approach 2: Use a Monotonically Increasing Build Number

This is a more classic CI/CD approach.

*   **How it works:** The fourth digit is a **unique build number** that automatically increments with each build (especially in `master`). It is generated by the CI/CD system (Jenkins, GitLab CI, GitHub Actions).
*   **Feature branches:** In branches `fixJira1` and `fixJira2`, you can keep a "development" version, e.g., `1.2.2024.0` or `1.2.2024.SNAPSHOT`.
*   **Merging into `master`:**
    *   `master` is built after merging `fixJira1` → CI/CD assigns the next number to the new build, e.g., `1.2.2024.1051`.
    *   Later, `fixJira2` is merged → the new `master` build gets number `1.2.2024.1052`.
*   **How to know what's inside?** **Via Git tags and history!** You tag each build in Git with its version. To understand which changes (Jira tasks) are included in `1.2.2024.1052`, you look at:
    1.  The commit history between tags `v1.2.2024.1051` and `v1.2.2024.1052`.
    2.  The commit messages or branch names will contain references to `Jira1` and `Jira2`.
*   **Advantage:** The build number in `master` is always unique and increasing. Easy to track release order.
*   **Disadvantage:** The number itself doesn't convey information about the content. Requires disciplined commit and tag practices.

### Approach 3: Semantic Versioning with Metadata (The Most Correct)

Essentially, you are trying to force the fourth number to carry information it cannot hold. According to the **SemVer (Semantic Versioning)** standard, **build metadata** is designed for this purpose.

*   **How it works:** The version looks like this: `MAJOR.MINOR.PATCH+BUILD_METADATA`.
    *   `MAJOR.MINOR.PATCH` — these are your "first three digits" (where PATCH = year).
    *   `+BUILD_METADATA` — this is not a number but a string. It **does not affect version precedence** but carries information.
*   **Your case:**
    *   `master` after merging `fixJira1`: `1.2.2024+JIRA-123`
    *   `master` after merging both `fixJira1` and `fixJira2`: `1.2.2024+JIRA-123.JIRA-456`
*   **Advantage:** Clear, standard, machine-readable. All necessary information is present right in the version string.
*   **Disadvantage:** Requires a paradigm shift and possibly tool adjustments.

---

### Practical Recommendation for Your Case

1.  **In feature branches (`fixJira1`, `fixJira2`):**
    *   Set the version to include the task number. For example, `1.2.2024.123`. This immediately shows what the build is for.

2.  **When merging into `master` (CI/CD strategy):**
    *   **Do not take the version from the merged branch.** This is the key point.
    *   **Automatically generate a new version for `master`** based on:
        *   **Patch (third digit):** Current year.
        *   **Build (fourth digit):** **A unique, monotonically increasing build number.** This number should be stored in CI/CD and incremented with each `master` build.
    *   **Always tag the commit in Git** with this new version (`v1.2.2024.1052`).

3.  **How to know what's inside a `master` version?**
    *   **Primary method:** Use Git history. Compare tags or commits.
    *   **Additionally:** In the build metadata (description, release notes) of your CI/CD/artifact, record the list of task numbers (Jira-123, Jira-456) included in that build. This can be automated by analyzing commits between tags.

**Conclusion:** Do not try to make the fourth digit serve as both a unique identifier for the `master` build *and* a task identifier. Separate these concepts:
*   **The fourth digit in `master` is the Build Number** (unique, increasing).
*   **The task identifier is meta-information**, stored in Git history, release notes, and can be output as build metadata (`+jira123.jira456`).


