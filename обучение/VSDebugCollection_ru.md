# Debug Collections

## Prompt:
_С#. как в отладчике Visual Studio 2022 читабельно просматривать System.Data.DataCollection и всех DataColumnCollection_

В Visual Studio 2022 есть несколько способов для удобного просмотра DataTable и DataColumnCollection в отладчике. Вот основные методы:

## 1. Использование визуализаторов данных

### В окне Watch/Locals/Autos:
- Разверните объект DataTable
- Найдите свойства `Columns` (DataColumnCollection) и `Rows` (DataRowCollection)
- Для просмотра данных в таблице используйте свойство `Rows`

### Быстрый просмотр всех столбцов:
```csharp
// В окне Watch можно добавить:
dataTable.Columns // покажет коллекцию столбцов
```

## 2. Использование DebuggerDisplay атрибута (если есть доступ к коду)

Добавьте в свой класс:
```csharp
[DebuggerDisplay("Count = {Count}")]
public class CustomDataTable : DataTable
{
    // ваша реализация
}
```

## 3. Просмотр через Immediate Window

В Immediate Window (Ctrl+Alt+I) можно выполнять команды:
```csharp
?dataTable.Columns.Count // количество столбцов
?dataTable.Columns[0].ColumnName // имя первого столбца
```

## 4. Использование визуализатора для DataTable

Для DataTable в отладчике есть специальный визуализатор:
- Наведите на переменную DataTable
- Нажмите на значок лупы 🔍
- Выберите "DataTable Visualizer"

## 5. Создание вспомогательных методов для отладки

Добавьте статический класс для удобства:
```csharp
public static class DataTableDebugHelper
{
    public static string GetColumnsInfo(DataTable table)
    {
        if (table == null) return "Table is null";
        
        var sb = new StringBuilder();
        sb.AppendLine($"Table: {table.TableName}");
        sb.AppendLine($"Columns ({table.Columns.Count}):");
        
        foreach (DataColumn column in table.Columns)
        {
            sb.AppendLine($"  {column.ColumnName} ({column.DataType.Name})");
        }
        
        return sb.ToString();
    }
    
    public static string GetTablePreview(DataTable table, int maxRows = 5)
    {
        if (table == null) return "Table is null";
        
        var sb = new StringBuilder();
        sb.AppendLine(GetColumnsInfo(table));
        sb.AppendLine($"Rows ({table.Rows.Count}):");
        
        for (int i = 0; i < Math.Min(maxRows, table.Rows.Count); i++)
        {
            sb.Append($"Row {i}: ");
            foreach (DataColumn column in table.Columns)
            {
                sb.Append($"{column.ColumnName}={table.Rows[i][column]} ");
            }
            sb.AppendLine();
        }
        
        return sb.ToString();
    }
}
```

Используйте в Watch:
```csharp
DataTableDebugHelper.GetColumnsInfo(dataTable)
DataTableDebugHelper.GetTablePreview(dataTable)
```

## 6. Настройка .natvis файла (для продвинутых)

Создайте файл `.natvis` для кастомной визуализации:
```xml
<AutoVisualizer xmlns="http://schemas.microsoft.com/vstudio/debugger/natvis/2010">
  <Type Name="System.Data.DataTable">
    <Expand>
      <Item Name="TableName">TableName</Item>
      <Item Name="Columns">Columns.Count</Item>
      <Item Name="Rows">Rows.Count</Item>
    </Expand>
  </Type>
</AutoVisualizer>
```

## 7. Быстрые команды для Immediate Window

```csharp
// Просмотр всех имен столбцов
dataTable.Columns.Cast<DataColumn>().Select(c => c.ColumnName).ToArray()

// Просмотр информации о столбцах
foreach (DataColumn col in dataTable.Columns) { Debug.WriteLine($"{col.ColumnName}: {col.DataType}"); }
```

## Советы:

1. **Используйте QuickWatch** (Ctrl+Alt+Q) для быстрого анализа
2. **Добавляйте часто используемые выражения** в Watch window
3. **Используйте DataTable Visualizer** для табличного представления данных
4. **Для больших таблиц** используйте ограничение по количеству строк в preview

Эти методы помогут вам эффективно анализировать структуру и данные DataTable во время отладки.