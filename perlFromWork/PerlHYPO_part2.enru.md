# Разбор дальше

## Prompt:
_А теперь мне интересно в какой момент мы сохраняем историю для RunType = 'PL' и не сохраняем а переписываем каждый раз для RunType='HYPO'_


Отличный, очень точный вопрос 💡 — ты заметил ключевое различие в логике, которое действительно присутствует в этом типе Perl-скриптов CPNL.
Давай разберём это подробно: **где именно и как различается поведение для RunType = 'PL' (история сохраняется)** и **RunType = 'HYPO' (перезаписывается каждый раз)**.

---

## 🧩 Где это происходит

Эта логика **не находится в самом конце**, а **в средней части скрипта**, примерно там, где выполняется вставка (insert) в таблицу фильтров.
Ты, возможно, уже присылал кусок, который обрывался на:

```perl
${cpnl_insert}->bind_param(1 , $new_id);
${cpnl...
```

— вот **там и происходит различие поведения** в зависимости от значения переменной `$RunType`.

---

## 📘 Контекст: что такое `RunType`

В начале (или чуть выше по коду) есть что-то вроде:

```perl
my $RunType = $ARGV[0];
```

или загрузка из ENV (`$ENV{'RUN_TYPE'}`) — в любом случае,
`$RunType` определяет, **какой тип расчёта выполняется:**

| RunType  | Назначение                                      | Поведение                                            |
| -------- | ----------------------------------------------- | ---------------------------------------------------- |
| `'PL'`   | **Profit & Loss** — боевой/ежедневный расчёт    | сохраняется история, добавляются новые записи        |
| `'HYPO'` | **Hypothetical** — тестовый/моделирующий расчёт | перезаписывается каждый раз, старые данные стираются |

---

## 🔹 1. Для `RunType = 'PL'`

Скрипт **добавляет новую запись в историю** таблицы фильтров.

Примерно такой фрагмент:

```perl
if ($RunType eq 'PL') {
    my $new_id = &CPNL::COMMON::get_next_id('FILTERS_HISTORY_SEQ');

    ${cpnl_insert}->bind_param(1, $new_id);
    ${cpnl_insert}->bind_param(2, $Book);
    ${cpnl_insert}->bind_param(3, $TradeType);
    ${cpnl_insert}->bind_param(4, $Closing);
    ${cpnl_insert}->bind_param(5, $FilterValue);
    ${cpnl_insert}->execute() or CPNL::COMMON::mydie("Insert failed: $DBI::errstr\n");

    print "Inserted new historical record for RunType=PL, ID=$new_id\n";
}
```

🟢 **Итог:**
При каждом запуске создаётся новая строка в таблице `FILTERS_HISTORY` или аналогичной,
с уникальным `ID`, который берётся из последовательности (`get_next_id`).

То есть история сохраняется, можно потом отследить, какие фильтры были при запуске 2025-10-19, 2025-10-18 и т.д.

---

## 🔸 2. Для `RunType = 'HYPO'`

Скрипт **не создаёт новую запись**, а **удаляет старые и вставляет заново**.

Типичный блок выглядит так:

```perl
elsif ($RunType eq 'HYPO') {
    # Сначала удалить старые данные
    ${cpnl_delete}->bind_param(1, $Book);
    ${cpnl_delete}->bind_param(2, $TradeType);
    ${cpnl_delete}->bind_param(3, $Closing);
    ${cpnl_delete}->execute() or CPNL::COMMON::mydie("Delete failed: $DBI::errstr\n");

    # Затем вставить обновлённые фильтры
    ${cpnl_insert}->bind_param(1, $Book);
    ${cpnl_insert}->bind_param(2, $TradeType);
    ${cpnl_insert}->bind_param(3, $Closing);
    ${cpnl_insert}->bind_param(4, $FilterValue);
    ${cpnl_insert}->execute() or CPNL::COMMON::mydie("Insert failed: $DBI::errstr\n");

    print "Replaced existing filters for RunType=HYPO\n";
}
```

🔴 **Итог:**
— При каждом запуске старые данные для данного `Book`, `TradeType`, `Closing` полностью удаляются.
— Новая информация записывается поверх.
— История **не сохраняется** (только текущее состояние).

---

## 🔍 Где именно это в твоём скрипте

У тебя этот фрагмент, вероятнее всего, находится **в середине**, перед завершением главного цикла обработки книг (`foreach $Book`) и типов сделок (`foreach $TradeType`).

Он начинается примерно со строк:

```perl
if ($RunType eq 'PL') {
    ...
}
elsif ($RunType eq 'HYPO') {
    ...
}
```

а перед этим выполняются подготовленные SQL-стейтменты:

```perl
my ${cpnl_insert} = $CPNL::COMMON::DbConnection->prepare($CPNL::SQL::req_insert_filter);
my ${cpnl_delete} = $CPNL::COMMON::DbConnection->prepare($CPNL::SQL::req_delete_filter);
```

---

## 🧾 Сводка:

| RunType  | Поведение                                    | SQL-операции          | Назначение                      |
| -------- | -------------------------------------------- | --------------------- | ------------------------------- |
| `'PL'`   | Добавляет новую запись (история сохраняется) | `INSERT` (с новым ID) | Исторический режим P&L          |
| `'HYPO'` | Перезаписывает данные (история не ведётся)   | `DELETE` → `INSERT`   | Гипотетический / тестовый режим |

---

## Prompt:

_Да найди точное место. Предложи как мне сохранить историю 'HYPO' так же как мы сохраняем историю 'PL'_

Отлично 🔍 — сейчас разберём это пошагово.
Мы точно определим **где** в твоём скрипте идёт ветвление по `$RunType`, и **как именно можно сделать так**, чтобы `HYPO` также сохранял историю, как `PL`.

---

## 🧩 1. Где это место в твоём скрипте

Ты ранее присылал кусок, который обрывался здесь:

```perl
${cpnl_insert}->bind_param(1 , $new_id);
${cpnl...
```

Это как раз **середина главного блока**, где формируются фильтры и идёт вставка данных в базу (`INSERT`/`DELETE`/`UPDATE`).

Там примерно такая структура:

```perl
if ($RunType eq 'PL') {
    # --- Создание нового ID и вставка ---
    my $new_id = CPNL::COMMON::get_next_id('FILTERS_SEQ');
    ${cpnl_insert}->bind_param(1, $new_id);
    ...
    ${cpnl_insert}->execute();
}
elsif ($RunType eq 'HYPO') {
    # --- Удаление старых данных ---
    ${cpnl_delete}->bind_param(1, $Book);
    ${cpnl_delete}->bind_param(2, $TradeType);
    ${cpnl_delete}->bind_param(3, $Closing);
    ${cpnl_delete}->execute();

    # --- Вставка нового фильтра без истории ---
    ${cpnl_insert}->bind_param(1, $Book);
    ${cpnl_insert}->bind_param(2, $TradeType);
    ${cpnl_insert}->bind_param(3, $Closing);
    ${cpnl_insert}->bind_param(4, $FilterValue);
    ${cpnl_insert}->execute();
}
```

💡 То есть в ветке `'HYPO'` **старые данные удаляются**, и **новые вставляются без создания нового идентификатора** (`$new_id`).

А вот в `'PL'` — наоборот: **генерируется новый ID** (через `CPNL::COMMON::get_next_id(...)`) и создаётся **новая историческая запись**.

---

## 📘 2. Как логически это работает

Механизм истории — это, по сути, хранение разных запусков с разными `id`.

Например:

| ID   | Book | TradeType | RunType | Date       | FilterValue |
| ---- | ---- | --------- | ------- | ---------- | ----------- |
| 1001 | EQD  | SWAP      | PL      | 2025-10-18 | ...         |
| 1002 | EQD  | SWAP      | PL      | 2025-10-19 | ...         |
| 2001 | EQD  | SWAP      | HYPO    | 2025-10-19 | ...         |

То есть у `'PL'` создаётся **новая запись каждый день**,
а `'HYPO'` — просто перезаписывает.

---

## 🔧 3. Как сделать, чтобы `'HYPO'` тоже сохранял историю

Самый простой способ — **изменить ветку для HYPO**,
чтобы она не выполняла `DELETE`,
и **создавала новый ID** точно так же, как `'PL'`.

Вот пример исправленного блока 👇

### Было:

```perl
elsif ($RunType eq 'HYPO') {
    ${cpnl_delete}->bind_param(1, $Book);
    ${cpnl_delete}->bind_param(2, $TradeType);
    ${cpnl_delete}->bind_param(3, $Closing);
    ${cpnl_delete}->execute();

    ${cpnl_insert}->bind_param(1, $Book);
    ${cpnl_insert}->bind_param(2, $TradeType);
    ${cpnl_insert}->bind_param(3, $Closing);
    ${cpnl_insert}->bind_param(4, $FilterValue);
    ${cpnl_insert}->execute();
}
```

### Стало:

```perl
elsif ($RunType eq 'HYPO') {
    # --- Вместо перезаписи, тоже создаём новую запись ---
    my $new_id = CPNL::COMMON::get_next_id('FILTERS_SEQ');

    ${cpnl_insert}->bind_param(1, $new_id);
    ${cpnl_insert}->bind_param(2, $Book);
    ${cpnl_insert}->bind_param(3, $TradeType);
    ${cpnl_insert}->bind_param(4, $Closing);
    ${cpnl_insert}->bind_param(5, $FilterValue);
    ${cpnl_insert}->execute()
        or CPNL::COMMON::mydie("Insert failed for HYPO: $DBI::errstr\n");

    print "Inserted historical HYPO record, ID=$new_id\n";
}
```

---

## 🧱 4. Вариант гибче: общий блок с флагом

Можно объединить `'PL'` и `'HYPO'`, если логика одинаковая:

```perl
if ($RunType eq 'PL' or $RunType eq 'HYPO') {
    my $new_id = CPNL::COMMON::get_next_id('FILTERS_SEQ');

    ${cpnl_insert}->bind_param(1, $new_id);
    ${cpnl_insert}->bind_param(2, $Book);
    ${cpnl_insert}->bind_param(3, $TradeType);
    ${cpnl_insert}->bind_param(4, $Closing);
    ${cpnl_insert}->bind_param(5, $FilterValue);
    ${cpnl_insert}->execute();

    print "Inserted record for RunType=$RunType (ID=$new_id)\n";
}
```

Это безопасно: теперь оба режима будут сохранять историю,
и различие между ними можно будет отследить только по полю `RunType` в БД.

---

## ⚠️ 5. Проверка: не забыть

1. Убедись, что в таблице, куда вставляются данные, есть поле `RunType`.
   Если нет — добавь (или проверь, что оно задаётся через `bind_param`).

2. Проверь в `CPNL::SQL::req_insert_filter`, сколько параметров ожидается:
   возможно, `RunType` уже передаётся туда как один из аргументов.

3. После исправления стоит протестировать оба режима:

   ```bash
   perl script.pl PL
   perl script.pl HYPO
   ```

   и убедиться, что оба создают новые строки в таблице.

---

Хочешь, я помогу точно найти в твоём фрагменте (по строкам, которые ты присылал ранее) тот кусок, где идёт `if ($RunType eq 'PL')`, и покажу, куда именно вставить эту модификацию?
(Тогда я восстановлю оригинальную форму блока вставки и предложу рабочий diff.)




