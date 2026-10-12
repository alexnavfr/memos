# Update wo Join

## Prompt:
_Oracle. Sql query:
```sql
UPDATE Group g 
	SET g.RClass = 'Basic`-- Set the value you want to update to 
FROM BelongTo b 
JOIN APITask t ON t.TaskId = b.TaskId AND t.JobId = b.JobId 
WHERE g.GroupId = b.GroupId AND t.JobId = 'jobid_name'
```
 дает ошибку "ORA-00933: la commande SQL ne se termine pas correctement 00933. 
00000 - "SQL command not properly ended". Возможная причина наличие `FROM`и `JOIN` внутри `update`. Напиши эквивалент который будет работать на оракл_

В Oracle синтаксис UPDATE с JOIN отличается. Вот эквивалентный запрос, который будет работать:

```sql
UPDATE Group g 
SET g.RClass = 'Basic'
WHERE EXISTS (
    SELECT 1 
    FROM BelongTo b 
    JOIN APITask t ON t.TaskId = b.TaskId AND t.JobId = b.JobId 
    WHERE g.GroupId = b.GroupId 
    AND t.JobId = 'jobid_name'
);
```

Альтернативный вариант с подзапросом:

```sql
UPDATE Group g 
SET g.RClass = 'Basic'
WHERE g.GroupId IN (
    SELECT b.GroupId
    FROM BelongTo b 
    JOIN APITask t ON t.TaskId = b.TaskId AND t.JobId = b.JobId 
    WHERE t.JobId = 'jobid_name'
);
```

Оба варианта эквивалентны по функциональности вашему исходному запросу, но используют синтаксис, совместимый с Oracle.
