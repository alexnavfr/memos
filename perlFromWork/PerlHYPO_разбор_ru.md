# Разбор скрипта Perl

## Prompt:
Будем разбирать скрипт по блокам.

1. block
Отличный вопрос — давай разберём этот фрагмент **построчно и подробно**, чтобы стало ясно, **что именно делает Perl при выполнении скрипта**.

---

### 🔹 Первая строка

```perl
#!/usr/bin/env perl
```

Это **шейбанг (shebang)** — системная подсказка, что скрипт нужно запускать с интерпретатором `perl`, который находится в `$PATH`.
`/usr/bin/env perl` — универсальный способ найти Perl в окружении пользователя (работает на разных системах, в отличие от жёсткого пути `/usr/bin/perl`).

---

### 🔹 Блок `BEGIN { ... }`

```perl
BEGIN {
  my $program_dir = $0;
  $program_dir =~ s{^(.*/).*?$}{$1};

  push @INC, $program_dir;
  push @INC, "$ENV{'SPEHOME'}/sbin/";
}
```

Блок `BEGIN` выполняется **ещё до того, как Perl начнёт обрабатывать остальные части программы** — буквально во время компиляции.
Это используется для инициализации окружения: например, добавления путей для поиска модулей.

---

#### 🔸 Строка 1:

```perl
my $program_dir = $0;
```

`$0` — это **путь к исполняемому скрипту**, который запущен.
Например, если ты запустил:

```
/opt/tools/my_script.pl
```

то `$0` будет равно `"/opt/tools/my_script.pl"`.

---

#### 🔸 Строка 2:

```perl
$program_dir =~ s{^(.*/).*?$}{$1};
```

Это регулярное выражение заменяет строку `$program_dir` на только её каталог (удаляет имя файла).

Пошагово:

* `^(.*/)` — захватывает всё от начала строки до **последнего** символа `/`.
* `.*?$` — остальная часть строки (имя файла).
* `$1` — оставляет только первую захваченную группу — путь к директории.

✅ Пример:

```perl
$program_dir = "/opt/tools/my_script.pl";
```

После выполнения:

```perl
$program_dir = "/opt/tools/";
```

---

#### 🔸 Строка 3–4:

```perl
push @INC, $program_dir;
push @INC, "$ENV{'SPEHOME'}/sbin/";
```

`@INC` — это **список директорий, где Perl ищет модули** (`use`, `require` и т.д.).

Обычно там лежат стандартные пути, например:

```
/usr/lib/perl5
/usr/local/lib/perl5
```

Эти две строки добавляют **дополнительные пути**:

1. `$program_dir` — папка, где находится сам скрипт.
2. `"$ENV{'SPEHOME'}/sbin/"` — путь, зависящий от переменной окружения `SPEHOME`.

> Например, если `SPEHOME=/opt/project`, то Perl будет искать модули и в `/opt/project/sbin/`.

Это нужно, чтобы скрипт мог подключать свои собственные локальные Perl-модули, не требуя глобальной установки.

---

### 🔹 Подключение модулей

```perl
use strict;
no strict 'refs';
use Date::Calc qw(Delta_Days);
use File::stat;
use CPNL::COMMON;
use CPNL::ENV_VARS;
use CPNL::SQL;
```

#### ▪ `use strict;`

Включает строгую проверку кода (обязательно объявлять переменные `my`, нельзя использовать неинициализированные глобальные переменные и т.д.).
Это помогает избежать ошибок.

#### ▪ `no strict 'refs';`

Отключает **строгость только для ссылок** (references).
Обычно это нужно, если программа будет работать с **динамическими именами переменных**, т.е. использовать символические ссылки:

```perl
my $varname = 'foo';
${$varname} = 42;  # разрешено, если strict 'refs' выключен
```

---

#### ▪ `use Date::Calc qw(Delta_Days);`

Подключает модуль `Date::Calc` и импортирует только функцию `Delta_Days`,
которая вычисляет количество дней между двумя датами.

#### ▪ `use File::stat;`

Подключает модуль для работы со структурой `stat()` — позволяет удобно получать размер файла, время изменения и т.д.

---

#### ▪ Пользовательские модули:

```perl
use CPNL::COMMON;
use CPNL::ENV_VARS;
use CPNL::SQL;
```

Эти три — **собственные Perl-модули проекта** (не стандартные).
Благодаря `push @INC` выше, Perl сможет найти их в:

* директории скрипта (`$program_dir`)
* или в `$SPEHOME/sbin/`.

Обычно такие модули содержат:

* общие функции (`COMMON`);
* переменные окружения или настройки (`ENV_VARS`);
* функции для работы с базой данных (`SQL`).

---

### 🔹 Итого: что делает этот кусок

1. Определяет папку, где лежит сам скрипт.
2. Добавляет в пути поиска модулей (`@INC`) эту папку и `$SPEHOME/sbin/`.
3. Включает строгий режим (кроме проверки ссылок).
4. Подключает системные и пользовательские модули, необходимые для работы скрипта.

---

### 💡 Кратко:

| Этап                                              | Действие                       | Цель                                |
| ------------------------------------------------- | ------------------------------ | ----------------------------------- |
| `#!/usr/bin/env perl`                             | Указывает интерпретатор        | Позволяет запускать скрипт напрямую |
| `BEGIN { ... }`                                   | Добавляет нужные пути в `@INC` | Чтобы `use` мог найти модули        |
| `use strict`                                      | Строгая проверка кода          | Безопасность и чистота              |
| `no strict 'refs'`                                | Разрешает динамические ссылки  | Гибкость                            |
| `use Date::Calc`, `use File::stat`, `use CPNL::*` | Подключает модули              | Расширяет функциональность          |

---

## Prompt 2:
_дальше идет разбор кода строки 34-116:_

Отлично 👍 — вторая часть гораздо насыщеннее, чем первая: здесь начинается **основная логика инициализации** скрипта.
Разберём всё **построчно и детально**, чтобы понять, **что именно делает Perl**, какие модули участвуют, и зачем нужны SQL-запросы.

---

## 🧩 Часть 2 — Анализ построчно

---

### 🔹 Получение параметров командной строки

```perl
GetOptions(
'h|H' =>\$help,
'PCF=s' =>\$_PARAMS_CVID_FILE,
'BATCHDATE=s' =>\$_BATCHDATE,
'TPL_FILTER=s' =>\$_TEMPLATE_FILTER,
'TPL_FILTERSEC=s' =>\$_TEMPLATE_FILTERSEC,
'FILTERS_FILE=s' =>\$_FILTERS_FILE,
'GRID_CMD_FILE=s' =>\$_GRID_CMD_FILE
) ;
```

#### 🔸 Что делает `GetOptions`

Функция `GetOptions` из модуля **Getopt::Long** (подключается неявно или ранее) разбирает аргументы, переданные скрипту в командной строке, и сохраняет их в переменные.

---

#### 🔸 Синтаксис параметров

* `'h|H' => \$help`
  — принимает флаг `-h` или `-H`, без значения (булево).
  Пример: `script.pl -h`

* `'PCF=s' => \$_PARAMS_CVID_FILE`
  — `=s` означает **строковое значение**.
  Пример: `-PCF params.txt`

* Остальные (`BATCHDATE`, `TPL_FILTER`, `TPL_FILTERSEC`, `FILTERS_FILE`, `GRID_CMD_FILE`) аналогично — принимают строки.

---

#### 🔸 Результат

После этого блока у нас есть такие переменные:

* `$help` — если задан `-h` или `-H`;
* `$_PARAMS_CVID_FILE` — путь к файлу параметров;
* `$_BATCHDATE` — дата запуска (возможно, для логов);
* `$_TEMPLATE_FILTER`, `$_TEMPLATE_FILTERSEC` — пути к шаблонам фильтров;
* `$_FILTERS_FILE`, `$_GRID_CMD_FILE` — файлы с командами и фильтрами.

---

### 🔹 Помощь по параметрам

```perl
if ($help) {
  print " |     Prog $0 \n";
  ...
  die ("\n\nHope this helps\n\n");
}
```

Если пользователь вызвал скрипт с `-h` или `-H`,
скрипт выведет справку и **завершит выполнение** (`die` останавливает программу).

`$0` — имя исполняемого скрипта.

---

🧠 Пример вывода:

```
| Prog ./generate_filters.pl
-----------------------------------------------------------------------
| -H              : Help
| -PCF            : Params and CVID file
| -BATCHDATE      : date to keep a trace of the execution
| -TPL_FILTER     : Template file to be used for the filters
| ...
-----------------------------------------------------------------------

Hope this helps
```

---

### 🔹 Проверка обязательных аргументов

```perl
die ("\nThe parameter -BATCHDATE is missing \n") if !$_BATCHDATE;
die ("\nThe parameter -PCF is missing \n") if !$_PARAMS_CVID_FILE;
...
```

Если какой-либо параметр не передан, скрипт аварийно завершится.

То есть программа требует **все эти параметры для корректной работы** — они определяют:

* дату (идентификатор сессии),
* входные данные (`PCF`),
* шаблоны (`TPL_FILTER*`),
* управляющие файлы (`GRID_CMD_FILE`, `FILTERS_FILE`).

---

## ⚙️ Подготовка SQL-запросов

```perl
my ${cpnl_get_new_max_tasks_id} = CPNL::COMMON::prepare_query($CPNL::SQL::get_new_max_tasks_id);
my ${cpnl_insert} = CPNL::COMMON::prepare_query("INSERT INTO SRM_Tasks_CPNL (...) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
...
```

---

### 🔸 Что делает `CPNL::COMMON::prepare_query`

С большой вероятностью этот метод:

* принимает SQL-строку (обычно запрос);
* вызывает `DBI->prepare($sql)` — создаёт **подготовленный запрос**;
* возвращает объект запроса (`$sth` — statement handle).

Таким образом, переменные `${cpnl_...}` — это объекты SQL-запросов, готовые к `->execute()`.

---

### 🔸 Какие запросы готовятся

| Переменная                     | Назначение                                 | Источник SQL                            |
| ------------------------------ | ------------------------------------------ | --------------------------------------- |
| `${cpnl_get_new_max_tasks_id}` | Получить новый ID задачи                   | `$CPNL::SQL::get_new_max_tasks_id`      |
| `${cpnl_insert}`               | Вставить запись в таблицу `SRM_Tasks_CPNL` | строка SQL прямо в коде                 |
| `${cpnl_update}`               | Обновить параметры                         | `$CPNL::SQL::req_update_params`         |
| `${cpnl_update_hypo}`          | Обновить гипотетические параметры          | `$CPNL::SQL::req_update_params_hypo`    |
| `${cpnl_delete_hypo}`          | Удалить гипотетические строки              | `$CPNL::SQL::req_delete_hypo_lines`     |
| `${cpnl_activate}`             | Активировать параметры                     | `$CPNL::SQL::req_activate_params`       |
| `${cpnl_remove_groups}`        | Очистить группы фильтров                   | `$CPNL::SQL::req_remove_groups`         |
| `${cpnl_deactivate_all}`       | Деактивировать все параметры               | `$CPNL::SQL::req_deactivate_all_params` |

---

### 🔹 Выполнение и завершение некоторых запросов

```perl
${cpnl_remove_groups}->execute();
${cpnl_remove_groups}->finish;

${cpnl_deactivate_all}->execute();
${cpnl_deactivate_all}->finish;
```

Эти команды:

1. Выполняют SQL-запрос (например, `DELETE` или `UPDATE`);
2. Закрывают statement handle (`finish`).

💡 Таким образом, скрипт:

* очищает старую информацию о группах фильтров;
* деактивирует все параметры перед загрузкой новых данных.

---

## 📊 Чтение данных из базы

---

### 🔹 Чтение исключений SDR

```perl
my ${list_exclusions_sdr} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_SDR_excl);
$list_exclusions_sdr->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
```

* Готовится и выполняется SQL-запрос `req_select_SDR_excl`,
  который возвращает список исключений (скорее всего, книг или трейдов, не участвующих в обработке).

---

#### 🔸 Перебор строк результата

```perl
while (my @exclusion = $list_exclusions_sdr->fetchrow_array) {
  my ($sdr_book, $sdr_tt, $sdr_comment) = @exclusion;
  print "req_select_SDR_excl $sdr_book,$sdr_tt,$sdr_comment\n";
  push @sdr_excl_array, $sdr_book.'.'.$sdr_tt;
}
```

Каждая строка результата помещается в массив `@exclusion`.
Из него берутся:

* `$sdr_book` — код книги (book),
* `$sdr_tt` — тип сделки (trade type),
* `$sdr_comment` — комментарий.

Создаётся массив `@sdr_excl_array` из строк `"BOOK.TRADETYPE"`.

📘 Пример:

```
req_select_SDR_excl FX01,SWAP,legacy_data
```

→ в массив добавится `"FX01.SWAP"`

---

### 🔹 Чтение основного списка CVID

```perl
my @main_cvid_array;
my ${list_main_cvid} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_mr_main_cvid);
$list_main_cvid->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
while (my @cur_main_cvid = $list_main_cvid->fetchrow_array) {
  my (${cvid}) = @cur_main_cvid;
  print "req_select_mr_main_cvid $cvid\n";

  push @main_cvid_array, ${cvid};
}
```

Этот фрагмент:

* извлекает из базы все значения `CVID` (вероятно, идентификаторы сценариев или клиентов);
* выводит их на экран;
* сохраняет в массив `@main_cvid_array` для дальнейшей обработки.

---

## 🧠 ИТОГОВОЕ ПОНИМАНИЕ

| Этап                    | Действие                           | Цель                                 |
| ----------------------- | ---------------------------------- | ------------------------------------ |
| `GetOptions(...)`       | Разбор аргументов командной строки | Получить имена файлов и дату         |
| Проверка параметров     | Проверить обязательные ключи       | Без них работа невозможна            |
| Подготовка SQL-запросов | `prepare_query(...)`               | Создать заготовки SQL-команд         |
| Очистка старых данных   | `remove_groups`, `deactivate_all`  | Сброс перед новой загрузкой          |
| Чтение SDR-исключений   | SQL → `@sdr_excl_array`            | Запомнить, какие сделки исключить    |
| Чтение CVID             | SQL → `@main_cvid_array`           | Список идентификаторов для обработки |

---

## 🧩 Ключевые Perl-концепции, использованные здесь

| Концепт                                       | Пример                                      | Назначение                                         |
| --------------------------------------------- | ------------------------------------------- | -------------------------------------------------- |
| **Ссылки на переменные**                      | `\$help`                                    | Позволяет `GetOptions` изменять внешние переменные |
| **Глобальные переменные в пространстве имён** | `$CPNL::SQL::req_update_params`             | Получение данных из импортированного модуля        |
| **Интерполяция переменных в SQL**             | `"INSERT INTO ... VALUES (?,?,?,?,...)”`    | Подготовка параметризованных SQL-запросов          |
| **Динамические имена переменных**             | `my ${cpnl_insert}`                         | Используется из-за `no strict 'refs'`              |
| **Работа с DBI-подобным интерфейсом**         | `->execute`, `->fetchrow_array`, `->finish` | Типичные шаги для SQL-запросов                     |

---

## Prompt 3 :
_строка 282_

Отлично 👏 — теперь мы добрались до самой "мясистой" части: здесь скрипт **загружает данные из базы**, **структурирует их в Perl-хэши и массивы**, и готовит к дальнейшей обработке.

Разберём эту часть пошагово, максимально подробно — что именно делает Perl, зачем столько `trim`, и как устроены эти сложные хэши с динамическими ключами.

---

## 🧩 Общая идея

В этой части скрипт дважды делает примерно одно и то же:

1. 📘 **Читает данные о фильтрах P&L из базы** (`req_select_params`)
   и сохраняет их в `%cpnl_filters_params_hash`.

2. 📗 **Читает данные о “разделённых фильтрах”** (`req_select_splitted_params`)
   и сохраняет их во вторую структуру `%cpnl_filters_splitted_params_hash`.

---

## 🔹 Блок 1: Чтение обычных фильтров (`req_select_params`)

### 1️⃣ Подготовка структур

```perl
my %cpnl_filters_params_hash;
my %cpnl_filters_names_hash;
my @cpnl_filters_nums_array;
```

* `%cpnl_filters_params_hash` — основной хэш с **параметрами фильтров**, ключ — уникальная комбинация `"RunType;Desk;Book;TradeType"`.
* `%cpnl_filters_names_hash` — хэш с **именами фильтров** по комбинации `"Desk;Book;TradeType"`.
* `@cpnl_filters_nums_array` — массив **номеров фильтров** (извлекаемых из имени фильтра).

---

### 2️⃣ SQL-запрос

```perl
my ${list_cpnl} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_params);
$list_cpnl->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
```

* Подготавливается SQL-запрос `req_select_params` из модуля `CPNL::SQL`.
* Выполняется запрос, который возвращает список строк (каждая — фильтр P&L).

---

### 3️⃣ Обработка результатов запроса

```perl
while (my @cur_cpnl = $list_cpnl->fetchrow_array) {
  my (${Id}, ${Priority}, ${RunType}, ${Desk}, ${Book}, ${TradeType}, ${FilterName}, ... ) = @cur_cpnl;
  ...
}
```

Каждая строка таблицы базы данных извлекается как массив `@cur_cpnl`.
Затем присваивается множеству отдельных переменных (через множественное присваивание).

---

### 4️⃣ Очистка строковых значений

```perl
${Id} = CPNL::COMMON::trim(${Id});
${Priority} = CPNL::COMMON::trim(${Priority});
...
```

`CPNL::COMMON::trim` — функция, убирающая пробелы по краям строк.
Это стандартный приём при чтении данных из SQL, чтобы избежать артефактов вроде `"ABC "`.

---

### 5️⃣ Фильтрация ненужных строк

```perl
if (${RunType} eq 'HYPO' &&
    !CPNL::COMMON::in_array(${CVID}, @main_cvid_array)) {
  next;
}
```

* Если тип запуска (`RunType`) = `HYPO` (гипотетический сценарий),
  и при этом CVID не входит в основной список `@main_cvid_array`,
  → эта запись пропускается (`next`).

То есть остаются только "актуальные" строки.

---

### 6️⃣ Извлечение номера фильтра

```perl
my $start_loc = length(${FilterName}) - $CPNL::ENV_VARS::_FILTERS_PADDING_COUNT;
my ${FilterNumber} = substr(${FilterName}, $start_loc, $CPNL::ENV_VARS::_FILTERS_PADDING_COUNT);
```

**Что происходит:**

* `$CPNL::ENV_VARS::_FILTERS_PADDING_COUNT` — число, определяющее длину числовой части имени фильтра (например, 5 символов).
* Из имени фильтра берётся **последний N-символьный кусок** — номер фильтра.

🧩 Пример:

```
FilterName = "FX_RISK_FILTER_00045"
_FILTERS_PADDING_COUNT = 5
→ FilterNumber = "00045"
```

---

### 7️⃣ Формирование основной хэш-структуры

```perl
$cpnl_filters_params_hash{${RunType}.';'.$Desk.';'.$Book.';'.$TradeType} = {
  'ID' => ${Id},
  'Priority' => ${Priority},
  'RunType' => ${RunType},
  ...
};
```

Ключ:

```
RunType;Desk;Book;TradeType
```

Например:

```
"REAL;FX;FX01;SWAP"
```

Значение: ссылка на хэш с параметрами данного фильтра:

```perl
{
  'ID' => 12,
  'Priority' => 3,
  'FilterName' => "FX_RISK_FILTER_00045",
  'FilterNumber' => "00045",
  ...
}
```

---

### 8️⃣ Дополнительные структуры

```perl
$cpnl_filters_names_hash{$Desk.';'.$Book.';'.$TradeType} = CPNL::COMMON::trim(${FilterName});
push @cpnl_filters_nums_array, ${FilterNumber};
```

* `%cpnl_filters_names_hash` сопоставляет `"Desk;Book;TradeType"` → `"FX_RISK_FILTER_00045"`.
* `@cpnl_filters_nums_array` собирает все номера фильтров, чтобы позже их отсортировать и уникализировать.

---

### 9️⃣ Сортировка и уникализация номеров

```perl
@cpnl_filters_nums_array = sort(@cpnl_filters_nums_array);
my %hash_tmp = map { $_ => 1 } @cpnl_filters_nums_array;
@cpnl_filters_nums_array = sort keys %hash_tmp;
```

* Сначала сортировка (например, `"00001"`, `"00002"`, ...).
* Затем `map` используется как способ **удалить дубликаты** (через временный хэш `%hash_tmp`).

---

## 🔹 Блок 2: Чтение *splitted filters* (`req_select_splitted_params`)

Это почти та же логика, но для **фильтров, разделённых по датам** (возможно, под-диапазоны P&L по периодам).

---

### 1️⃣ Инициализация структур

```perl
my %cpnl_filters_splitted_params_hash;
my %cpnl_filters_splitted_names_hash;
my @cpnl_filters_splitted_nums_array;
```

---

### 2️⃣ SQL-запрос

```perl
${list_cpnl} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_splitted_params);
$list_cpnl->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
```

---

### 3️⃣ Отладочные сообщения

```perl
print "EXECUTE!!!!!!!req_select_splitted_params \n";
```

(многократно повторено — вероятно, чтобы явно показать выполнение в логе).

---

### 4️⃣ Цикл обработки строк

Полностью аналогичен предыдущему:
все поля читаются, `trim`-ятся, затем создаются хэши.

---

### 5️⃣ Отличие: ключ хэша и вычисление номера фильтра

```perl
my $start_loc = length(${FilterName}) - $CPNL::ENV_VARS::_FILTERS_PADDING_COUNT + 1;
my ${FilterNumber} = substr(${FilterName}, $start_loc, $CPNL::ENV_VARS::_FILTERS_PADDING_COUNT);
```

* Здесь `+1`, потому что в “splitted filters” номера начинаются на позицию раньше —
  возможно, первая цифра используется для обозначения типа фильтра.

Ключ хэша теперь содержит **диапазон дат**:

```perl
${RunType}.';'.$Desk.';'.$Book.';'.$TradeType.';'.$From_TradeDate.';'.$To_TradeDate
```

То есть фильтр идентифицируется не только типом и книгой, но и временным диапазоном.

---

### 6️⃣ Пример структуры

```perl
$cpnl_filters_splitted_params_hash{"REAL;FX;FX01;SWAP;2025-01-01;2025-01-31"} = {
  'FilterName' => 'FX_RISK_SPLIT_01002',
  'FilterNumber' => '01002',
  'From_TradeDate' => '2025-01-01',
  'To_TradeDate' => '2025-01-31',
  ...
};
```

---

### 7️⃣ Хэш имён и список номеров

```perl
$cpnl_filters_splitted_names_hash{$Desk.';'.$Book.';'.$TradeType.';'.${From_TradeDate}.';'.${To_TradeDate}} = ${FilterName};
push @cpnl_filters_splitted_nums_array, ${FilterNumber};
```

---

### 8️⃣ Сортировка и уникализация

```perl
@cpnl_filters_splitted_nums_array = sort(@cpnl_filters_splitted_nums_array);
my %hash_tmp = map { $_ => 1 } @cpnl_filters_splitted_nums_array;
@cpnl_filters_splitted_nums_array = sort keys %hash_tmp;
```

---

## 🧠 ИТОГОВОЕ ПОВЕДЕНИЕ ЭТОЙ ЧАСТИ

| Этап | Что делает                            | Что получается                               |
| ---- | ------------------------------------- | -------------------------------------------- |
| 1    | Запрашивает все фильтры P&L из БД     | `%cpnl_filters_params_hash`                  |
| 2    | Пропускает неактуальные `HYPO` записи | —                                            |
| 3    | Очищает данные (`trim`)               | Убирает мусор и пробелы                      |
| 4    | Извлекает номера фильтров из имени    | `"FILTER_00012"` → `"00012"`                 |
| 5    | Формирует хэши параметров и имён      | Доступ к фильтрам по Desk/Book/TradeType     |
| 6    | Сортирует и удаляет дубликаты номеров | @cpnl_filters_nums_array                     |
| 7    | Делает то же для разделённых фильтров | `%cpnl_filters_splitted_params_hash`         |
| 8    | Формирует структуру с диапазонами дат | ключи включают From_TradeDate / To_TradeDate |

---

## 🧩 Ключевые Perl-приёмы в этой части

| Приём                               | Пример                                   | Объяснение                                         |
| ----------------------------------- | ---------------------------------------- | -------------------------------------------------- |
| **Динамические переменные**         | `my ${FilterNumber}`                     | Разрешено благодаря `no strict 'refs'`             |
| **Хэш со ссылками**                 | `%hash = ( key => { … } )`               | Хранит сложные структуры как JSON-подобные объекты |
| **`map` для удаления дубликатов**   | `map { $_ => 1 } @array`                 | Быстрое построение уникального множества           |
| **`substr` для извлечения номера**  | `substr($str, $start, $len)`             | Извлекает конец строки                             |
| **Объектный доступ к SQL-запросам** | `$sth->execute(); $sth->fetchrow_array;` | Типичный Perl/DBI стиль                            |

---

## 💡 Краткий итог (в человеческом виде)

> Скрипт обращается к БД, получает список фильтров P&L (обычных и разделённых), очищает и структурирует данные.
> Для каждого фильтра создаются хэши с детальной информацией, чтобы в последующих шагах скрипт мог:
>
> * легко найти фильтр по типу, книге и периоду,
> * знать, какой шаблон и параметры использовать,
> * и корректно построить SQL-запросы для расчётов P&L.

---

## Prompt 4:
_next 282-358_

Отлично 👌
Эта часть скрипта делает три большие операции, каждая логически готовит данные для последующих шагов:

---

## 🧩 Общая структура блока

| Раздел | Назначение                                                     |
| ------ | -------------------------------------------------------------- |
| 1️⃣    | Читает **технические исключения** (исключённые трейды)         |
| 2️⃣    | Читает **трансляцию CVID** для гипотетических (HYPO) сценариев |
| 3️⃣    | Читает и анализирует **файлы шаблонов фильтров**               |
| 4️⃣    | Читает **исключения из шаблонов фильтров** из базы             |

---

Теперь подробно, шаг за шагом 👇

---

## 🔹 1️⃣ Чтение технических исключений

```perl
my %exclusions_tech_hash;
my ${list_exclusions_tech} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_excl_tech);
$list_exclusions_tech->execute() or CPNL::COMMON::mydie(...);
```

### 💡 Что происходит:

* Из модуля `CPNL::SQL` берётся SQL-запрос `req_select_excl_tech`.
* Этот запрос получает список трейдов, которые **надо исключить** из расчётов — например, из-за технических причин, тестовых данных, аннулированных сделок и т.д.
* Результаты читаются построчно.

---

### Цикл обработки:

```perl
while (my @cur_exclusion_tech = $list_exclusions_tech->fetchrow_array) {
  my (${closing}, ${desk}, ${book}, ${trade_type}, ${trade_id_list}, ${comment}) = @cur_exclusion_tech;
  ...
}
```

Каждая строка из SQL содержит поля вроде:

```
closing | desk | book | trade_type | trade_id_list | comment
```

---

### Разбор списка трейдов

```perl
my @trade_id_array = split(/,/, ${trade_id_list});
foreach my $trade_id (@trade_id_array) {
  $trade_id = CPNL::COMMON::trim($trade_id);
  if (${trade_id} eq '') { next; }
  $exclusions_tech_hash{${desk}.';'.${book}.';'.${trade_type}} .= '-'.${trade_id};
}
```

**Что делает этот код:**

* Разбивает строку `"123,124,125"` в массив `("123","124","125")`.
* Очищает пробелы.
* Для каждой записи создаёт ключ `"desk;book;trade_type"` и добавляет строку `"-<trade_id>"` к значению.

🧩 Пример:

| Вход                                            | Результат в `%exclusions_tech_hash` |
| ----------------------------------------------- | ----------------------------------- |
| desk=FX, book=B001, type=SWAP, trades="123,124" | `"FX;B001;SWAP" => "-123-124"`      |

Таким образом, для каждого набора (деск, книга, тип сделки) хранится **строка из ID исключённых трейдов**.

---

## 🔹 2️⃣ Трансляция CVID для HYPO сценариев

```perl
my %hypo_cvid_transco_hash;
my ${list_hypo_cvid} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_hypo_cvid_transco);
$list_hypo_cvid->execute() or CPNL::COMMON::mydie(...);
```

**CVID (Curve ID)** — это идентификатор кривой (например, процентной ставки или валютного курса), используемой в расчётах P&L.
Иногда для гипотетических сценариев ("what-if" анализов) нужно **заменить** CVID из реального значения на тестовое.

---

### Цикл

```perl
while (my @cur_hypo_cvid = $list_hypo_cvid->fetchrow_array) {
  my (${cTranscoFrom}, ${cTranscoTo}) = @cur_hypo_cvid;
  print "req_select_hypo_cvid_transco:${cTranscoFrom},${cTranscoTo}\n";
  $hypo_cvid_transco_hash{${cTranscoFrom}} = ${cTranscoTo};
}
```

Результат:

```perl
%hypo_cvid_transco_hash = (
  "CVID_REAL_001" => "CVID_HYPO_001",
  "CVID_REAL_002" => "CVID_HYPO_002",
);
```

👉 То есть, когда скрипт встретит CVID `"CVID_REAL_001"`, он сможет быстро найти соответствующий `"CVID_HYPO_001"`.

---

## 🔹 3️⃣ Чтение и анализ шаблонов фильтров

Эта часть работает уже не с БД, а с файлами конфигурации шаблонов фильтров (обычно XML или текстовые шаблоны).

---

### Открытие основного шаблона

```perl
open (my $FIC_IN_TEMPLATE_FILTER,"<${CPNL::ENV_VARS::CONFIG}/${_TEMPLATE_FILTER}")
  or CPNL::COMMON::mydie("Error opening file ...");
my (@filter_template_array) = <$FIC_IN_TEMPLATE_FILTER>;
```

* Открывает файл (например, `/app/config/filters_template.tpl`).
* Читает его **построчно** в массив `@filter_template_array`.

---

### Проверка даты последнего изменения шаблона

```perl
my ($sec,$min,$hour,$mday,$mon,$year,...) = localtime(stat($FIC_IN_TEMPLATE_FILTER)->mtime);
```

`stat(...)->mtime` возвращает **дату последнего изменения файла** (в секундах с эпохи UNIX).
Функция `localtime` разбивает её на компоненты (год, месяц, день и т.п.).

---

### Расчёт, насколько давно файл изменялся

```perl
my $template_modified_days = Delta_Days(
    $year + 1900, CPNL::COMMON::get_month($mon), CPNL::COMMON::get_day($mday),
    substr($_BATCHDATE, 0, 4), substr($_BATCHDATE, 4, 2), substr($_BATCHDATE, 6, 2)
);
```

Функция `Delta_Days` (из `Date::Calc`) возвращает количество дней между:

* датой изменения файла,
* и текущей датой запуска (`$_BATCHDATE`, переданной как аргумент).

---

### Решение: нужно ли обновлять все фильтры

```perl
my $must_update_all_filters = 0;
if ($template_modified_days >= 0 &&
    $template_modified_days <= ${CPNL::ENV_VARS::_TEMPLATES_MODIFIED_SECURITY_DAYS}) {
  $must_update_all_filters = 1;
  print "File ... has been modified less than N days ago : we must update ALL filters !\n";
}
```

* Если шаблон был изменён недавно (например, ≤ 3 дней назад),
  то `must_update_all_filters = 1`.
* Это заставит систему **пересоздать все фильтры**, чтобы они соответствовали новому шаблону.

---

### Чтение второго шаблона (secondary)

```perl
open (FIC_IN_TEMPLATE_FILTERSEC,"<${CPNL::ENV_VARS::CONFIG}/${_TEMPLATE_FILTERSEC}") or ...
my (@filtersec_template_array) = <FIC_IN_TEMPLATE_FILTERSEC>;
close(FIC_IN_TEMPLATE_FILTERSEC);
```

— То же самое, но для второго шаблона (например, “security filters”).

---

## 🔹 4️⃣ Исключения шаблонов (из базы)

```perl
my %filter_tmpl_exclusions_hash;
my %templates_to_update;
my ${list_exclusions} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_excl_templ);
$list_exclusions->execute() or CPNL::COMMON::mydie(...);
```

* Из базы выбираются **исключения для шаблонов фильтров**: элементы, которые нужно удалить или заменить при генерации XML-файлов.
* Возможно, это индивидуальные настройки конкретных фильтров.

---

### Обработка исключений

```perl
while (my @exclusion = $list_exclusions->fetchrow_array) {
  my ($TmplAudit_DateTime, $TmplName, $ExclElement, $ExclValue) = @exclusion;

  $filter_tmpl_exclusions_hash{$TmplName} .= '<'.$ExclElement.'>'.$ExclValue.'</'.$ExclElement.'>';
```

Для каждого шаблона (`$TmplName`) создаётся строка XML-исключений:

🧩 Пример:

```perl
$filter_tmpl_exclusions_hash{"FX_FILTER_01"} = "<TradeType>SWAP</TradeType><Desk>FX</Desk>";
```

---

### Проверка свежести шаблона

```perl
my $template_modified_days = Delta_Days(
  substr($TmplAudit_DateTime, 0, 4),
  substr($TmplAudit_DateTime, 4, 2),
  substr($TmplAudit_DateTime, 6, 2),
  substr($_BATCHDATE, 0, 4),
  substr($_BATCHDATE, 4, 2),
  substr($_BATCHDATE, 6, 2)
);
```

Если исключение было обновлено недавно — или если весь шаблон недавно изменился —
оно добавляется в `%templates_to_update`.

---

### Вывод

```perl
if ($must_update_all_filters == 1) {
  $templates_to_update{$TmplName} = 1;
}
elsif ($template_modified_days >= 0 &&
      $template_modified_days <= ${CPNL::ENV_VARS::_TEMPLATES_MODIFIED_SECURITY_DAYS}) {
  $templates_to_update{$TmplName} = 1;
}
```

👉 В итоге `%templates_to_update` содержит **список шаблонов, которые нужно обновить**
(либо потому что их структура изменилась, либо потому что были обновлены исключения).

---

## 🧠 Итоговая картина

| Структура                      | Что хранит                                 | Пример                               |
| ------------------------------ | ------------------------------------------ | ------------------------------------ |
| `%exclusions_tech_hash`        | трейды, которые нужно исключить из расчёта | `"FX;B001;SWAP" => "-123-124-125"`   |
| `%hypo_cvid_transco_hash`      | соответствие CVID_REAL → CVID_HYPO         | `"CVID_REAL_001" => "CVID_HYPO_001"` |
| `@filter_template_array`       | содержимое файла шаблона                   | массив строк файла                   |
| `%filter_tmpl_exclusions_hash` | исключения XML для каждого шаблона         | `"FILTER_1" => "<Desk>FX</Desk>"`    |
| `%templates_to_update`         | список изменённых шаблонов                 | `"FILTER_1" => 1`                    |

---

## ⚙️ Зачем это всё

Этот блок подготавливает весь «сырой материал», с которым далее работает скрипт:

* знает, какие фильтры пересоздавать (если шаблон поменялся);
* знает, какие сделки не учитывать;
* знает, как трансформировать CVID для гипотетических сценариев;
* имеет XML-фрагменты для обновления шаблонов.

Следующий блок, скорее всего, будет **генерировать фильтры** на основе этих данных (создавать новые файлы или вставлять их в БД через `INSERT` / `UPDATE`).

---

## Prompt 4:
_359 - 933_

Отлично 👍 — это **огромный и важный фрагмент**, где, собственно, происходит **основная логика создания, обновления и активации “фильтров” (filters)** в системе.
Давай я объясню, что делает этот кусок **пошагово и с контекстом**.

---

## 🧩 1. Общий смысл блока

Этот участок скрипта занимается:

* чтением входного файла параметров (`_PARAMS_CVID_FILE`), где каждая строка содержит описание набора параметров запуска (“run parameters”);
* на основе этих параметров — **создаёт, обновляет или переактивирует фильтры** в базе данных;
* “фильтры” — это, по сути, задания (tasks) или логические выборки сделок (по Desk, Book, TradeType, датам и т.д.);
* если фильтр уже есть в БД, он проверяется на различия и при необходимости обновляется;
* если его нет — создаётся новый (`INSERT`);
* если он есть, но что-то в нём изменилось — обновляется (`UPDATE`);
* если ничего не изменилось — просто активируется (`ACTIVATE`);
* при этом HYPO-запуски (гипотетические сценарии) требуют особой обработки (удаление и пересоздание строк).

---

## 📄 2. Переменные и подготовка

```perl
my ${filter_name} = '';
my ${filter_num} = '';
my ${flag_import_filter} = 0;
my ${flag_new_filter} = 0;
my @cpnl_filters_to_create_array;
my @cpnl_filters_to_create_names_array;
my $new_id = 0;
my $_MUST_PRODUCT;
```

Это инициализация всех временных флагов и структур:

* `${filter_name}` — имя фильтра (`FILTER_00001`, например)
* `${filter_num}` — его числовой идентификатор
* `${flag_import_filter}` — нужно ли импортировать фильтр заново
* `${flag_new_filter}` — фильтр создаётся впервые
* массивы `@cpnl_filters_to_create_*` — накапливают фильтры, которые нужно потом реально импортировать
* `$new_id` — новый `TASK_ID` (из таблицы в БД)
* `${_MUST_PRODUCT}` — особое значение для “MUST_TR” (продукт, который обязателен к пересчёту)

---

## 📂 3. Чтение файла `_PARAMS_CVID_FILE`

```perl
open (FIC_IN_PARAMS_CVID,"<$CPNL::ENV_VARS::SUMMITSPOOLDIR/${_PARAMS_CVID_FILE}");
while (my $line=<FIC_IN_PARAMS_CVID>) {
  chomp($line);
  my (...список...) = split(/;/, $line);
```

* Открывается файл с параметрами (файл, созданный предыдущим этапом пайплайна).
* Каждая строка содержит информацию о параметрах запуска (`RunType`, `Desk`, `Book`, `TradeType`, даты, приоритеты и т.д.).
* Эти данные разбиваются по `;` и загружаются в локальные переменные.

---

## 📎 4. Обработка “copy-to” и исключений

```perl
if ((!CPNL::COMMON::in_array(${_BOOK}.'.'.${_TRADE_TYPE}, @sdr_excl_array)) && ...) {
    $_NEW_COPY_TO = CPNL::COMMON::trim(${_COPY_TO_SDR})."|";
}
if (CPNL::COMMON::trim(${_COPY_TO}) ne "") {
    $_NEW_COPY_TO .= CPNL::COMMON::trim(${_COPY_TO})."|";
}
```

— определяет, куда копировать результат (“copy-to targets”), в зависимости от исключений SDR.

---

## 🚫 5. Исключённые сделки и MUST_TR

```perl
my ${_TRADES_EXCLUDED} = $exclusions_tech_hash{${_DESK}.';'.${_BOOK}.';'.${_TRADE_TYPE}};
if (CPNL::COMMON::in_array(CPNL::COMMON::trim(${_TRADE_TYPE}), @CPNL::COMMON::must_types)) {
    ${_MUST_PRODUCT} = CPNL::COMMON::trim(${_TRADE_TYPE});
    ${_TRADE_TYPE} = "MUST_TR";
}
```

* Если тип сделки входит в “must_types”, то он заменяется на `"MUST_TR"`,
  а его оригинальное имя сохраняется в `${_MUST_PRODUCT}`.
* `$exclusions_tech_hash` даёт список исключённых сделок по Desk/Book/TradeType.

---

## 🧱 6. Создание хэша параметров фильтра

```perl
my $new_filter_params_hash_ref = {
  'Priority' => ...,
  'RunType' => ...,
  ...
  'CopyTo' => CPNL::COMMON::trim(${_NEW_COPY_TO})
};
```

Этот хэш описывает **все параметры будущего фильтра** — полный профиль задачи.
Дальше код будет сравнивать этот новый набор с текущим состоянием фильтра в БД.

---

## 🔀 7. Определение, нужно ли разбивать фильтр (split)

```perl
if (${new_filter_params_hash}{'Nb_Trades'} <= ${_SPLIT_THRESHOLD})
{
  ... один фильтр ...
}
else {
  ... разбиваем на несколько по датам сделок ...
}
```

* Если сделок (`Nb_Trades`) слишком много, фильтр “сплитится” —
  разбивается на подфильтры по диапазонам дат (`From_TradeDate` / `To_TradeDate`).
* Используется вспомогательная функция `get_tradedate_count_list`,
  которая возвращает количество сделок по датам.

---

## 🔁 8. Перебор фильтров для обработки

После подготовки создаётся список `@filters_to_treat`.
Для каждого фильтра выполняются проверки и возможные действия:

```perl
foreach my $cur_filter_to_treat (@filters_to_treat) {
    my %cur_filter_params_hash = %{$cur_filter_to_treat_hash{'cur_params'}};
    my %new_filter_params_hash = %{$cur_filter_to_treat_hash{'new_params'}};
```

---

## ⚙️ 9. Если фильтр уже существует

Проверяются изменения:

* шаблон (`TemplateUsed`)
* список исключений
* даты (`From_MatDate`, `To_MatDate`, `From_FinalMaturity`)
* CVID
* приоритет и другие параметры

Если различия есть — выполняется `UPDATE`.
Если фильтр HYPO — он удаляется (`DELETE`) и создаётся заново (`INSERT`).

---

## 🧩 10. Если фильтра нет — создаём новый

```perl
${filter_num} = CPNL::COMMON::find_hole_in_array(@cpnl_filters_nums_array);
${filter_name} = ${CPNL::ENV_VARS::_FILTERS_NAME_PREFIX}."_".$padded_filter_num;
```

* Находит “дырку” (первый свободный номер фильтра)
* Формирует имя (`FILTER_00123`)
* Создаёт запись в БД через `${cpnl_insert}`

---

## 💾 11. INSERT и UPDATE

`$cpnl_insert` и `$cpnl_update` — это заранее подготовленные SQL-запросы (prepared statements).
Перед каждым `execute()` в них подставляются значения:

```perl
${cpnl_insert}->bind_param(1 , $new_id);
${cpnl_insert}->bind_param(2 , $new_filter_params_hash{'Priority'});
...
${cpnl_insert}->execute();
```

---

## 🧮 12. Флаги импорта

```perl
if (${flag_import_filter} == 1 &&
    !CPNL::COMMON::in_array(${filter_name}, @cpnl_filters_to_create_names_array)) {
    push @cpnl_filters_to_create_array, { ... };
}
```

— если фильтр нужно импортировать, добавляем его в список для последующего импорта.

---

## 🧹 13. Завершение

```perl
${cpnl_get_new_max_tasks_id}->finish;
${cpnl_insert}->finish;
${cpnl_update}->finish;
...
```

— освобождает все подготовленные SQL-объекты (statement handles) и завершает работу этого блока.

---

## 🧠 14. В целом, логика цикла:

| Этап | Действие                                           |
| ---- | -------------------------------------------------- |
| 1️⃣  | Читаем строку с параметрами из `_PARAMS_CVID_FILE` |
| 2️⃣  | Проверяем, есть ли фильтр с такими параметрами     |
| 3️⃣  | Если есть — сравниваем параметры                   |
| 4️⃣  | Если различия — обновляем (`UPDATE`)               |
| 5️⃣  | Если HYPO — удаляем и пересоздаём                  |
| 6️⃣  | Если нет — создаём новый (`INSERT`)                |
| 7️⃣  | Если всё совпадает — просто активируем             |
| 8️⃣  | Добавляем фильтр в список для последующего импорта |

---

## Prompt 5 :
_935 - 1070_

Отлично 👍 — вот теперь мы подошли к **финальной фазе всего процесса**, где Perl-скрипт фактически **формирует выходные файлы** для загрузки (импорта) фильтров в систему и завершает работу.
Давай подробно разберём, **что делает каждая часть** этого большого куска.

---

## 🧩 1. Раздел «Open files»

```perl
open (FIC_OUT_GRID_CMD_FILE, ">$CPNL::ENV_VARS::SUMMITSPOOLDIR/${_GRID_CMD_FILE}");
```

— создаётся *командный файл*, в который будут записаны строки с командами импорта (`static_import`).

Затем инициализируются счётчики и имена файлов:

```perl
my $count_filters_files = 0;
my $count_filters_files_padded = sprintf("%0${CPNL::ENV_VARS::_FILTERS_PADDING_COUNT}d", $count_filters_files);
my $out_filters_filename = "${CPNL::ENV_VARS::SUMMITSPOOLDIR}/${_FILTERS_FILE}.${count_filters_files_padded}";
```

🔹 `sprintf("%0Xd", $n)` — добавляет ведущие нули, например `0001`, `0002`, чтобы имена файлов были сортируемыми.
🔹 создаётся файл, куда будут записаны фильтры (`FILTERS.0000`), и в него пишется открывающий тег:

```perl
print FIC_OUT_FILTERS "<ENTITYLIST>\n";
```

📂 Аналогично создаётся файл для “SEC-фильтров” (FilterSec Entities):

```perl
my $out_filters_sec_filename = ".../${_FILTERS_FILE}.SEC.0000";
open (FIC_OUT_FILTERS_SEC, ">${out_filters_sec_filename}");
print FIC_OUT_FILTERS_SEC "<ENTITYLIST>\n";
```

и в командный файл сразу записываются команды импорта:

```perl
print FIC_OUT_GRID_CMD_FILE "static_import -XML -NEWACT IMLIVE -I ${out_filters_filename} -COMMIT\n";
print FIC_OUT_GRID_CMD_FILE "static_import -XML -NEWACT IMLIVE -I ${out_filters_sec_filename} -COMMIT\n";
```

💡
→ То есть создаются **три файла**:

* `GRID_CMD_FILE` — содержит команды импорта;
* `FILTERS.xxxx` — XML-файл с фильтрами;
* `FILTERS.SEC.xxxx` — XML-файл с FilterSec сущностями (роли и доступы).

---

## ⚙️ 2. Подготовка к записи фильтров

```perl
my $count_filters = 0;
my $count_filters_in_file = 0;
my $count_filters_sec_in_file = 0;
```

— это счётчики общего количества фильтров и количества в текущем файле.

---

## 🔁 3. Основной цикл по фильтрам для импорта

```perl
foreach my $cur_filter_to_create (@cpnl_filters_to_create_array) {
  my %cur_filter_to_create_hash = %{$cur_filter_to_create};
```

Здесь скрипт берёт каждый фильтр, ранее накопленный в `@cpnl_filters_to_create_array`.

---

## 📂 4. Разделение на файлы при превышении лимита

Существует ограничение:

> `$CPNL::ENV_VARS::_FILTERS_MAX_NB_IN_FILE`

Если в одном файле слишком много фильтров, создаётся **новый файл**, и в командный файл (`GRID_CMD_FILE`) добавляется строка с его импортом.

```perl
if ($count_filters_in_file > $CPNL::ENV_VARS::_FILTERS_MAX_NB_IN_FILE) {
  print FIC_OUT_FILTERS "</ENTITYLIST>\n";
  close(FIC_OUT_FILTERS);
  ...
  open (FIC_OUT_FILTERS,">${out_filters_filename}") or CPNL::COMMON::mydie(...);
  print FIC_OUT_FILTERS "<ENTITYLIST>\n";
}
```

То же самое делается отдельно для `FilterSec` файлов (параллельная структура).

---

## 🧱 5. Создание FilterSec сущности (если фильтр новый)

```perl
if ($cur_filter_to_create_hash{'FlagNewFilter'} == 1) {
  for (my $i = 0; $i < @filtersec_template_array; $i++) {
      my $new_line = $filtersec_template_array[$i];
      $new_line =~ s/__FILTER_NAME__/$cur_filter_to_create_hash{'FilterName'}/g;
      $new_line =~ s/__ROLE_NAME__/${CPNL::ENV_VARS::_FILTERS_MODIF_ROLES}/g;
      print FIC_OUT_FILTERS_SEC "$new_line";
  }
  $count_filters_sec_in_file++;
}
```

🔹 `@filtersec_template_array` — шаблон XML-строк, определяющий права доступа к фильтру (кто может модифицировать, просматривать и т.д.).
🔹 Для каждого нового фильтра подставляются реальные значения и записывается блок XML в `FILTERS.SEC`-файл.

---

## 🧩 6. Создание основного фильтра (Filter Entity)

```perl
for (my $i = 0; $i < @filter_template_array; $i++) {
    my $new_line = $filter_template_array[$i];
    $new_line =~ s/__FILTER_NAME__/$cur_filter_to_create_hash{'FilterName'}/g;
    $new_line =~ s/__TEMPLATE_NAME__/$cur_filter_to_create_hash{'TemplateUsed'}/g;
    ...
    print FIC_OUT_FILTERS "$new_line";
}
```

🔹 `@filter_template_array` — это шаблон XML фильтра.
Каждая строка из шаблона копируется, в ней выполняются подстановки (`s///g`) вроде:

| шаблон                                     | заменяется на           |
| ------------------------------------------ | ----------------------- |
| `__FILTER_NAME__`                          | имя фильтра             |
| `__TEMPLATE_NAME__`                        | используемый шаблон     |
| `__TRADE_TYPE__`                           | тип сделки (или `MUST`) |
| `__DESK__`, `__BOOK__`                     | параметры               |
| `__FROM_TRADE_DATE__`, `__TO_TRADE_DATE__` | даты                    |
| `__TRADES_EXCLUDED__`                      | список исключений       |
| `__TEMPLATE_EXCLUSIONS__`                  | исключения из шаблона   |

Также есть особая логика:

```perl
if (CPNL::COMMON::in_array($cur_filter_to_create_hash{'MustProduct'}, @CPNL::COMMON::must_types)) {
    $new_line =~ s@__TRADE_TYPE__@MUST@g;
} else {
    $new_line =~ s@__TRADE_TYPE__@$cur_filter_to_create_hash{'MustProduct'}@g;
}
```

→ Если фильтр относится к “must types” (особые типы сделок), то вместо типа пишется `MUST`.

---

## 📄 7. Закрытие файлов

После цикла все открытые XML-файлы закрываются:

```perl
print FIC_OUT_FILTERS "</ENTITYLIST>\n";
close(FIC_OUT_FILTERS);
print FIC_OUT_FILTERS_SEC "</ENTITYLIST>\n";
close(FIC_OUT_FILTERS_SEC);
close(FIC_OUT_GRID_CMD_FILE);
close(FIC_IN_PARAMS_CVID);
```

📎 `<ENTITYLIST>` — это обёртка для XML-документа, закрывающая список сущностей (entity definitions).

---

## 🧹 8. Удаление неактивных “Splitted Filters”

```perl
my ${cpnl_delete} = CPNL::COMMON::prepare_query($CPNL::SQL::req_delete_inactive_splitted_params);
${cpnl_delete}->execute();
${cpnl_delete}->finish;
```

— выполняется SQL-запрос, который чистит старые неактивные (разбитые) фильтры из базы.
(Эти “splitted” фильтры — результат разбиения больших наборов на диапазоны дат.)

---

## 🗑️ 9. Удаление ненужных файлов

Если вообще **не было создано ни одного фильтра**, всё, что создавалось, удаляется:

```perl
if ($count_filters == 0) {
  print "There are no filters to import : Removing Import files :\n";
  unlink(${out_filters_filename});
  unlink(${out_filters_sec_filename});
  unlink(${CPNL::ENV_VARS::SUMMITSPOOLDIR}.'/'.${_GRID_CMD_FILE});
}
```

Так скрипт оставляет систему чистой — без пустых файлов и команд.

---

## 🧠 10. Итого — что делает этот блок

| Этап | Действие                                                 |
| ---- | -------------------------------------------------------- |
| 1️⃣  | Создаёт файлы: `GRID_CMD_FILE`, `FILTERS`, `FILTERS.SEC` |
| 2️⃣  | Записывает команды импорта (`static_import ...`)         |
| 3️⃣  | Перебирает все фильтры, собранные ранее                  |
| 4️⃣  | Для каждого создаёт XML-фрагменты из шаблонов            |
| 5️⃣  | При превышении лимита — открывает новый файл             |
| 6️⃣  | Закрывает все XML-файлы корректно                        |
| 7️⃣  | Очищает старые неактивные фильтры в БД                   |
| 8️⃣  | Если фильтров не было — удаляет временные файлы          |

---

## 🧩 11. Конечный результат

После выполнения этого блока в каталоге `${SPEHOME}/sbin` или `${SUMMITSPOOLDIR}` появляется структура вида:

```
FILTERS.0000
FILTERS.SEC.0000
GRID_CMD_FILE
```

Файл `GRID_CMD_FILE` содержит, например:

```
static_import -XML -NEWACT IMLIVE -I FILTERS.0000 -COMMIT
static_import -XML -NEWACT IMLIVE -I FILTERS.SEC.0000 -COMMIT
```

После чего эти команды могут быть выполнены на сервере Summit, чтобы **загрузить новые фильтры** и их права доступа.

---

## Prompt:
_1070 - 1300_

Отлично, теперь у нас есть финал всего скрипта 🙌
Ты прислал завершающий блок — **“End” + две функции:**
`calculateNextDate()` и `get_tradedate_count_list()` (с вложенной `prepare_get_infos_from_db()`).

Давай разберём подробно, **что происходит в этой части и зачем.**

---

## 🧩 1. Завершение основной программы

```perl
&CPNL::COMMON::db_disconnect();
print "=> End of filters creation.\n";
```

### Что делает

* `CPNL::COMMON::db_disconnect()` — закрывает соединение с базой данных, установленное ранее в скрипте.
  Обычно это вызов к `DBI->disconnect()` через обёртку, определённую в модуле `CPNL::COMMON`.
* `print "=> End of filters creation.\n";` — просто сообщение о завершении (лог в консоль).

---

## ⚙️ 2. Функция `calculateNextDate()`

```perl
sub calculateNextDate(){
    my ($Date) = @_;
    my $Year = substr($Date, 0, 4);
    my $Month = substr($Date, 4, 2) - 1;
    my $Day = substr($Date, 6, 2);
    my $Date_int = timelocal("0","0","0","$Day","$Month","$Year");
    my $NextDate_int = $Date_int + (24 * 60 * 60);
    my $NextDate = sprintf "%04d%02d%02d",
        (localtime($NextDate_int))[5] + 1900,
        (localtime($NextDate_int))[4] + 1,
        (localtime($NextDate_int))[3];
    return $NextDate;
}
```

### Что делает

Эта функция получает дату в формате `YYYYMMDD` и возвращает **следующую дату** (прибавляет 1 день).

### Пошагово:

1. `substr()` достаёт год, месяц, день из строки (`20251019` → `2025`, `10`, `19`).
2. Месяц уменьшается на 1, потому что `timelocal()` принимает месяцы в диапазоне `0–11`.
3. `timelocal()` из модуля `Time::Local` превращает дату в число секунд (UNIX timestamp).
4. Добавляется `24 * 60 * 60` секунд = 1 сутки.
5. `localtime()` обратно переводит число секунд в дату.
6. `sprintf "%04d%02d%02d"` формирует новую строку `YYYYMMDD`.
7. Возвращается результат, например:

   ```perl
   calculateNextDate("20251019") → "20251020"
   ```

---

## 📊 3. Функция `get_tradedate_count_list()`

Это одна из центральных частей бизнес-логики скрипта.

```perl
sub get_tradedate_count_list(){
    my ($Book, $TradeType, $Closing) = @_;
    my %TradeDate_Hash;
```

Эта функция:

* принимает параметры **Book**, **TradeType**, **Closing** (то есть книга сделок, тип сделки, дата закрытия),
* собирает SQL-запросы,
* и возвращает хэш `%TradeDate_Hash`, где:

  ```
  ключ = TradeDate
  значение = количество сделок (count)
  ```

---

### 🔹 Шаг 1: Получение шаблонных исключений

```perl
my ${tmpl_excl_db} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_common_tmpl_excl);
$tmpl_excl_db->execute();
while (my @tmpl_excl = $tmpl_excl_db->fetchrow_array) {
    my ($tmpl_name, $element, $value) = @tmpl_excl;
    $tmpl_excl_hash{$element} = $value;
}
```

Из базы данных извлекаются **исключения** (фильтры), определённые в шаблоне “COMMON template” — например, типы сделок, клиентов, статусы, которые надо исключить из отчёта.

Они сохраняются в `%tmpl_excl_hash`, типа:

```perl
%tmpl_excl_hash = (
   'TradeStatus' => 'CANCELLED',
   'Customer'    => 'TESTCLIENT',
   ...
)
```

---

### 🔹 Шаг 2: Построение SQL-фрагмента с исключениями

```perl
while ( my ($cur_excl_element, $cur_excl_value) = each %tmpl_excl_hash) {
    ...
    $sql_query_env_excl_tmpl .= " AND E.$cur_excl_element <> '$cur_excl_value' \n";
}
```

Здесь формируется фрагмент SQL (строка `sql_query_env_excl_tmpl`), который потом добавится к каждому SQL-запросу, чтобы исключить ненужные записи.

Также обрабатываются случаи:

* `"-"` — несколько исключений объединяются через `AND`
* `"+"` — несколько условий объединяются через `OR`
* `"%“` — используется `LIKE` вместо `=` или `<>`

---

### 🔹 Шаг 3: Получение минимальных дат

```perl
my $MatDate = ... req_select_mr_min_matdate
my $FinalMaturity = ... req_select_mr_min_finalmaturity
```

Из базы достаются минимальные даты:

* **MatDate** — минимальная дата погашения активов (maturity date),
* **FinalMaturity** — минимальная дата окончательной экспирации сделки.

Эти даты ограничивают диапазон для последующих SQL-запросов.

---

### 🔹 Шаг 4: Перебор типов сделок

```perl
my $list_trade_types = $CPNL::COMMON::DbConnection->prepare($CPNL::SQL::req_select_TTYPES);
$list_trade_types->execute();
while (my @trade_types = $list_trade_types->fetchrow_array) {
    my ($trade_type, $owner_table) = @trade_types;

    if ($trade_type eq $TradeType) {
        %TradeDate_Hash = &prepare_get_infos_from_db(...);
    }
}
```

Здесь программа перебирает список доступных типов сделок, и если находит нужный, вызывает подфункцию `prepare_get_infos_from_db()` для извлечения информации из базы.

---

## 📋 4. Подфункция `prepare_get_infos_from_db()`

Эта функция **динамически строит SQL-запрос**, подходящий под конкретный тип сделки (`FX`, `BOND`, `SWAP`, `REPO` и т.п.).

Она возвращает хэш `%data_hash` вида:

```perl
%data_hash = (
   "20251015" => 34,
   "20251016" => 29,
   "20251017" => 42,
   ...
)
```

---

### Пример того, что она делает

Если тип сделки = `"BOND"`, то запрос может быть примерно таким:

```sql
SELECT E.TradeDate, count(E.TradeDate) as TradesCount
FROM dmENV E, dmBOOK BOO, dmBOND BON, dmSEC S, dmSASSET SA
WHERE E.Audit_Current = 'Y'
  AND E.dmOwnerTable = 'dmBOND'
  AND E.TradeStatus IN ('OPEN','VALIDATED')
  AND BOO.Book = E.Book
  AND BOO.cdmClosing = '20251019'
  AND SA.MatDate > '20251001'
GROUP BY E.TradeDate
ORDER BY E.TradeDate
```

---

### Важные моменты:

* Для разных типов сделок (`BOND`, `FX`, `SWAP`, `OPTION`, `MM`, `REPO`, и др.) разные наборы таблиц (`dmBOND`, `dmFOREX`, `dmASSET`, `dmOPTION`, и т.д.).
* Общие условия:
  `E.Audit_Current = 'Y'`, `E.TradeStatus IN (...)`, `E.Book = ...`
* Исключения (`$sql_query_env_excl`, `$sql_query_env_excl_tmpl`) добавляются динамически.
* Результат выводится в консоль:

  ```perl
  print "sql_query = $sql_query.\n";
  ```

  — это помогает отладить SQL.

---

## 🧾 ИТОГОВАЯ ЛОГИКА ВСЕГО КУСОЧКА

1. Скрипт **создаёт фильтры** для различных типов сделок (в контексте PNL/Trading системы CPNL).
2. Подключается к базе через модуль `CPNL::COMMON`.
3. Выбирает активные книги (`Book`), типы сделок (`TradeType`), даты (`Closing`).
4. Для каждой комбинации собирает SQL с нужными условиями и исключениями.
5. Подсчитывает количество сделок по каждой дате (`TradeDate → Count`).
6. Сохраняет эти данные в таблицы фильтров.
7. Закрывает соединение и печатает сообщение о завершении.

---


