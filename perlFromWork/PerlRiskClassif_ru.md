# Работа с RiskClassification в скриптах create/update

## Prompt:
_появился новый параметр `riskClassification`. Одновременно появилась новая таблица в DB - SRM_RiskClassif которая содержит в себе всего 2 поля TaskId который связан с TaskId в других таблицах и колонка RiskCassification котороя соответствует каждому taskId. Создай новую функцию `insertIntoRiskClassif` которая будет обновлять или вставлять новые данные в таблицу SRM_Riskclassif на основании полученных вводных параметров. Предложи место вызова этого метода в основном скрипте. Добавь подробные объяснения._

Отличная задача! Давайте создадим новую функцию `insertIntoRiskClassif` и интегрируем ее в скрипт.

## Новая функция для работы с SRM_RiskClassif

```perl
sub insertIntoRiskClassif(\$\$\$) {
    my ($jobId, $taskId, $riskClassification) = @_;
    
    print "\n insertIntoRiskClassif(): JobId = $jobId, TaskId = $taskId, RiskClassification = $riskClassification\n";
    
    # Проверяем, существует ли уже запись для этого TaskId
    my $existingRiskClassif = undef;
    my $sqlCheckExisting = $dbh->prepare(qq{SELECT RiskClassification FROM SRM_RiskClassif WHERE TaskId = ?})
        or die "Couldn't prepare statement: $dbh->errstr\n";
    $sqlCheckExisting->execute($taskId);
    $sqlCheckExisting->bind_columns(\$existingRiskClassif);
    $sqlCheckExisting->fetch;
    
    if (defined $existingRiskClassif) {
        # Запись существует - обновляем
        print "Updating existing RiskClassification for TaskId $taskId: '$existingRiskClassif' -> '$riskClassification'\n";
        my $sqlUpdate = $dbh->prepare(qq{UPDATE SRM_RiskClassif SET RiskClassification = ? WHERE TaskId = ?})
            or die "Couldn't prepare update statement: $dbh->errstr\n";
        $sqlUpdate->execute($riskClassification, $taskId)
            or die "Update SRM_RiskClassif failed: $dbh->errstr\n";
    } else {
        # Записи нет - вставляем новую
        print "Inserting new RiskClassification for TaskId $taskId: '$riskClassification'\n";
        my $sqlInsert = $dbh->prepare(qq{INSERT INTO SRM_RiskClassif(TaskId, RiskClassification) VALUES(?, ?)})
            or die "Couldn't prepare insert statement: $dbh->errstr\n";
        $sqlInsert->execute($taskId, $riskClassification)
            or die "Insert into SRM_RiskClassif failed: $dbh->errstr\n";
    }
}
```

## Место вызова в основном скрипте

Лучшее место для вызова этой функции - **после успешной вставки задачи и получения `taskId`**, но **до вставки групп принадлежности**.

Конкретно, вставьте вызов после этой строки:
```perl
$taskId = &getTaskId($jobId, $taskTable, $filter, $suffix);
```

И до этого вызова:
```perl
&insertCopyTo($jobId, $taskId, @copyTo);
```

Вот как будет выглядеть измененный блок кода:

```perl
# ... существующий код ...
$taskId = &getTaskId($jobId, $taskTable, $filter, $suffix);
print "Generated TaskID is $taskId  \n";

# НОВЫЙ ВЫЗОВ: Вставка/обновление классификации рисков
&insertIntoRiskClassif($jobId, $taskId, $riskClassification);

&insertCopyTo($jobId, $taskId, @copyTo);
# ... продолжение существующего кода ...
```

## Полное объяснение решения

### Почему именно это место?

1. **`taskId` уже получен** - функция требует `taskId`, который генерируется базой данных при вставке задачи
2. **Логическая последовательность** - сначала создаем задачу, затем настраиваем ее атрибуты (классификация рисков), затем связи (копирования, группы)
3. **Целостность транзакции** - все операции выполняются в рамках одной логической единицы работы
4. **Обработка ошибок** - если вставка классификации рисков fail, вся операция будет откатана благодаря `RaiseError => 1`

### Особенности реализации функции

1. **UPSERT логика** - функция проверяет существование записи и либо обновляет, либо вставляет новую
2. **Подробное логирование** - выводит информацию о выполняемых операциях
3. **Обработка ошибок** - использует ту же стратегию, что и остальной код
4. **Согласованность** - следует тем же шаблонам именования и структуры, что и другие функции

### Дополнительные улучшения

Вы также можете добавить проверку на пустое значение `$riskClassification`:

```perl
# После получения taskId, перед вызовом insertIntoRiskClassif
if (defined $riskClassification && $riskClassification ne "") {
    &insertIntoRiskClassif($jobId, $taskId, $riskClassification);
} else {
    print "Warning: RiskClassification is empty for TaskId $taskId - skipping\n";
}
```

### Альтернативные места вызова (менее предпочтительные)

1. **Внутри `insertBelongsTo`** - не подходит, так как классификация рисков относится к задаче, а не к группе
2. **Перед получением `taskId`** - невозможно, так как нужен `taskId`
3. **В самом конце обработки строки** - нарушает логическую последовательность операций

Это решение обеспечивает корректное сохранение классификации рисков для каждой задачи в соответствии с входными данными из CSV файла.