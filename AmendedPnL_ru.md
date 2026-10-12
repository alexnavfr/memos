# Amended PnL

## Prompt:
_Finance. Расскажи что такое "amended pnl"?_

Отличный вопрос в области финансов, особенно в контексте хедж-фондов, инвестиционных компаний и управляющих активами.

**Amended P&L (или Amended P&L Statement)** — это **исправленный или уточненный отчет о прибылях и убытках**, который выпускается после первоначального (предварительного) отчета.

Давайте разберем по порядку:

### Основная суть
Управляющие капиталом (например, хедж-фонды) часто предоставляют своим инвесторам предварительные (preliminary) оценки прибыли и убытков вскоре после окончания отчетного периода (месяца/квартала). Эти цифры основаны на оперативных данных и рыночных котировках. Однако для окончательного отчета требуется время на:
*   Точную сверку всех сделок.
*   Получение официальных выписок от брокеров и кастодианов.
*   Корректный учет всех комиссий, дивидендов, процентов и других начислений.
*   Аудит и валидацию данных.

Когда все эти процессы завершены и выявлены расхождения с предварительной оценкой, выпускается **Amended P&L** — окончательный, проверенный отчет.

### Ключевые причины выпуска Amended P&L:
1.  **Точность учета:** Исправление ошибок в первоначальных данных (например, неправильно зафиксированная цена сделки или ее объем).
2.  **Окончательные расчеты:** Учет всех комиссий (брокерских, управляющих, performance fees), которые могут быть рассчитаны только после определения окончательной NAV (стоимости чистых активов).
3.  **Корректировка оценки (Mark-to-Market):** Уточнение стоимости сложных или неликвидных активов, для которых предварительные котировки могли быть оценочными.
4.  **Учет корпоративных действий:** Дивиденды, сплиты акций, мерджи и т.д., информация о которых поступила позже.

### В чем разница между Preliminary P&L и Amended P&L?
| **Аспект** | **Preliminary (Предварительный) P&L** | **Amended (Исправленный) P&L** |
| :--- | :--- | :--- |
| **Своевременность** | Быстрый, выпускается вскоре после периода. | Запаздывающий, выпускается позже (дни или недели). |
| **Цель** | Дать инвесторам оперативное представление о результатах. | Предоставить окончательные, точные и проверенные данные. |
| **Точность** | Оценочная, на основе доступных на момент закрытия данных. | Высокая, прошедшая сверку и аудит. |
| **Основа** | Данные трейдинговых систем, последние котировки. | Официальные выписки от контрагентов, расчеты комиссий. |

### Практический пример (Хедж-фонд)
*   **31 января:** Окончание отчетного месяца.
*   **2 февраля:** Фонд рассылает **Prelinary P&L** за январь. Предварительная доходность +1.5%.
*   **С 3 по 10 февраля:** Проходит сверка. Обнаружено, что комиссия за одну из сделок была учтена не полностью, а дивиденды по одному из активов поступили на счет позже и не были включены.
*   **12 февраля:** Фонд рассылает **Amended P&L**, где с учетом всех корректировок окончательная доходность за январь составляет **+1.43%**. Этот показатель ложится в основу официальной отчетности и расчета вознаграждения управляющего.

### Важность для инвесторов
*   **Прозрачность:** Процесс (preliminary → amended) показывает, что у управляющего есть четкий контрольный цикл.
*   **Доверие:** Регулярные небольшие корректировки — это норма. Однако частые и значительные исправления могут быть **красным флажком**, сигнализирующим о слабых операционных процессах или потенциальных проблемах с рисками.
*   **Окончательность:** Именно **Amended P&L** является базой для расчета **доходности (performance)** фонда за период и, что критически важно, для расчета **вознаграждения за результат (performance fee)** управляющего.

### Резюме
**Amended P&L** — это **окончательная, откорректированная версия отчета о прибылях и убытках**, которая заменяет собой предварительную оценку. Он отражает точные финансовые результаты после всех сверок и уточнений. Наличие такого процесса — признак профессионального и ответственного подхода к финансовой отчетности в инвестиционной индустрии.

## Prompt 2:
_Как можно добавить в данный скрипт работу с "Amended Pnl"_

Чтобы добавить работу с "Amended Pnl" в данный скрипт, нужно внести изменения в несколько ключевых мест. Вот пошаговый план:

## **1. Добавить новый тип запуска в начало скрипта**

Добавить константу для нового типа:

```perl
# В разделе use CPNL::ENV_VARS добавить:
use CPNL::ENV_VARS;
# Добавить константу для Amended PnL
use constant _AMENDED_RUN_TYPES => ['AMENDED_PNL'];  # или добавить в массив существующих типов
```

## **2. Изменить SQL запросы (в модуле CPNL::SQL)**

Нужно добавить новые SQL запросы или модифицировать существующие:

```sql
-- Добавить в CPNL::SQL.pm:

# Для чтения Amended PnL параметров
our $req_select_amended_params = qq{
    SELECT Id, Priority, RunType, Desk, Book, TradeType, FilterName, 
           GroupFilterName, TemplateUsed, TradesExcluded, CVID, Closing, 
           From_TradeDate, To_TradeDate, From_MatDate, To_MatDate, 
           X_Date, Y_Date, EnvVars, CommandLine, TableTemp, TableFinal, 
           Nb_Trades, CopyTo, Active, From_FinalMaturity, EffectId,
           Amended_Date, Original_RunId  -- новые поля
    FROM SRM_Tasks_CPNL 
    WHERE RunType IN ('AMENDED_PNL')
    AND Active = 1
    ORDER BY Priority DESC
};

# Для обновления Amended PnL параметров
our $req_update_amended_params = qq{
    UPDATE SRM_Tasks_CPNL 
    SET Priority = ?, TemplateUsed = ?, TradesExcluded = ?, 
        From_TradeDate = ?, To_TradeDate = ?, From_MatDate = ?, 
        To_MatDate = ?, X_Date = ?, Y_Date = ?, From_FinalMaturity = ?,
        EnvVars = ?, CommandLine = ?, TableFinal = ?, Nb_Trades = ?, 
        CopyTo = ?, CVID = ?, Amended_Date = ?, Original_RunId = ?
    WHERE RunType = ? AND Desk = ? AND Book = ? AND TradeType = ? 
    AND FilterName = ? AND From_TradeDate = ? AND To_TradeDate = ?
};

# Для активации Amended PnL параметров
our $req_activate_amended_params = qq{
    UPDATE SRM_Tasks_CPNL 
    SET Active = 1 
    WHERE RunType = ? AND Desk = ? AND Book = ? AND TradeType = ? 
    AND From_TradeDate = ? AND To_TradeDate = ? 
    AND Amended_Date = ? AND Original_RunId = ?
};
```

## **3. Модифицировать основной скрипт**

### **A. Подготовка запросов**

```perl
# После других prepare_query добавить:
my ${cpnl_insert_amended} = CPNL::COMMON::prepare_query("INSERT INTO SRM_Tasks_CPNL (Id, Priority, RunType, Desk, Book, TradeType, FilterName, GroupFilterName, TemplateUsed, TradesExcluded, CVID, Closing, FromTradeDate, ToTradeDate, FromMatDate, ToMatDate, X_Date, Y_Date, EnvVars, CommandLine, TableTemp, TableFinal, NbTrades, CopyTo, Active, FromFinalMaturity, EffectId, Amended_Date, Original_RunId) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

my ${cpnl_update_amended} = CPNL::COMMON::prepare_query($CPNL::SQL::req_update_amended_params);
my ${cpnl_activate_amended} = CPNL::COMMON::prepare_query($CPNL::SQL::req_activate_amended_params);

# Также нужно подготовить запрос для чтения Amended PnL из БД
my ${cpnl_select_amended} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_amended_params);
```

### **B. Чтение Amended PnL данных в хэш**

```perl
######################################################
# We read the actual Amended P&L data (DB) into a hash
######################################################
my %cpnl_amended_filters_params_hash;
my %cpnl_amended_filters_names_hash;
my @cpnl_amended_filters_nums_array;

my ${list_cpnl_amended} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_amended_params);
$list_cpnl_amended->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");

while (my @cur_cpnl = $list_cpnl_amended->fetchrow_array) {
  # Добавить новые поля для Amended PnL
  my (${Id}, ${Priority}, ${RunType}, ${Desk}, ${Book}, ${TradeType}, ${FilterName}, 
      ${GroupFilterName}, ${TemplateUsed}, ${TradesExcluded}, ${CVID}, ${Closing}, 
      ${From_TradeDate}, ${To_TradeDate}, ${From_MatDate}, ${To_MatDate}, 
      ${X_Date}, ${Y_Date}, ${EnvVars}, ${CommandLine}, ${TableTemp}, ${TableFinal}, 
      ${Nb_Trades}, ${CopyTo}, ${Active}, ${From_FinalMaturity}, ${EffectId},
      ${Amended_Date}, ${Original_RunId}) = @cur_cpnl;
  
  # ... остальная обработка полей ...
  
  # Создать уникальный ключ для Amended PnL с учетом даты аmendment
  my $amended_key = ${RunType}.';'.$Desk.';'.$Book.';'.$TradeType.';'.
                   ${Amended_Date}.';'.${Original_RunId};
  
  $cpnl_amended_filters_params_hash{$amended_key} = {
      # ... все существующие поля ...
      'Amended_Date' => ${Amended_Date},
      'Original_RunId' => ${Original_RunId},
      # ... остальные поля ...
  };
  
  # Сохранить имя фильтра
  $cpnl_amended_filters_names_hash{$Desk.';'.$Book.';'.$TradeType.';'.
                                   ${Amended_Date}.';'.${Original_RunId}} = ${FilterName};
}
$list_cpnl_amended->finish();
```

### **C. Модификация основного цикла обработки**

```perl
# В разделе чтения входного файла добавить обработку Amended PnL
while (my $line=<FIC_IN_PARAMS_CVID>) {
  chomp($line);
  print "FIC_IN_PARAMS_CVID $line \n";
  
  # Добавить новые поля для Amended PnL
  my (${_RUN_TYPE}, ${_TEMPLATE_USED}, ${_DESK}, ${_BOOK}, ${_TRADE_TYPE}, 
      ${_FROM_MAT_DATE}, ${_TO_MAT_DATE}, ${_CVID}, ${_X_DATE}, ${_Y_DATE}, 
      ${_ENV_VARS}, ${_COMMAND_LINE}, ${_NB_TRADES}, ${_COPY_TO}, ${_COPY_TO_SDR}, 
      ${_PRIORITY}, ${_MIN_TRADE_DATE}, ${_TABLE_FINAL}, ${_SPLIT_THRESHOLD},
      ${_FROM_FINAL_MATURITY}, ${_AMENDED_DATE}, ${_ORIGINAL_RUNID}) = split(/;/, $line);
  
  # Проверка на Amended PnL
  if (${_RUN_TYPE} eq 'AMENDED_PNL') {
    # Обработка Amended PnL
    process_amended_pnl(
        \%new_filter_params_hash,
        ${_AMENDED_DATE},
        ${_ORIGINAL_RUNID},
        \@cpnl_amended_filters_params_hash,
        \@cpnl_amended_filters_names_hash,
        \@cpnl_amended_filters_nums_array
    );
  } else {
    # Существующая обработка для других типов
    # ...
  }
}
```

### **D. Добавить функцию обработки Amended PnL**

```perl
sub process_amended_pnl {
    my ($new_params_ref, $amended_date, $original_runid, 
        $amended_params_hash_ref, $amended_names_hash_ref, 
        $amended_nums_array_ref) = @_;
    
    my %new_filter_params_hash = %$new_params_ref;
    my %cpnl_amended_filters_params_hash = %$amended_params_hash_ref;
    my %cpnl_amended_filters_names_hash = %$amended_names_hash_ref;
    my @cpnl_amended_filters_nums_array = @$amended_nums_array_ref;
    
    # Создать уникальный ключ для поиска
    my $amended_key = 'AMENDED_PNL;' . 
                      $new_filter_params_hash{'Desk'} . ';' .
                      $new_filter_params_hash{'Book'} . ';' .
                      $new_filter_params_hash{'MustProduct'} . ';' .
                      $amended_date . ';' . $original_runid;
    
    my %cur_filter_params_hash;
    if ($cpnl_amended_filters_params_hash{$amended_key}) {
        %cur_filter_params_hash = %{$cpnl_amended_filters_params_hash{$amended_key}};
    }
    
    my $filter_name = $cpnl_amended_filters_names_hash{
        $new_filter_params_hash{'Desk'} . ';' .
        $new_filter_params_hash{'Book'} . ';' .
        $new_filter_params_hash{'MustProduct'} . ';' .
        $amended_date . ';' . $original_runid
    };
    
    my $filter_num = $cur_filter_params_hash{'FilterNumber'};
    
    # Добавить специфичные для Amended PnL поля
    $new_filter_params_hash{'Amended_Date'} = $amended_date;
    $new_filter_params_hash{'Original_RunId'} = $original_runid;
    
    # Проверить, нужно ли обновлять или создавать новую запись
    if ($filter_num) {
        # Проверить изменения
        my $need_update = check_amended_changes(\%cur_filter_params_hash, \%new_filter_params_hash);
        
        if ($need_update) {
            # Обновить Amended PnL запись
            update_amended_record(\%cur_filter_params_hash, \%new_filter_params_hash, 
                                 $filter_name, $filter_num);
        } else {
            # Просто активировать
            activate_amended_record(\%new_filter_params_hash, $filter_name);
        }
    } else {
        # Создать новую Amended PnL запись
        create_amended_record(\%new_filter_params_hash, $amended_date, 
                             $original_runid, \$filter_name, \$filter_num);
    }
}
```

### **E. Добавить вспомогательные функции**

```perl
sub check_amended_changes {
    my ($cur_params_ref, $new_params_ref) = @_;
    my %cur_params = %$cur_params_ref;
    my %new_params = %$new_params_ref;
    
    my @keys_to_check = ('Priority', 'TemplateUsed', 'TradesExcluded', 
                         'From_MatDate', 'To_MatDate', 'CVID', 'Amended_Date');
    
    foreach my $key (@keys_to_check) {
        if ($new_params{$key} ne $cur_params{$key}) {
            print "  Amended PnL: Change detected for $key\n";
            return 1;
        }
    }
    return 0;
}

sub update_amended_record {
    my ($cur_params_ref, $new_params_ref, $filter_name, $filter_num) = @_;
    my %cur_params = %$cur_params_ref;
    my %new_params = %$new_params_ref;
    
    print "  Updating Amended PnL record: $filter_name\n";
    
    # Подготовить таблицу для временных данных
    my $table_temp = '';
    if ($new_params{'RunType'} eq "THETA") {
        $table_temp = ${CPNL::ENV_VARS::_TABLE_TEMP_NAME_TTA_PREFIX} . $filter_num;
    } else {
        $table_temp = ${CPNL::ENV_VARS::_TABLE_TEMP_NAME_PREFIX} . $filter_num . "_AMENDED";
    }
    
    # Выполнить обновление
    ${cpnl_update_amended}->bind_param(1 , $new_params{'Priority'});
    ${cpnl_update_amended}->bind_param(2 , $new_params{'TemplateUsed'});
    # ... остальные параметры ...
    ${cpnl_update_amended}->bind_param(17, $new_params{'Amended_Date'});
    ${cpnl_update_amended}->bind_param(18, $new_params{'Original_RunId'});
    
    # WHERE условия
    ${cpnl_update_amended}->bind_param(19, $new_params{'RunType'});
    ${cpnl_update_amended}->bind_param(20, $new_params{'Desk'});
    ${cpnl_update_amended}->bind_param(21, $new_params{'Book'});
    ${cpnl_update_amended}->bind_param(22, $new_params{'MustProduct'});
    ${cpnl_update_amended}->bind_param(23, $filter_name);
    ${cpnl_update_amended}->bind_param(24, $new_params{'From_TradeDate'});
    ${cpnl_update_amended}->bind_param(25, $new_params{'To_TradeDate'});
    
    ${cpnl_update_amended}->execute();
}

sub create_amended_record {
    my ($new_params_ref, $amended_date, $original_runid, 
        $filter_name_ref, $filter_num_ref) = @_;
    
    my %new_params = %$new_params_ref;
    my $filter_name = $$filter_name_ref;
    my $filter_num = $$filter_num_ref;
    
    print "  Creating new Amended PnL record\n";
    
    # Генерация нового имени фильтра, если нужно
    if (!$filter_name) {
        $filter_num = CPNL::COMMON::find_hole_in_array(@cpnl_amended_filters_nums_array);
        if ($filter_num == -1) {
            $filter_num = $cpnl_amended_filters_nums_array[-1] + 1;
        }
        
        my $padded_filter_num = sprintf("%0${CPNL::ENV_VARS::_FILTERS_PADDING_COUNT}d", $filter_num);
        $filter_name = ${CPNL::ENV_VARS::_FILTERS_NAME_PREFIX} . "_AMENDED_" . $padded_filter_num;
        
        push @cpnl_amended_filters_nums_array, $padded_filter_num;
        @cpnl_amended_filters_nums_array = sort(@cpnl_amended_filters_nums_array);
    }
    
    # Подготовить таблицу для временных данных
    my $table_temp = '';
    if ($new_params{'RunType'} eq "THETA") {
        $table_temp = ${CPNL::ENV_VARS::_TABLE_TEMP_NAME_TTA_PREFIX} . $filter_num . "_AMENDED";
    } else {
        $table_temp = ${CPNL::ENV_VARS::_TABLE_TEMP_NAME_PREFIX} . $filter_num . "_AMENDED";
    }
    
    # Вставить новую запись
    my $new_id = $CPNL::COMMON::DbConnection->selectrow_array($cpnl_get_new_max_tasks_id);
    
    ${cpnl_insert_amended}->bind_param(1 , $new_id);
    ${cpnl_insert_amended}->bind_param(2 , $new_params{'Priority'});
    ${cpnl_insert_amended}->bind_param(3 , $new_params{'RunType'});
    # ... остальные параметры ...
    ${cpnl_insert_amended}->bind_param(28, $amended_date);
    ${cpnl_insert_amended}->bind_param(29, $original_runid);
    
    ${cpnl_insert_amended}->execute();
    
    $$filter_name_ref = $filter_name;
    $$filter_num_ref = $filter_num;
    
    return 1;
}
```

## **4. Модификация обработки файлов фильтров**

```perl
# В разделе создания фильтров для импорта добавить проверку на Amended PnL
foreach my $cur_filter_to_create (@cpnl_filters_to_create_array) {
    my %cur_filter_to_create_hash = %{$cur_filter_to_create};
    
    # Проверить, является ли фильтр Amended PnL
    if ($cur_filter_to_create_hash{'RunType'} eq 'AMENDED_PNL') {
        # Добавить специфичные теги для Amended PnL в XML
        for (my $i = 0; $i < @filter_template_array; $i++) {
            my $new_line = $filter_template_array[$i];
            
            # Добавить теги для Amended PnL
            $new_line =~ s/__AMENDED_DATE__/$cur_filter_to_create_hash{'Amended_Date'}/g;
            $new_line =~ s/__ORIGINAL_RUNID__/$cur_filter_to_create_hash{'Original_RunId'}/g;
            
            # ... остальные замены ...
            
            print FIC_OUT_FILTERS "$new_line";
        }
    } else {
        # Существующая обработка
        # ...
    }
}
```

## **5. Обновление шаблонов XML**

Создать или модифицировать шаблонные файлы для Amended PnL:

```xml
<!-- amended_filter_template.xml -->
<FILTER Name="__FILTER_NAME__">
    <TEMPLATE>__TEMPLATE_NAME__</TEMPLATE>
    <TRADETYPE>__TRADE_TYPE__</TRADETYPE>
    <DESK>__DESK__</DESK>
    <BOOK>__BOOK__</BOOK>
    <AMENDED_DATE>__AMENDED_DATE__</AMENDED_DATE>
    <ORIGINAL_RUNID>__ORIGINAL_RUNID__</ORIGINAL_RUNID>
    <!-- ... остальные теги ... -->
</FILTER>
```

## **6. Обновление входного формата файла**

Модифицировать формат входного файла параметров:

```
# Текущий формат:
RUN_TYPE;TEMPLATE_USED;DESK;BOOK;TRADE_TYPE;FROM_MAT_DATE;TO_MAT_DATE;CVID;...

# Новый формат для Amended PnL:
AMENDED_PNL;TEMPLATE_USED;DESK;BOOK;TRADE_TYPE;FROM_MAT_DATE;TO_MAT_DATE;CVID;...;AMENDED_DATE;ORIGINAL_RUNID
```

## **7. Добавить логику очистки старых Amended PnL**

```perl
# В конце скрипта добавить:
######################################################
# Remove old Amended PnL records (older than X days)
######################################################
if ($CPNL::ENV_VARS::_AMENDED_RETENTION_DAYS) {
    my ${cpnl_cleanup_amended} = CPNL::COMMON::prepare_query($CPNL::SQL::req_cleanup_old_amended);
    ${cpnl_cleanup_amended}->bind_param(1, $_BATCHDATE);
    ${cpnl_cleanup_amended}->bind_param(2, $CPNL::ENV_VARS::_AMENDED_RETENTION_DAYS);
    ${cpnl_cleanup_amended}->execute();
    ${cpnl_cleanup_amended}->finish;
}
```

## **Ключевые особенности реализации:**

1. **Отдельные таблицы/префиксы** для временных данных Amended PnL
2. **Связь с оригинальными запусками** через `Original_RunId`
3. **Дата исправления** (`Amended_Date`) для отслеживания версий
4. **Отдельные SQL запросы** для Amended PnL операций
5. **Сохранение истории** всех исправлений
6. **Очистка старых записей** для управления дисковым пространством

## **Важные замечания:**

1. **Проверить совместимость** с существующими процессами
2. **Обновить документацию** по формату входных файлов
3. **Протестировать** на всех типах торгов
4. **Рассмотреть производительность** при большом количестве исправлений
5. **Обеспечить целостность данных** при удалении оригинальных записей

Эта реализация обеспечивает полную поддержку Amended PnL с сохранением всех преимуществ существующей архитектуры.

