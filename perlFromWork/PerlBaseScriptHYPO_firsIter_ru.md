# Первая версия изменения для HYPO

## Prompt 1:
_Измени скрипт таким образом чтобы данные для RunType = 'HYPO' обрабатывались одинаковым образом с RunType='PL'. Необходимо сохранять историю для типа 'HYPO' аналогичным образом как сейчас сохраняется для типа 'PL'. Изменения необходимо объяснить пошагово и подробно_

Я проанализировал код и вижу несколько ключевых различий в обработке HYPO и PL. Вот необходимые изменения для обеспечения одинаковой обработки:

## **Основные различия, которые нужно устранить:**

1. **Разное обновление CVID** - для HYPO используется специальная логика `cpnl_update_hypo`
2. **Специальное удаление и пересоздание строк** для HYPO при изменении CVID
3. **Разные таблицы для временных данных** (префиксы `_TABLE_TEMP_NAME_PREFIX` и `_TABLE_TEMP_NAME_TTA_PREFIX`)

## **Шаги для изменений:**

### **1. Удалить специальную обработку удаления HYPO строк**

Найти и удалить этот блок:

```perl
if ($flag_differences_hypo_cvid_found == 1 ) {
  print '  HYPO : we delete and recreate lines.'."\n";
  
  ${cpnl_delete_hypo}->bind_param(1, ${filter_name});
  ${cpnl_delete_hypo}->execute();
  
  # ... остальной код создания новых строк для HYPO ...
}
```

Вместо этого нужно обрабатывать HYPO так же, как PL - через обычное обновление.

### **2. Изменить логику обновления CVID для HYPO**

Заменить это условие:

```perl
# Hypo : Never update CVID
if ($new_filter_params_hash{'RunType'} ne 'HYPO') {
```

На:

```perl
# Все типы (включая HYPO) обновляют CVID одинаково
if (1) {
```

Или просто удалить условие полностью.

### **3. Удалить специальную подготовку запроса для HYPO**

Удалить или закомментировать эту строку:

```perl
my ${cpnl_update_hypo} = CPNL::COMMON::prepare_query($CPNL::SQL::req_update_params_hypo);
```

Также удалить:

```perl
my ${cpnl_delete_hypo} = CPNL::COMMON::prepare_query($CPNL::SQL::req_delete_hypo_lines);
```

### **4. Изменить логику вставки новых записей для HYPO**

Вместо создания нескольких записей для разных `hypo_effects`, создавать одну запись как для PL.

Заменить этот блок:

```perl
if ($new_filter_params_hash{'RunType'} eq 'HYPO') {
  my ${Hypo_CVID};
  foreach my $cur_hypo_effect (@CPNL::ENV_VARS::hypo_effects) {
    $new_id = $CPNL::COMMON::DbConnection->selectrow_array($cpnl_get_new_max_tasks_id);
    ${cpnl_insert}->bind_param(1 , $new_id);
    
    ${Hypo_CVID} = $hypo_cvid_transco_hash{$cur_hypo_effect.';'.$new_filter_params_hash{'CVID'}};
    if (defined(${Hypo_CVID}) &&
        ${Hypo_CVID} ne "") {
      ${cpnl_insert}->bind_param(11, ${Hypo_CVID});
      ${cpnl_insert}->bind_param(27, $cur_hypo_effect);
    }
    else {
      ${cpnl_insert}->bind_param(11, $new_filter_params_hash{'CVID'});
    }
    ${cpnl_insert}->execute();
  }
}
```

На:

```perl
if ($new_filter_params_hash{'RunType'} eq 'HYPO') {
  $new_id = $CPNL::COMMON::DbConnection->selectrow_array($cpnl_get_new_max_tasks_id);
  ${cpnl_insert}->bind_param(1 , $new_id);
  # Используем оригинальный CVID, без трансформаций
  ${cpnl_insert}->bind_param(11, $new_filter_params_hash{'CVID'});
  ${cpnl_insert}->bind_param(27, ''); # EffectId пустой как у PL
  ${cpnl_insert}->execute();
}
```

### **5. Удалить хэш трансформации CVID для HYPO**

Удалить или закомментировать этот блок:

```perl
my %hypo_cvid_transco_hash;
my ${list_hypo_cvid} = CPNL::COMMON::prepare_query($CPNL::SQL::req_select_hypo_cvid_transco);
$list_hypo_cvid->execute() or CPNL::COMMON::mydie("SQL execution failed : $DBI::errstr\n");
while (my @cur_hypo_cvid = $list_hypo_cvid->fetchrow_array) {
  my (${cTranscoFrom}, ${cTranscoTo}) = @cur_hypo_cvid;
  print "req_select_hypo_cvid_transco:${cTranscoFrom},${cTranscoTo}\n";
  $hypo_cvid_transco_hash{${cTranscoFrom}} = ${cTranscoTo};
}
```

### **6. Использовать одинаковые префиксы таблиц**

Изменить логику выбора префикса таблицы. Вместо:

```perl
if ($new_filter_params_hash{'RunType'} eq "THETA")
{
  ${table_temp} = ${CPNL::ENV_VARS::_TABLE_TEMP_NAME_TTA_PREFIX}.${padded_filter_num};
}
else
{
  ${table_temp} = ${CPNL::ENV_VARS::_TABLE_TEMP_NAME_PREFIX}.${padded_filter_num};
}
```

Можно использовать единый префикс для всех типов, или оставить как есть, но тогда для HYPO тоже использовать `_TABLE_TEMP_NAME_PREFIX`.

### **7. Удалить специальную переменную для эффектов HYPO**

Удалить использование `@CPNL::ENV_VARS::hypo_effects`.

## **Измененный код (ключевые фрагменты):**

```perl
# Удаляем специальные запросы для HYPO
# my ${cpnl_update_hypo} = CPNL::COMMON::prepare_query($CPNL::SQL::req_update_params_hypo);
# my ${cpnl_delete_hypo} = CPNL::COMMON::prepare_query($CPNL::SQL::req_delete_hypo_lines);

# Удаляем блок чтения трансформации CVID для HYPO
# my %hypo_cvid_transco_hash;
# ... код чтения ...

# В основном цикле обработки изменяем логику:

# Вместо специальной обработки HYPO при изменении CVID:
if ($flag_differences_hypo_cvid_found == 1 ) {
  # УДАЛЯЕМ этот блок полностью
}

# Изменяем условие обновления:
# Вместо:
# if ($new_filter_params_hash{'RunType'} ne 'HYPO') {
# На:
if (1) { # Все типы обрабатываются одинаково
  ${cpnl_update}->bind_param(1 , $new_filter_params_hash{'Priority'});
  # ... остальные параметры ...
  ${cpnl_update}->execute();
}

# В блоке создания новых записей:
if ($new_filter_params_hash{'RunType'} eq 'HYPO') {
  # Обрабатываем как обычную запись, без создания multiple effects
  $new_id = $CPNL::COMMON::DbConnection->selectrow_array($cpnl_get_new_max_tasks_id);
  ${cpnl_insert}->bind_param(1 , $new_id);
  ${cpnl_insert}->bind_param(11, $new_filter_params_hash{'CVID'});
  ${cpnl_insert}->bind_param(27, ''); # EffectId пустой
  ${cpnl_insert}->execute();
}
else {
  # Существующая логика для других типов
  $new_id = $CPNL::COMMON::DbConnection->selectrow_array($cpnl_get_new_max_tasks_id);
  ${cpnl_insert}->bind_param(1 , $new_id);
  ${cpnl_insert}->execute();
}
```

## **Последствия изменений:**

1. **История для HYPO** будет сохраняться так же, как для PL
2. **Упрощение кода** - меньше специальных случаев
3. **Единообразие обработки** - меньше ошибок и сложности поддержки
4. **CVID для HYPO** будет обновляться, а не создаваться заново

## **Важные замечания:**

1. Проверьте, что SQL-запросы `req_update_params` поддерживают обновление всех полей для HYPO
2. Убедитесь, что в базе данных нет ограничений, которые могут нарушиться при таких изменениях
3. Протестируйте изменения на тестовой среде перед внедрением в production
4. Возможно, потребуется миграция данных для существующих записей HYPO

Эти изменения обеспечат одинаковую обработку и сохранение истории для RunType 'HYPO' и 'PL', упрощая поддержку и уменьшая количество кода.

