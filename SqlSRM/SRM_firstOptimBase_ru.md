# Первая оптимизация базового запроса

## Prompt:
_SQL. Oracle 19. Оптимизируй по скорости следующий запрос sql:_

Для оптимизации этого запроса в Oracle 19c, предлагаю следующие улучшения:

## 1. **Оптимизация коррелированного подзапроса в CASE**
Заменить коррелированный подзапрос на JOIN или использовать аналитическую функцию:

```sql
SELECT
    CASE WHEN b.TaskId IS NOT NULL THEN 'Y' ELSE 'N' END AS "Top",
    -- остальные поля
FROM SRM_Tasks_HedgeAPI t
JOIN SRM_Jobs j ON t.JobId = j.JobId
LEFT JOIN (
    SELECT DISTINCT b.TaskId, b.JobId
    FROM SRM_BelongTo b
    JOIN SRM_Group g ON g.GroupId = b.GroupId
    WHERE g.TopPrio = 1
) b ON t.TaskId = b.TaskId AND t.JobId = b.JobId
LEFT JOIN SRM_Manager M ON M.JobId = t.JobId 
    AND M.TaskId = t.TaskId 
    AND M.ReportDate = '%DATE%'
WHERE t.JobId = '%JOBID%'
    AND j.ACTIVE = 1
    AND t.Active = 1
ORDER BY t.filter, t.suffix ASC;
```

## 2. **Полная оптимизированная версия с улучшениями:**

```sql
WITH filtered_tasks AS (
    SELECT /*+ MATERIALIZE */
        t.*,
        j.Closing
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
    j.Priority AS "Priority",
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

## 3. **Дополнительные рекомендации по оптимизации:**

### Создание индексов (если их нет):
```sql
-- Для SRM_Tasks_HedgeAPI
CREATE INDEX IDX_TASKS_JOB_ACTIVE ON SRM_Tasks_HedgeAPI(JobId, Active);
CREATE INDEX IDX_TASKS_FILTER_SUFFIX ON SRM_Tasks_HedgeAPI(filter, suffix);

-- Для SRM_Jobs
CREATE INDEX IDX_JOBS_ACTIVE ON SRM_Jobs(JobId, Active);

-- Для SRM_BelongTo
CREATE INDEX IDX_BELONGTO_COMPOSITE ON SRM_BelongTo(TaskId, JobId, GroupId);

-- Для SRM_Group
CREATE INDEX IDX_GROUP_TOPPRIO ON SRM_Group(GroupId, TopPrio);

-- Для SRM_Manager
CREATE INDEX IDX_MANAGER_COMPOSITE ON SRM_Manager(JobId, TaskId, ReportDate);
```

### Анализ статистики:
```sql
-- Обновить статистику таблиц
EXEC DBMS_STATS.GATHER_TABLE_STATS(ownname => 'YOUR_SCHEMA', tabname => 'SRM_Tasks_HedgeAPI');
EXEC DBMS_STATS.GATHER_TABLE_STATS(ownname => 'YOUR_SCHEMA', tabname => 'SRM_Jobs');
EXEC DBMS_STATS.GATHER_TABLE_STATS(ownname => 'YOUR_SCHEMA', tabname => 'SRM_BelongTo');
EXEC DBMS_STATS.GATHER_TABLE_STATS(ownname => 'YOUR_SCHEMA', tabname => 'SRM_Group');
EXEC DBMS_STATS.GATHER_TABLE_STATS(ownname => 'YOUR_SCHEMA', tabname => 'SRM_Manager');
```

## 4. **Ключевые улучшения:**

1. **Убрал коррелированный подзапрос** - он выполнялся для каждой строки
2. **Использовал CTE** для предварительной фильтрации данных
3. **Добавил DISTINCT** для уменьшения дублирования в JOIN
4. **Оптимизировал CASE выражения** для лучшей читаемости
5. **Использовал COALESCE** вместо сложных CASE
6. **Вынес фильтрацию в WHERE** на более ранний этап

## 5. **Для проверки производительности:**
```sql
-- Включить трассировку
ALTER SESSION SET STATISTICS_LEVEL = ALL;

-- Выполнить запрос
-- Затем посмотреть план выполнения:
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
```

Эти изменения должны значительно ускорить выполнение запроса, особенно при большом количестве записей.
