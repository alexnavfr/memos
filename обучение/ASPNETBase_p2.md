### Пример простого Full-Stack приложения на C# (ASP.NET Core + Blazor)

В этом примере мы создадим простое кросс-платформенное Full-Stack приложение с использованием ASP.NET Core для бэкенда и Blazor для фронтенда. Приложение будет представлять собой список задач (To-Do List), где пользователь может добавлять, просматривать и удалять задачи.

---

### Структура приложения

1. **Backend**:
   - ASP.NET Core Web API для обработки запросов.
   - Entity Framework Core для работы с базой данных (SQLite).

2. **Frontend**:
   - Blazor WebAssembly (WASM) для создания пользовательского интерфейса.

3. **База данных**:
   - SQLite (легкая и кросс-платформенная).

---

### Шаги для создания приложения

#### 1. Создание проекта

1. Установите .NET SDK (версия 6 или выше).
2. Создайте решение и проекты:
   ```bash
   dotnet new sln -n TodoApp
   dotnet new webapi -n TodoApi
   dotnet new blazorwasm -n TodoClient
   dotnet sln add TodoApi
   dotnet sln add TodoClient
   ```

---

#### 2. Настройка Backend (TodoApi)

1. **Установите необходимые пакеты**:
   ```bash
   cd TodoApi
   dotnet add package Microsoft.EntityFrameworkCore.Sqlite
   dotnet add package Microsoft.EntityFrameworkCore.Design
   ```

2. **Создайте модель задачи**:
   ```csharp
   // Models/TodoItem.cs
   public class TodoItem
   {
       public int Id { get; set; }
       public string Title { get; set; }
       public bool IsCompleted { get; set; }
   }
   ```

3. **Создайте контекст базы данных**:
   ```csharp
   // Data/TodoContext.cs
   using Microsoft.EntityFrameworkCore;

   public class TodoContext : DbContext
   {
       public TodoContext(DbContextOptions<TodoContext> options) : base(options) { }
       public DbSet<TodoItem> TodoItems { get; set; }
   }
   ```

4. **Настройте базу данных в `Program.cs`**:
   ```csharp
   var builder = WebApplication.CreateBuilder(args);
   builder.Services.AddDbContext<TodoContext>(options =>
       options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));
   builder.Services.AddControllers();
   var app = builder.Build();
   app.MapControllers();
   app.Run();
   ```

5. **Создайте контроллер для задач**:
   ```csharp
   // Controllers/TodoController.cs
   using Microsoft.AspNetCore.Mvc;
   using Microsoft.EntityFrameworkCore;

   [ApiController]
   [Route("api/[controller]")]
   public class TodoController : ControllerBase
   {
       private readonly TodoContext _context;

       public TodoController(TodoContext context)
       {
           _context = context;
       }

       [HttpGet]
       public async Task<ActionResult<IEnumerable<TodoItem>>> GetTodoItems()
       {
           return await _context.TodoItems.ToListAsync();
       }

       [HttpPost]
       public async Task<ActionResult<TodoItem>> PostTodoItem(TodoItem item)
       {
           _context.TodoItems.Add(item);
           await _context.SaveChangesAsync();
           return CreatedAtAction(nameof(GetTodoItems), new { id = item.Id }, item);
       }

       [HttpDelete("{id}")]
       public async Task<IActionResult> DeleteTodoItem(int id)
       {
           var item = await _context.TodoItems.FindAsync(id);
           if (item == null) return NotFound();
           _context.TodoItems.Remove(item);
           await _context.SaveChangesAsync();
           return NoContent();
       }
   }
   ```

6. **Настройка базы данных**:
   - Добавьте строку подключения в `appsettings.json`:
     ```json
     {
       "ConnectionStrings": {
         "DefaultConnection": "Data Source=todo.db"
       }
     }
     ```
   - Примените миграции:
     ```bash
     dotnet ef migrations add InitialCreate
     dotnet ef database update
     ```

---

#### 3. Настройка Frontend (TodoClient)

1. **Установите HttpClient**:
   - В `Program.cs` добавьте:
     ```csharp
     builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri("https://localhost:5001") });
     ```

2. **Создайте модель задачи**:
   ```csharp
   // Models/TodoItem.cs
   public class TodoItem
   {
       public int Id { get; set; }
       public string Title { get; set; }
       public bool IsCompleted { get; set; }
   }
   ```

3. **Создайте сервис для работы с API**:
   ```csharp
   // Services/TodoService.cs
   using System.Net.Http.Json;

   public class TodoService
   {
       private readonly HttpClient _httpClient;

       public TodoService(HttpClient httpClient)
       {
           _httpClient = httpClient;
       }

       public async Task<List<TodoItem>> GetTodoItemsAsync()
       {
           return await _httpClient.GetFromJsonAsync<List<TodoItem>>("api/todo");
       }

       public async Task AddTodoItemAsync(TodoItem item)
       {
           await _httpClient.PostAsJsonAsync("api/todo", item);
       }

       public async Task DeleteTodoItemAsync(int id)
       {
           await _httpClient.DeleteAsync($"api/todo/{id}");
       }
   }
   ```

4. **Создайте компонент для отображения задач**:
   ```razor
   <!-- Pages/Todo.razor -->
   @page "/todo"
   @inject TodoService TodoService

   <h3>Todo List</h3>

   <input @bind="_newItemTitle" placeholder="New task" />
   <button @onclick="AddItem">Add</button>

   <ul>
       @foreach (var item in _todoItems)
       {
           <li>
               @item.Title
               <button @onclick="() => DeleteItem(item.Id)">Delete</button>
           </li>
       }
   </ul>

   @code {
       private List<TodoItem> _todoItems = new();
       private string _newItemTitle = string.Empty;

       protected override async Task OnInitializedAsync()
       {
           _todoItems = await TodoService.GetTodoItemsAsync();
       }

       private async Task AddItem()
       {
           var newItem = new TodoItem { Title = _newItemTitle, IsCompleted = false };
           await TodoService.AddTodoItemAsync(newItem);
           _todoItems = await TodoService.GetTodoItemsAsync();
           _newItemTitle = string.Empty;
       }

       private async Task DeleteItem(int id)
       {
           await TodoService.DeleteTodoItemAsync(id);
           _todoItems = await TodoService.GetTodoItemsAsync();
       }
   }
   ```

---

#### 4. Запуск приложения

1. Запустите Backend:
   ```bash
   cd TodoApi
   dotnet run
   ```

2. Запустите Frontend:
   ```bash
   cd TodoClient
   dotnet run
   ```

3. Откройте браузер и перейдите по адресу `http://localhost:5000/todo`.

---

### Итог

Это простое Full-Stack приложение демонстрирует:
- Создание RESTful API на ASP.NET Core.
- Использование Entity Framework Core для работы с базой данных.
- Разработку фронтенда на Blazor WebAssembly.
- Взаимодействие между фронтендом и бэкендом через HTTP-запросы.

Этот пример можно расширять, добавляя аутентификацию, улучшая интерфейс и добавляя новые функции.
