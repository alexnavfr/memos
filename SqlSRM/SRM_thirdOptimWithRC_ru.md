# Добавляем в запрос RiskClassification

## Prompt:
_теперь в работу была добавлена новая таблица SRM_RiskClassif в которой всего 2 колонки - TaskId которая соответствует такой же колонке в таблице SRM_Tasks_HedgeAPI и RiskClassification. Добавь новую колонку в запрос так чтобы мы видели в результате и данные по RiskClassification._

Добавляем колонку `RiskClassification` из новой таблицы `SRM_RiskClassif`. Использую LEFT JOIN, так как записи могут отсутствовать:

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
    -- НОВАЯ КОЛОНКА: RiskClassification
    rc.RiskClassification AS "RiskClassification",
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
-- НОВЫЙ LEFT JOIN для таблицы SRM_RiskClassif
LEFT JOIN SRM_RiskClassif rc ON rc.TaskId = t.TaskId
LEFT JOIN SRM_Manager M ON M.JobId = t.JobId 
    AND M.TaskId = t.TaskId 
    AND M.ReportDate = '%DATE%'
WHERE t.JobId = '%JOBID%'
    AND j.ACTIVE = 1
    AND t.Active = 1
ORDER BY t.filter, t.suffix ASC;
```

## Если нужно добавить индекс для новой таблицы:
```sql
-- Рекомендуемый индекс для SRM_RiskClassif
CREATE INDEX IDX_RISKCLASSIF_TASKID ON SRM_RiskClassif(TaskId);

-- Композитный индекс, если часто фильтруем по JobId (хотя его нет в таблице)
-- Если TaskId уникален в SRM_RiskClassif, можно использовать UNIQUE индекс:
CREATE UNIQUE INDEX IDX_RISKCLASSIF_UNIQUE_TASK ON SRM_RiskClassif(TaskId);
```

## Версия с хинтами для оптимизации нового JOIN:
```sql
SELECT /*+ LEADING(t j) USE_NL(rc) INDEX(rc IDX_RISKCLASSIF_TASKID) */
    -- все поля, как выше
FROM SRM_Tasks_HedgeAPI t
-- ... остальные JOIN
LEFT JOIN SRM_RiskClassif rc ON rc.TaskId = t.TaskId
-- ... остальной запрос
```

## Альтернативный вариант - добавить в подзапрос:
Если нужно гарантировать только одну запись на TaskId:

```sql
-- Вместо простого LEFT JOIN можно использовать коррелированный подзапрос
-- если в SRM_RiskClassif может быть несколько записей на TaskId
(
    SELECT RiskClassification 
    FROM SRM_RiskClassif 
    WHERE TaskId = t.TaskId 
    AND ROWNUM = 1  -- берем только первую запись
) AS "RiskClassification",
```

## Если нужно агрегировать несколько значений RiskClassification:
```sql
-- Если на один TaskId может быть несколько классификаций
LEFT JOIN (
    SELECT 
        TaskId,
        LISTAGG(RiskClassification, ', ') WITHIN GROUP (ORDER BY RiskClassification) AS RiskClassifications
    FROM SRM_RiskClassif
    GROUP BY TaskId
) rc ON rc.TaskId = t.TaskId
-- тогда в SELECT использовать rc.RiskClassifications вместо rc.RiskClassification
```

Добавление нового LEFT JOIN не должно существенно повлиять на производительность, особенно если есть индекс на `SRM_RiskClassif.TaskId`.

## Prompt 2:
_Приведи запрос полностью, так чтобы его можно было сразу использовать._

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
    rc.RiskClassification AS "RiskClassification",
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
LEFT JOIN SRM_RiskClassif rc ON rc.TaskId = t.TaskId
LEFT JOIN SRM_Manager M ON M.JobId = t.JobId 
    AND M.TaskId = t.TaskId 
    AND M.ReportDate = '%DATE%'
WHERE t.JobId = '%JOBID%'
    AND j.ACTIVE = 1
    AND t.Active = 1
ORDER BY t.filter, t.suffix ASC;
```

## Если нужно добавить хинты для оптимизации:
```sql
SELECT /*+ LEADING(t) USE_NL(j) USE_HASH(tg rc M) */
    -- все поля как выше
FROM SRM_Tasks_HedgeAPI t
-- остальной запрос без изменений
```

## Для создания индекса (если еще не создан):
```sql
CREATE INDEX IDX_SRM_RISKCLASSIF_TASKID ON SRM_RiskClassif(TaskId);
```

**Примечание:** 
1. Замените `%JOBID%` и `%DATE%` на фактические значения параметров
2. Новая колонка `RiskClassification` добавлена после `ConfigFile`
3. Используется `LEFT JOIN`, так как записи в `SRM_RiskClassif` могут отсутствовать для некоторых задач

