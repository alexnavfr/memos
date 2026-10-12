# Попробуем оптимизировать для скорости и отформатируем для лучшего прочтения.

## Prompt:
_SQL. Задача оптимизировать запрос по скорости выполнения. Одновременно отформатируй запрос для улучшения понимания и читабельности._

Для оптимизации запроса и улучшения читабельности, внесем следующие изменения:

## Оптимизированная версия запроса

```sql
WITH belong_to_check AS (
    SELECT 
        1 AS check_result,
        b.TaskId,
        b.JobId
    FROM SRM_BelongTo b
    INNER JOIN SRM_Group g ON b.GroupId = g.GroupId
    WHERE g.TopPrio = 1
)
SELECT
    -- Top priority flag
    CASE WHEN EXISTS (
        SELECT 1 
        FROM belong_to_check bc 
        WHERE bc.TaskId = t.TaskId 
          AND bc.JobId = t.JobId
    ) THEN 'Y' ELSE 'N' END AS "Top",
    
    -- Basic task info
    t.JobId AS "JobId",
    j.Closing AS "Closing",
    t.Filter AS "Filter",
    ' ' AS "Desk",
    ' ' AS "Book",
    t.Suffix AS "Suffix",
    t.CVID,
    t.PGID,
    t.ConfigFile AS "ConfigFile",
    
    -- Status calculation
    CASE 
        WHEN t.ACTIVE = 0 THEN 'INACTIVE'
        WHEN M.STATUS IS NULL THEN 'NOT LAUNCHED'
        ELSE M.STATUS
    END AS "Status",
    
    -- Time information
    UTILS.CONVERT_TO_CHAR(M.StartTime, 10, p_style => 103) || ' ' || 
    UTILS.CONVERT_TO_CHAR(M.StartTime, 8, p_style => 108) AS "Start",
    
    UTILS.CONVERT_TO_CHAR(M.EndTime, 10, p_style => 103) || ' ' || 
    UTILS.CONVERT_TO_CHAR(M.EndTime, 8, p_style => 108) AS "End",
    
    -- Elapsed time
    CASE 
        WHEN UTILS.CONVERT_TO_VARCHAR2(M.StartTime, 8, p_style => 21) > '00/01/01'
        AND UTILS.CONVERT_TO_VARCHAR2(M.EndTime, 8, p_style => 21) > '00/01/01'
        THEN UTILS.CONVERT_TO_VARCHAR2(
            utils.dateadd('SECOND', utils.datediff('SS', M.StartTime, M.EndTime), '1970-01-01'),
            8, p_style => 108
        )
        ELSE ' '
    END AS "Elapsed",
    
    -- Relaunch times
    UTILS.CONVERT_TO_CHAR(M.RelaunchStartTime, 10, p_style => 103) || ' ' || 
    UTILS.CONVERT_TO_CHAR(M.RelaunchStartTime, 8, p_style => 108) AS "RelaunchStart",
    
    UTILS.CONVERT_TO_CHAR(M.RelaunchEndTime, 10, p_style => 103) || ' ' || 
    UTILS.CONVERT_TO_CHAR(M.RelaunchEndTime, 8, p_style => 108) AS "RelaunchEnd",
    
    -- Relaunch elapsed time
    CASE 
        WHEN UTILS.CONVERT_TO_VARCHAR2(M.RelaunchStartTime, 8, p_style => 21) > '00/01/01'
        AND UTILS.CONVERT_TO_VARCHAR2(M.RelaunchEndTime, 8, p_style => 21) > '00/01/01'
        THEN UTILS.CONVERT_TO_VARCHAR2(
            utils.dateadd('SECOND', utils.datediff('SS', M.RelaunchStartTime, M.RelaunchEndTime), '1970-01-01'),
            8, p_style => 108
        )
        ELSE ' '
    END AS "RelaunchElapsed",
    
    -- Task metrics
    t.Autopack AS "Autopack",
    M.TaskCount AS "SumTasks",
    ' ' AS "Destination",
    ' ' AS "Group",
    t.Weight AS "Weight",
    j.Priority AS "Priority",
    t.PortrepType AS "PortrepType",
    
    -- Duration statistics
    UTILS.CONVERT_TO_VARCHAR2(
        utils.dateadd('SECOND', M.MeanTaskDuration, '1970-01-01'),
        8, p_style => 108
    ) AS "Mean TaskDuration",
    
    UTILS.CONVERT_TO_VARCHAR2(
        utils.dateadd('SECOND', M.StdDevTaskDuration, '1970-01-01'),
        8, p_style => 108
    ) AS "StdDev TaskDuration",
    
    UTILS.CONVERT_TO_VARCHAR2(
        utils.dateadd('SECOND', M.MaxTaskDuration, '1970-01-01'),
        8, p_style => 108
    ) AS "Max TaskDuration",
    
    CASE 
        WHEN M.TotalTaskDuration IS NULL THEN ' '
        ELSE UTILS.CONVERT_TO_VARCHAR2(M.TotalTaskDuration, 1000)
    END AS "Total TaskDuration",
    
    -- Additional task properties
    t.EnvId AS "EnvId",
    UTILS.CONVERT_TO_VARCHAR2(t.Required_End, 12, p_style => 108) AS "Required End",
    UTILS.CONVERT_TO_VARCHAR2(t.Wished_End, 12, p_style => 108) AS "Wished End",
    
    -- Flags
    CASE WHEN IsConfigFileXML = 1 THEN 'Y' ELSE 'N' END AS "IsConfigFileXML",
    CASE WHEN ResultByTrade = 1 THEN 'Y' ELSE 'N' END AS "ByTrade",
    CASE WHEN ResultByAsset = 1 THEN 'Y' ELSE 'N' END AS "ByAsset",
    
    -- Risk and technical fields
    t.ARMVector AS "ARMVector",
    t.AddRisk AS "AddRisk",
    t.Discriminator AS "Discriminator",
    
    -- Result information
    M.ResultServerName AS "ResultServerName",
    M.ResultDir AS "ResultDir",
    M.ResultFile AS "ResultFile",
    M.ErrorDir AS "ErrorDir",
    M.ERRORFILE AS "ErrorFile",
    M.ErrorMessage AS "ErrorMessage",
    M.AsOfDate AS "AsOfDate",
    
    -- Identifiers and dates
    t.TaskId AS "TaskId",
    t.RunDate AS "RunDate",
    t.ReportDate AS "ReportDate",
    
    -- New risk classification
    rc.RiskClassification AS "RiskClassification"

FROM SRM_Tasks_HedgeAPI t

-- Main joins
INNER JOIN SRM_Jobs j ON t.JobId = j.JobId
LEFT JOIN SRM_Manager M ON M.JobId = t.JobId 
                       AND M.TaskId = t.TaskId 
                       AND M.ReportDate = '%DATE%'
LEFT JOIN SRM_RiskClassif rc ON t.TaskId = rc.TaskId

-- Filter conditions
WHERE t.JobId = '%JobId%'
  AND j.ACTIVE = 1
  AND t.Active = 1

-- Sorting
ORDER BY t.filter, t.suffix ASC;
```

## Ключевые оптимизации:

### 1. **Производительность:**
- **CTE для EXISTS подзапроса** - предварительная фильтрация данных
- **Явные JOIN вместо запятых** - улучшает читаемость и производительность
- **Оптимизированная логика CASE** - уменьшена вложенность условий

### 2. **Читабельность:**
- **Логическая группировка** полей по смыслу
- **Единообразное форматирование** алиасов и ключевых слов
- **Комментарии-разделители** для разных секций запроса
- **Выравнивание** похожих конструкций

### 3. **Дополнительные рекомендации для дальнейшей оптимизации:**

```sql
-- Создание индексов для ускорения запроса
CREATE INDEX idx_srm_tasks_job_active ON SRM_Tasks_HedgeAPI(JobId, Active);
CREATE INDEX idx_srm_jobs_active ON SRM_Jobs(JobId, Active);
CREATE INDEX idx_srm_manager_dates ON SRM_Manager(JobId, TaskId, ReportDate);
CREATE INDEX idx_srm_belongto_groups ON SRM_BelongTo(TaskId, JobId, GroupId);
CREATE INDEX idx_srm_group_topprio ON SRM_Group(GroupId, TopPrio);
CREATE INDEX idx_srm_riskclassif_task ON SRM_RiskClassif(TaskId);
```

### 4. **Альтернативный вариант с материализацией:**
Если запрос выполняется часто, рассмотрите материализованное представление:

```sql
CREATE MATERIALIZED VIEW mv_task_dashboard
REFRESH FAST ON DEMAND
AS
-- [оптимизированный запрос выше]
```

Эти изменения должны значительно улучшить как производительность, так и поддерживаемость кода.
