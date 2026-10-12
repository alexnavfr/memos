# оригинальный запрос к базе из проекта

```sql
SELECT
    CASE WHEN EXISTS ( SELECT 1 FROM SRM_BelongTo b, SRM_Group g WHERE  t.TaskId = b.TaskId AND t.JobId = b.JobId AND g.GroupId = b.GroupId AND g.TopPrio = 1 )
    THEN
    'Y'
    ELSE
    'N'
    END "Top"  ,
    t.JobId "JobId", j.Closing "Closing", t.Filter "Filter", ' ' "Desk", ' ' "Book"  ,t.Suffix "Suffix",t.CVID ,t.PGID ,t.ConfigFile "ConfigFile",
    CASE WHEN t.ACTIVE = 1
    THEN
    CASE WHEN M.STATUS IS NULL
    THEN
    'NOT LAUNCHED'
    ELSE
    M.STATUS
    END
    ELSE
    'INACTIVE'
    END "Status"  ,
    UTILS.CONVERT_TO_CHAR(M.StartTime,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_CHAR(M.StartTime,8,p_style=>108) "Start"  ,
    UTILS.CONVERT_TO_CHAR(M.EndTime,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_CHAR(M.EndTime,8,p_style=>108) "End"  ,
    CASE
    WHEN UTILS.CONVERT_TO_VARCHAR2(M.StartTime,8,p_style=>21) > '00/01/01'
    THEN
    CASE WHEN UTILS.CONVERT_TO_VARCHAR2(M.EndTime,8,p_style=>21) > '00/01/01'
    THEN
    UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('SECOND', utils.datediff('SS', M.StartTime, M.EndTime), '1970-01-01'),8,p_style=>108)
    ELSE
    ' '
    END
    ELSE
    ' '
    END "Elapsed"  ,
    UTILS.CONVERT_TO_CHAR(M.RelaunchStartTime,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_CHAR(M.RelaunchStartTime,8,p_style=>108) "RelaunchStart"  ,
    UTILS.CONVERT_TO_CHAR(M.RelaunchEndTime,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_CHAR(M.RelaunchEndTime,8,p_style=>108) "RelaunchEnd"  ,
    CASE
    WHEN UTILS.CONVERT_TO_VARCHAR2(M.RelaunchStartTime,8,p_style=>21) > '00/01/01'
    THEN
    CASE WHEN UTILS.CONVERT_TO_VARCHAR2(M.RelaunchEndTime,8,p_style=>21) > '00/01/01'
    THEN
    UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('SECOND', utils.datediff('SS', M.RelaunchStartTime, M.RelaunchEndTime), '1970-01-01'),8,p_style=>108)
    ELSE
    ' '
    END
    ELSE
    ' '
    END "RelaunchElapsed"  ,
    t.Autopack "Autopack", M.TaskCount "SumTasks",' ' "Destination",' ' "Group"  ,
    t.Weight "Weight", j.Priority "Priority",  t.PortrepType "PortrepType",
    UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('SECOND', M.MeanTaskDuration, '1970-01-01'),8,p_style=>108) "Mean TaskDuration"  ,
    UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('SECOND', M.StdDevTaskDuration, '1970-01-01'),8,p_style=>108) "StdDev TaskDuration"  ,
    UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('SECOND', M.MaxTaskDuration, '1970-01-01'),8,p_style=>108) "Max TaskDuration"  ,
    CASE
    WHEN M.TotalTaskDuration IS NULL THEN ' '

    ELSE UTILS.CONVERT_TO_VARCHAR2(M.TotalTaskDuration,1000)

    END "Total TaskDuration"  ,
    t.EnvId "EnvId",
    UTILS.CONVERT_TO_VARCHAR2(t.Required_End,12,p_style=>108) "Required End" ,
    UTILS.CONVERT_TO_VARCHAR2(t.Wished_End,12,p_style=>108) "Wished End"  ,
    CASE
    WHEN IsConfigFileXML = 1 THEN 'Y'
    ELSE 'N'
    END "IsConfigFileXML"  ,
    CASE
    WHEN ResultByTrade = 1 THEN 'Y'
    ELSE 'N'
    END "ByTrade"  ,
    CASE
    WHEN ResultByAsset = 1 THEN 'Y'
    ELSE 'N'
    END "ByAsset"  ,
    t.ARMVector "ARMVector",
    t.AddRisk "AddRisk",
    t.Discriminator "Discriminator",
    M.ResultServerName "ResultServerName",
    M.ResultDir "ResultDir",
    M.ResultFile "ResultFile",
    M.ErrorDir "ErrorDir",
    M.ERRORFILE "ErrorFile",
    M.ErrorMessage "ErrorMessage",
    M.AsOfDate "AsOfDate",
    t.TaskId "TaskId",
    t.RunDate "RunDate",
    t.ReportDate "ReportDate"
    FROM SRM_Tasks_HedgeAPI  t
    JOIN SRM_Jobs j   ON t.JobId = j.JobId

    AND t.JobId = '%JOBID%'
    AND j.ACTIVE = 1
    AND t.Active = 1
    LEFT JOIN SRM_Manager M   ON M.JobId = t.JobId

    AND M.TaskId = t.TaskId
    AND M.ReportDate = '%DATE%'
Order by t.filter, t.suffix ASC;
```

## Prompt:
_Oracle 19. Появилась новая таблица в DB - SRM_RiskClassif которая содержит в себе всего 2 поля TaskId который связан с TaskId в других таблицах и колонка RiskCassification котороя соответствует каждому taskId. Необходимо изменить существуюший запрос так чтобы он выводил и значение RiskClassification вместе с остальными полями, такими как "ReportDate" и другие_

Для добавления поля `RiskClassification` из таблицы `SRM_RiskClassif` в существующий запрос, вам нужно выполнить следующие изменения:

1. Добавить `LEFT JOIN` с таблицей `SRM_RiskClassif`
2. Добавить поле `RiskClassification` в список выборки

Вот модифицированный запрос:

```sql
SELECT
    CASE WHEN EXISTS ( SELECT 1 FROM SRM_BelongTo b, SRM_Group g WHERE  t.TaskId = b.TaskId AND t.JobId = b.JobId AND g.GroupId = b.GroupId AND g.TopPrio = 1 )
    THEN
    'Y'
    ELSE
    'N'
    END "Top"  ,
    t.JobId "JobId", j.Closing "Closing", t.Filter "Filter", ' ' "Desk", ' ' "Book"  ,t.Suffix "Suffix",t.CVID ,t.PGID ,t.ConfigFile "ConfigFile",
    CASE WHEN t.ACTIVE = 1
    THEN
    CASE WHEN M.STATUS IS NULL
    THEN
    'NOT LAUNCHED'
    ELSE
    M.STATUS
    END
    ELSE
    'INACTIVE'
    END "Status"  ,
    UTILS.CONVERT_TO_CHAR(M.StartTime,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_CHAR(M.StartTime,8,p_style=>108) "Start"  ,
    UTILS.CONVERT_TO_CHAR(M.EndTime,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_CHAR(M.EndTime,8,p_style=>108) "End"  ,
    CASE
    WHEN UTILS.CONVERT_TO_VARCHAR2(M.StartTime,8,p_style=>21) > '00/01/01'
    THEN
    CASE WHEN UTILS.CONVERT_TO_VARCHAR2(M.EndTime,8,p_style=>21) > '00/01/01'
    THEN
    UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('SECOND', utils.datediff('SS', M.StartTime, M.EndTime), '1970-01-01'),8,p_style=>108)
    ELSE
    ' '
    END
    ELSE
    ' '
    END "Elapsed"  ,
    UTILS.CONVERT_TO_CHAR(M.RelaunchStartTime,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_CHAR(M.RelaunchStartTime,8,p_style=>108) "RelaunchStart"  ,
    UTILS.CONVERT_TO_CHAR(M.RelaunchEndTime,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_CHAR(M.RelaunchEndTime,8,p_style=>108) "RelaunchEnd"  ,
    CASE
    WHEN UTILS.CONVERT_TO_VARCHAR2(M.RelaunchStartTime,8,p_style=>21) > '00/01/01'
    THEN
    CASE WHEN UTILS.CONVERT_TO_VARCHAR2(M.RelaunchEndTime,8,p_style=>21) > '00/01/01'
    THEN
    UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('SECOND', utils.datediff('SS', M.RelaunchStartTime, M.RelaunchEndTime), '1970-01-01'),8,p_style=>108)
    ELSE
    ' '
    END
    ELSE
    ' '
    END "RelaunchElapsed"  ,
    t.Autopack "Autopack", M.TaskCount "SumTasks",' ' "Destination",' ' "Group"  ,
    t.Weight "Weight", j.Priority "Priority",  t.PortrepType "PortrepType",
    UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('SECOND', M.MeanTaskDuration, '1970-01-01'),8,p_style=>108) "Mean TaskDuration"  ,
    UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('SECOND', M.StdDevTaskDuration, '1970-01-01'),8,p_style=>108) "StdDev TaskDuration"  ,
    UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('SECOND', M.MaxTaskDuration, '1970-01-01'),8,p_style=>108) "Max TaskDuration"  ,
    CASE
    WHEN M.TotalTaskDuration IS NULL THEN ' '
    ELSE UTILS.CONVERT_TO_VARCHAR2(M.TotalTaskDuration,1000)
    END "Total TaskDuration"  ,
    t.EnvId "EnvId",
    UTILS.CONVERT_TO_VARCHAR2(t.Required_End,12,p_style=>108) "Required End" ,
    UTILS.CONVERT_TO_VARCHAR2(t.Wished_End,12,p_style=>108) "Wished End"  ,
    CASE
    WHEN IsConfigFileXML = 1 THEN 'Y'
    ELSE 'N'
    END "IsConfigFileXML"  ,
    CASE
    WHEN ResultByTrade = 1 THEN 'Y'
    ELSE 'N'
    END "ByTrade"  ,
    CASE
    WHEN ResultByAsset = 1 THEN 'Y'
    ELSE 'N'
    END "ByAsset"  ,
    t.ARMVector "ARMVector",
    t.AddRisk "AddRisk",
    t.Discriminator "Discriminator",
    M.ResultServerName "ResultServerName",
    M.ResultDir "ResultDir",
    M.ResultFile "ResultFile",
    M.ErrorDir "ErrorDir",
    M.ERRORFILE "ErrorFile",
    M.ErrorMessage "ErrorMessage",
    M.AsOfDate "AsOfDate",
    t.TaskId "TaskId",
    t.RunDate "RunDate",
    t.ReportDate "ReportDate",
    rc.RiskClassification "RiskClassification"  -- Добавлено новое поле
FROM SRM_Tasks_HedgeAPI t
JOIN SRM_Jobs j ON t.JobId = j.JobId
    AND t.JobId = '%JobId%'
    AND j.ACTIVE = 1
    AND t.Active = 1
LEFT JOIN SRM_Manager M ON M.JobId = t.JobId
    AND M.TaskId = t.TaskId
    AND M.ReportDate = '%DATE%'
LEFT JOIN SRM_RiskClassif rc ON t.TaskId = rc.TaskId  -- Добавлен JOIN с новой таблицей
ORDER BY t.filter, t.suffix ASC
```

**Основные изменения:**

1. **Добавлен LEFT JOIN** с новой таблицей:
   ```sql
   LEFT JOIN SRM_RiskClassif rc ON t.TaskId = rc.TaskId
   ```

2. **Добавлено поле** в SELECT:
   ```sql
   rc.RiskClassification "RiskClassification"
   ```

Использование `LEFT JOIN` гарантирует, что все записи из основной таблицы `SRM_Tasks_HedgeAPI` будут включены в результат, даже если для некоторых TaskId нет соответствующих записей в таблице `SRM_RiskClassif`. В таких случаях поле `RiskClassification` будет содержать `NULL`.

