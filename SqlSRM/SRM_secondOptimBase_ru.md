# Вторая итерация оптимизации

## Prompt:
_при выполнении запроса была получена ошибка "Ora-00904: "J", "PRIORITY": invalid identifier
00904.00000 - "%s: invalid identifier"_

Ошибка возникает потому, что в CTE `filtered_tasks` я не включил поле `Priority` из таблицы `SRM_Jobs`. Вот исправленная версия:

```sql
WITH filtered_tasks AS (
    SELECT /*+ MATERIALIZE */
        t.*,
        j.Closing,
        j.Priority  -- Добавлено это поле
    FROM SRM_Tasks_HedgeAPI t
    JOIN SRM_Jobs j ON t.JobId = j.JobId
    WHERE t.JobId = '%JOBID%'
        AND j.ACTIVE = 1
        AND t.Active = 1
),
top_groups AS (
    SELECT /*+ MATERIALIZE */
        DISTINCT b.TaskId, b.JobId
    FROM SRM_BelongTo b
    JOIN SRM_Group g ON g.GroupId = b.GroupId
    WHERE g.TopPrio = 1
)
SELECT
    CASE WHEN tg.TaskId IS NOT NULL THEN 'Y' ELSE 'N' END AS "Top",
    ft.JobId AS "JobId",
    ft.Closing AS "Closing",
    ft.Filter AS "Filter",
    ' ' AS "Desk",
    ' ' AS "Book",
    ft.Suffix AS "Suffix",
    ft.CVID,
    ft.PGID,
    ft.ConfigFile AS "ConfigFile",
    CASE 
        WHEN ft.ACTIVE = 1 THEN
            COALESCE(M.STATUS, 'NOT LAUNCHED')
        ELSE 'INACTIVE'
    END AS "Status",
    UTILS.CONVERT_TO_CHAR(M.StartTime,10,p_style=>103) || ' ' || 
        UTILS.CONVERT_TO_CHAR(M.StartTime,8,p_style=>108) AS "Start",
    UTILS.CONVERT_TO_CHAR(M.EndTime,10,p_style=>103) || ' ' || 
        UTILS.CONVERT_TO_CHAR(M.EndTime,8,p_style=>108) AS "End",
    CASE
        WHEN M.StartTime IS NOT NULL AND M.EndTime IS NOT NULL THEN
            UTILS.CONVERT_TO_VARCHAR2(
                utils.dateadd('SECOND', utils.datediff('SS', M.StartTime, M.EndTime), '1970-01-01'),
                8,
                p_style=>108
            )
        ELSE ' '
    END AS "Elapsed",
    UTILS.CONVERT_TO_CHAR(M.RelaunchStartTime,10,p_style=>103) || ' ' || 
        UTILS.CONVERT_TO_CHAR(M.RelaunchStartTime,8,p_style=>108) AS "RelaunchStart",
    UTILS.CONVERT_TO_CHAR(M.RelaunchEndTime,10,p_style=>103) || ' ' || 
        UTILS.CONVERT_TO_CHAR(M.RelaunchEndTime,8,p_style=>108) AS "RelaunchEnd",
    CASE
        WHEN M.RelaunchStartTime IS NOT NULL AND M.RelaunchEndTime IS NOT NULL THEN
            UTILS.CONVERT_TO_VARCHAR2(
                utils.dateadd('SECOND', utils.datediff('SS', M.RelaunchStartTime, M.RelaunchEndTime), '1970-01-01'),
                8,
                p_style=>108
            )
        ELSE ' '
    END AS "RelaunchElapsed",
    ft.Autopack AS "Autopack",
    M.TaskCount AS "SumTasks",
    ' ' AS "Destination",
    ' ' AS "Group",
    ft.Weight AS "Weight",
    ft.Priority AS "Priority",  -- Исправлено с j.Priority на ft.Priority
    ft.PortrepType AS "PortrepType",
    UTILS.CONVERT_TO_VARCHAR2(
        utils.dateadd('SECOND', M.MeanTaskDuration, '1970-01-01'),
        8,
        p_style=>108
    ) AS "Mean TaskDuration",
    UTILS.CONVERT_TO_VARCHAR2(
        utils.dateadd('SECOND', M.StdDevTaskDuration, '1970-01-01'),
        8,
        p_style=>108
    ) AS "StdDev TaskDuration",
    UTILS.CONVERT_TO_VARCHAR2(
        utils.dateadd('SECOND', M.MaxTaskDuration, '1970-01-01'),
        8,
        p_style=>108
    ) AS "Max TaskDuration",
    COALESCE(
        UTILS.CONVERT_TO_VARCHAR2(M.TotalTaskDuration,1000),
        ' '
    ) AS "Total TaskDuration",
    ft.EnvId AS "EnvId",
    UTILS.CONVERT_TO_VARCHAR2(ft.Required_End,12,p_style=>108) AS "Required End",
    UTILS.CONVERT_TO_VARCHAR2(ft.Wished_End,12,p_style=>108) AS "Wished End",
    CASE WHEN ft.IsConfigFileXML = 1 THEN 'Y' ELSE 'N' END AS "IsConfigFileXML",
    CASE WHEN ft.ResultByTrade = 1 THEN 'Y' ELSE 'N' END AS "ByTrade",
    CASE WHEN ft.ResultByAsset = 1 THEN 'Y' ELSE 'N' END AS "ByAsset",
    ft.ARMVector AS "ARMVector",
    ft.AddRisk AS "AddRisk",
    ft.Discriminator AS "Discriminator",
    M.ResultServerName AS "ResultServerName",
    M.ResultDir AS "ResultDir",
    M.ResultFile AS "ResultFile",
    M.ErrorDir AS "ErrorDir",
    M.ERRORFILE AS "ErrorFile",
    M.ErrorMessage AS "ErrorMessage",
    M.AsOfDate AS "AsOfDate",
    ft.TaskId AS "TaskId",
    ft.RunDate AS "RunDate",
    ft.ReportDate AS "ReportDate"
FROM filtered_tasks ft
LEFT JOIN top_groups tg ON ft.TaskId = tg.TaskId AND ft.JobId = tg.JobId
LEFT JOIN SRM_Manager M ON M.JobId = ft.JobId 
    AND M.TaskId = ft.TaskId 
    AND M.ReportDate = '%DATE%'
ORDER BY ft.filter, ft.suffix ASC;
```

**Ключевые исправления:**

1. **В CTE `filtered_tasks` добавил поле `j.Priority`**:
```sql
j.Closing,
j.Priority  -- Добавлено это поле
```

2. **В основном SELECT изменил ссылку с `j.Priority` на `ft.Priority`**:
```sql
ft.Priority AS "Priority",  -- Было: j.Priority AS "Priority"
```

## Альтернативная версия без CTE (если возникнут другие проблемы):

```sql
SELECT
    CASE WHEN tg.TaskId IS NOT NULL THEN 'Y' ELSE 'N' END AS "Top",
    t.JobId AS "JobId",
    j.Closing AS "Closing",
    t.Filter AS "Filter",
    ' ' AS "Desk",
    ' ' AS "Book",
    t.Suffix AS "Suffix",
    t.CVID,
    t.PGID,
    t.ConfigFile AS "ConfigFile",
    CASE 
        WHEN t.ACTIVE = 1 THEN
            COALESCE(M.STATUS, 'NOT LAUNCHED')
        ELSE 'INACTIVE'
    END AS "Status",
    UTILS.CONVERT_TO_CHAR(M.StartTime,10,p_style=>103) || ' ' || 
        UTILS.CONVERT_TO_CHAR(M.StartTime,8,p_style=>108) AS "Start",
    UTILS.CONVERT_TO_CHAR(M.EndTime,10,p_style=>103) || ' ' || 
        UTILS.CONVERT_TO_CHAR(M.EndTime,8,p_style=>108) AS "End",
    CASE
        WHEN M.StartTime IS NOT NULL AND M.EndTime IS NOT NULL THEN
            UTILS.CONVERT_TO_VARCHAR2(
                utils.dateadd('SECOND', utils.datediff('SS', M.StartTime, M.EndTime), '1970-01-01'),
                8,
                p_style=>108
            )
        ELSE ' '
    END AS "Elapsed",
    UTILS.CONVERT_TO_CHAR(M.RelaunchStartTime,10,p_style=>103) || ' ' || 
        UTILS.CONVERT_TO_CHAR(M.RelaunchStartTime,8,p_style=>108) AS "RelaunchStart",
    UTILS.CONVERT_TO_CHAR(M.RelaunchEndTime,10,p_style=>103) || ' ' || 
        UTILS.CONVERT_TO_CHAR(M.RelaunchEndTime,8,p_style=>108) AS "RelaunchEnd",
    CASE
        WHEN M.RelaunchStartTime IS NOT NULL AND M.RelaunchEndTime IS NOT NULL THEN
            UTILS.CONVERT_TO_VARCHAR2(
                utils.dateadd('SECOND', utils.datediff('SS', M.RelaunchStartTime, M.RelaunchEndTime), '1970-01-01'),
                8,
                p_style=>108
            )
        ELSE ' '
    END AS "RelaunchElapsed",
    t.Autopack AS "Autopack",
    M.TaskCount AS "SumTasks",
    ' ' AS "Destination",
    ' ' AS "Group",
    t.Weight AS "Weight",
    j.Priority AS "Priority",
    t.PortrepType AS "PortrepType",
    UTILS.CONVERT_TO_VARCHAR2(
        utils.dateadd('SECOND', M.MeanTaskDuration, '1970-01-01'),
        8,
        p_style=>108
    ) AS "Mean TaskDuration",
    UTILS.CONVERT_TO_VARCHAR2(
        utils.dateadd('SECOND', M.StdDevTaskDuration, '1970-01-01'),
        8,
        p_style=>108
    ) AS "StdDev TaskDuration",
    UTILS.CONVERT_TO_VARCHAR2(
        utils.dateadd('SECOND', M.MaxTaskDuration, '1970-01-01'),
        8,
        p_style=>108
    ) AS "Max TaskDuration",
    COALESCE(
        UTILS.CONVERT_TO_VARCHAR2(M.TotalTaskDuration,1000),
        ' '
    ) AS "Total TaskDuration",
    t.EnvId AS "EnvId",
    UTILS.CONVERT_TO_VARCHAR2(t.Required_End,12,p_style=>108) AS "Required End",
    UTILS.CONVERT_TO_VARCHAR2(t.Wished_End,12,p_style=>108) AS "Wished End",
    CASE WHEN t.IsConfigFileXML = 1 THEN 'Y' ELSE 'N' END AS "IsConfigFileXML",
    CASE WHEN t.ResultByTrade = 1 THEN 'Y' ELSE 'N' END AS "ByTrade",
    CASE WHEN t.ResultByAsset = 1 THEN 'Y' ELSE 'N' END AS "ByAsset",
    t.ARMVector AS "ARMVector",
    t.AddRisk AS "AddRisk",
    t.Discriminator AS "Discriminator",
    M.ResultServerName AS "ResultServerName",
    M.ResultDir AS "ResultDir",
    M.ResultFile AS "ResultFile",
    M.ErrorDir AS "ErrorDir",
    M.ERRORFILE AS "ErrorFile",
    M.ErrorMessage AS "ErrorMessage",
    M.AsOfDate AS "AsOfDate",
    t.TaskId AS "TaskId",
    t.RunDate AS "RunDate",
    t.ReportDate AS "ReportDate"
FROM SRM_Tasks_HedgeAPI t
JOIN SRM_Jobs j ON t.JobId = j.JobId
LEFT JOIN (
    SELECT DISTINCT b.TaskId, b.JobId
    FROM SRM_BelongTo b
    JOIN SRM_Group g ON g.GroupId = b.GroupId
    WHERE g.TopPrio = 1
) tg ON t.TaskId = tg.TaskId AND t.JobId = tg.JobId
LEFT JOIN SRM_Manager M ON M.JobId = t.JobId 
    AND M.TaskId = t.TaskId 
    AND M.ReportDate = '%DATE%'
WHERE t.JobId = '%JOBID%'
    AND j.ACTIVE = 1
    AND t.Active = 1
ORDER BY t.filter, t.suffix ASC;
```

Эта версия проще и может быть более понятна оптимизатору Oracle. Основное улучшение - замена коррелированного подзапроса на LEFT JOIN с подзапросом.

Отлично! Рад, что упрощенный вариант работает быстрее. 

## Дополнительные оптимизации, которые можно применить, если нужна еще большая производительность:

### 1. **Использование NO_PARALLEL для стабильности плана выполнения**
```sql
SELECT /*+ NO_PARALLEL LEADING(t j) USE_NL(M) INDEX(t IDX_TASKS_JOB_ACTIVE) */
    CASE WHEN tg.TaskId IS NOT NULL THEN 'Y' ELSE 'N' END AS "Top",
    -- остальные поля
```

### 2. **Оптимизация для конкретных значений параметров**
Если значения `%JOBID%` и `%DATE%` часто повторяются, можно использовать **Result Cache**:

```sql
SELECT /*+ RESULT_CACHE */
    CASE WHEN tg.TaskId IS NOT NULL THEN 'Y' ELSE 'N' END AS "Top",
    -- остальные поля
```

### 3. **Материализованное представление для агрегированных данных**
Если данные не часто меняются:

```sql
CREATE MATERIALIZED VIEW MV_SRM_TASK_INFO
REFRESH COMPLETE ON DEMAND
AS
SELECT
    t.JobId,
    t.TaskId,
    t.Filter,
    t.Suffix,
    -- остальные часто используемые поля
FROM SRM_Tasks_HedgeAPI t
WHERE t.Active = 1;
```

### 4. **Проверка плана выполнения для дальнейших оптимизаций**
```sql
-- 1. Получить SQL_ID запроса
SELECT sql_id, sql_text 
FROM v$sql 
WHERE sql_text LIKE '%SRM_Tasks_HedgeAPI%' 
AND sql_text NOT LIKE '%v$sql%';

-- 2. Показать план выполнения
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_AWR('ваш_sql_id'));
```

### 5. **Оптимизация функции UTILS.CONVERT_TO_CHAR**
Если вызовы UTILS.CONVERT_TO_CHAR занимают много времени:
- Проверить, есть ли индексы на полях дат
- Рассмотреть возможность кэширования результатов функций
- Использовать встроенные функции Oracle, если они доступны

### 6. **Оптимизация ORDER BY**
Если сортировка занимает много времени:
```sql
-- Добавить покрывающий индекс
CREATE INDEX IDX_TASKS_SORT ON SRM_Tasks_HedgeAPI(filter, suffix, JobId, Active) 
INCLUDE (CVID, PGID, ConfigFile, Weight, ...);
```

## Мониторинг производительности:
```sql
-- Проверить статистику выполнения
SELECT * FROM V$SQL_MONITOR 
WHERE sql_text LIKE '%SRM_Tasks_HedgeAPI%'
ORDER BY last_refresh_time DESC;

-- Проверить использование индексов
SELECT * FROM V$OBJECT_USAGE 
WHERE table_name = 'SRM_TASKS_HEDGEAPI';
```

Если производительность все еще требует улучшения, можно:
1. **Анализировать статистику выполнения** через AWR отчеты
2. **Рассмотреть партиционирование** таблиц по полям `JobId` или `ReportDate`
3. **Использовать In-Memory** для часто запрашиваемых данных

У вас уже есть хорошая базовая оптимизация с индексами и улучшенным запросом!
