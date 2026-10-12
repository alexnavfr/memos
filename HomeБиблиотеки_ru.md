# Каталоги домашних библиотек

Вот несколько **open-source** альтернатив **AllMyBooks**, которые соответствуют вашим требованиям:  

### 1. **[Calibre](https://calibre-ebook.com/)** *(Python, кросс-платформенный)*  
   - **Плюсы:**  
     - Поддержка множества форматов (включая FB2 и FB2.ZIP).  
     - Редактирование метаданных.  
     - Возможность сортировки и фильтрации по тегам, авторам и другим метаданным.  
     - Поддержка плагинов (можно настроить автоматическое сканирование директорий).  
     - Не изменяет файловую структуру (если не использовать встроенное управление библиотекой).  
   - **Минусы:**  
     - Основной интерфейс — табличный, а не древовидный (но можно использовать режим "Файловая система").  
     - Требует ручного добавления книг или настройки плагинов для автосканирования.  

### 2. **[Librum](https://github.com/Librum-Reader/Librum)** *(C++/Qt, кросс-платформенный)*  
   - **Плюсы:**  
     - Поддержка FB2, EPUB, PDF и других форматов.  
     - Редактирование метаданных.  
     - Возможность организации книг в коллекции.  
     - Не изменяет исходную файловую структуру.  
   - **Минусы:**  
     - Менее развит, чем Calibre.  
     - Нет встроенного автоматического сканирования директорий (но можно вручную добавлять книги).  

### 3. **[Koodo Reader](https://github.com/troyeguo/koodo-reader)** *(Electron, кросс-платформенный)*  
   - **Плюсы:**  
     - Поддержка FB2, EPUB, PDF и других форматов.  
     - Чистый интерфейс с возможностью просмотра файловой системы.  
     - Редактирование метаданных.  
     - Не изменяет исходные файлы.  
   - **Минусы:**  
     - Нет глубокой интеграции с файловой системой (сканирование только по запросу).  

### 4. **[BicBucStriim](https://github.com/rvolz/BicBucStriim)** *(PHP, веб-интерфейс)*  
   - **Плюсы:**  
     - Поддержка FB2, EPUB.  
     - Просмотр и редактирование метаданных.  
     - Веб-интерфейс (можно использовать с любого устройства).  
   - **Минусы:**  
     - Требует веб-сервера.  
     - Менее удобен для локального использования.  

### 5. **[Alfa Ebooks Manager](https://github.com/ogarcia/alfaebooks)** *(Python, кросс-платформенный)*  
   - **Плюсы:**  
     - Поддержка FB2, EPUB.  
     - Редактирование метаданных.  
     - Простота и минимализм.  
   - **Минусы:**  
     - Развитие проекта замедлилось.  

### **Рекомендация:**  
Если вам критично **автоматическое сканирование директорий** и **древовидный просмотр**, лучший вариант — **Calibre** с плагинами (например, **"Import List"** или **"SmartEject"** для мониторинга папок).  

Если нужен более легковесный вариант — **Koodo Reader** или **Librum**, но без глубокой автоматизации.  

Для веб-решения — **BicBucStriim**.  

Если ни один вариант не подходит идеально, можно рассмотреть написание простого скрипта на Python с использованием **SQLite** для хранения метаданных и **PyQt** для интерфейса.



---
Отлично! Если **Calibre** слишком перегружен, а вам нужен **минималистичный, но расширяемый** менеджер библиотек с поддержкой **FB2/FB2.ZIP**, **редактированием метаданных** и **древовидной файловой навигацией**, то вот более подходящие варианты:  

---

### **1. [Librum](https://github.com/Librum-Reader/Librum) (C++/Qt)**  
**Почему стоит рассмотреть:**  
✅ Чистый Qt-интерфейс (можно кастомизировать)  
✅ Поддержка **FB2, EPUB, PDF**  
✅ Редактирование метаданных  
✅ Не изменяет файловую структуру  
✅ Возможность сортировки по тегам/авторам  
❌ **Минус:** Нет автоматического сканирования папок (но можно дописать через Qt-наблюдатель за файлами)  

**Доработка:**  
Если у вас есть опыт в C++/Qt, можно добавить:  
- Мониторинг папок через `QFileSystemWatcher`  
- Парсинг FB2 (используя `QXmlStreamReader`)  
- Дополнительные фильтры  

---

### **2. [Koodo Reader](https://github.com/troyeguo/koodo-reader) (Electron/TypeScript)**  
**Почему стоит рассмотреть:**  
✅ Поддержка **FB2, EPUB, PDF**  
✅ Удобный интерфейс с файловым деревом  
✅ Редактирование метаданных  
✅ Кроссплатформенность (Windows/macOS/Linux)  
❌ **Минус:** Electron (может быть тяжеловат), но работает на Catalina  
❌ Нет глубокой интеграции с файловой системой  

**Доработка:**  
Можно добавить плагин для:  
- Автоматического сканирования папок (через `chokidar`)  
- Парсинга FB2 (например, через `fast-xml-parser`)  

---

### **3. [Alfa Ebooks Manager](https://github.com/ogarcia/alfaebooks) (Python/PyQt)**  
**Почему стоит рассмотреть:**  
✅ Минималистичный интерфейс  
✅ Поддержка **FB2, EPUB**  
✅ Редактирование метаданных  
✅ Простота доработки (Python + PyQt)  
❌ **Минус:** Проект мало развивается, но код понятный  

**Доработка:**  
Можно легко добавить:  
- Автосканирование папок через `watchdog`  
- Дополнительные колонки метаданных  
- Экспорт в CSV/JSON  

---

### **4. [Custom Solution: Python + PyQt + SQLite](https://wiki.python.org/moin/PyQt) (Самописный вариант)**  
Если готовы потратить немного времени, можно написать свой менеджер:  
✅ Полный контроль над функционалом  
✅ Легко добавить **автосканирование FB2** (библиотека `lxml`/`xml.etree`)  
✅ SQLite для хранения метаданных (без изменения файлов)  
✅ Qt-интерфейс с древовидной навигацией (`QTreeView + QFileSystemModel`)  

**Пример структуры:**  
```python
from PyQt5.QtWidgets import QApplication, QFileSystemModel, QTreeView
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class BookManager(QMainWindow):
    def __init__(self):
        super().__init__()
        self.model = QFileSystemModel()
        self.model.setRootPath("/path/to/books")
        self.tree = QTreeView()
        self.tree.setModel(self.model)
        self.setCentralWidget(self.tree)

app = QApplication([])
window = BookManager()
window.show()
app.exec_()
```
**Доработки:**  
- Добавить парсер FB2 (`xml.etree.ElementTree`)  
- Редактор метаданных (`QTableView + SQLite`)  

---

### **Итог: что выбрать?**  
| Вариант | Язык | Плюсы | Минусы |  
|---------|------|-------|--------|  
| **Librum** | C++/Qt | Быстрый, Qt-интерфейс | Нужно дописывать автосканирование |  
| **Koodo Reader** | Electron | Готовый UI, кроссплатформенность | Тяжеловат |  
| **Alfa Ebooks** | Python | Простота, легко допилить | Мало updates |  
| **Самописный** | Python | Полный контроль | Требует времени |  

**Если нужен готовый вариант → Librum или Koodo Reader.**  
**Если готовы кодить → Python/PyQt + SQLite.**  

Можно форкнуть **Alfa Ebooks** и добавить нужный функционал — это будет быстрее, чем писать с нуля.

---
Отличный выбор! Форк **Alfa Ebooks Manager** (или другого минималистичного проекта) даст вам гибкость, а Python/PyQt упростят доработку. Вот **план действий** и полезные ресурсы:  

---

### **1. Форк и базовая настройка**  
- Форкните репозиторий **[Alfa Ebooks Manager](https://github.com/ogarcia/alfaebooks)** (или **[Librum](https://github.com/Librum-Reader/Librum)** для C++).  
- Установите зависимости:  
  ```bash
  pip install PyQt5 lxml watchdog sqlite3
  ```

---

### **2. Добавление автосканирования папок**  
Используйте библиотеку **`watchdog`** для мониторинга изменений в указанных директориях.  

**Пример кода:**  
```python
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class BookHandler(FileSystemEventHandler):
    def on_modified(self, event):
        if event.src_path.endswith((".fb2", ".fb2.zip")):
            print(f"Обнаружена новая книга: {event.src_path}")
            # Добавьте парсинг метаданных здесь

observer = Observer()
observer.schedule(BookHandler(), path="/path/to/books", recursive=True)
observer.start()
```

---

### **3. Парсинг FB2-файлов**  
FB2 — это XML, поэтому используйте **`lxml`** или **`xml.etree`**.  

**Пример парсера:**  
```python
from lxml import etree

def parse_fb2(file_path):
    tree = etree.parse(file_path)
    ns = {"fb": "http://www.gribuser.ru/xml/fictionbook/2.0"}
    title = tree.xpath("//fb:book-title/text()", namespaces=ns)[0]
    author = tree.xpath("//fb:author/fb:first-name/text()", namespaces=ns)[0]
    return {"title": title, "author": author}
```

---

### **4. Редактирование метаданных**  
- Добавьте таблицу **SQLite** для хранения метаданных (без изменения исходных файлов).  
- Используйте **`QTableView`** в PyQt для отображения и редактирования.  

**Пример SQLite:**  
```python
import sqlite3
conn = sqlite3.connect("metadata.db")
conn.execute("CREATE TABLE IF NOT EXISTS books (path TEXT, title TEXT, author TEXT)")
```

---

### **5. Древовидный просмотр файлов**  
Используйте **`QFileSystemModel`** + **`QTreeView`** для нативного отображения файловой системы.  

**Пример:**  
```python
from PyQt5.QtWidgets import QFileSystemModel, QTreeView

model = QFileSystemModel()
model.setRootPath("/path/to/books")
tree = QTreeView()
tree.setModel(model)
```

---

### **6. Плагины (опционально)**  
Реализуйте систему плагинов через **`importlib`**.  
- Например, плагины для поддержки новых форматов (PDF, EPUB).  
- Пример структуры:  
  ```
  /plugins
    /epub_plugin.py
    /pdf_plugin.py
  ```

---

### **Полезные ссылки**  
1. **[Документация PyQt5](https://www.riverbankcomputing.com/static/Docs/PyQt5/)** — для кастомизации UI.  
2. **[Watchdog Tutorial](https://pythonhosted.org/watchdog/)** — мониторинг файлов.  
3. **[SQLite + Python](https://docs.python.org/3/library/sqlite3.html)** — хранение метаданных.  

---

### **Итог**  
1. Форкните **Alfa Ebooks Manager**.  
2. Добавьте:  
   - Автосканирование (`watchdog`).  
   - Парсер FB2 (`lxml`).  
   - SQLite для метаданных.  
3. Кастомизируйте интерфейс под древовидную навигацию (`QFileSystemModel`).  

Такой подход даст вам **гибкость** без перегруженности Calibre. Удачи в разработке! Если будут вопросы по конкретным шагам — спрашивайте. 🚀

---
Отлично! Разберём вариант **Librum** — это **C++/Qt**-приложение для управления электронными книгами, которое можно доработать под ваши нужды.  

---

## **1. Обзор Librum**  
**[Репозиторий](https://github.com/Librum-Reader/Librum)** | **[Сайт](https://librumreader.com/)**  

### **Плюсы:**  
✅ **Чистый Qt-интерфейс** (можно кастомизировать)  
✅ **Поддержка FB2, EPUB, PDF, MOBI**  
✅ **Редактирование метаданных** (автор, название, теги)  
✅ **Кроссплатформенность** (Windows, Linux, macOS)  
✅ **Не изменяет файловую структуру** (хранит метаданные отдельно)  
✅ **Локальное хранение** (без облаков)  

### **Минусы:**  
❌ **Нет автоматического сканирования папок** (нужно добавлять книги вручную)  
❌ **Нет древовидного файлового браузера** (но можно добавить через `QFileSystemModel`)  
❌ **Мало плагинов** (но можно писать свои на C++/Qt)  

---

## **2. Что можно доработать?**  
Если форкнуть **Librum**, можно добавить:  

### **🔹 Автоматическое сканирование папок**  
Использовать **`QFileSystemWatcher`** для мониторинга изменений в указанных директориях.  

**Пример кода (C++):**  
```cpp
#include <QFileSystemWatcher>
#include <QDebug>

QFileSystemWatcher *watcher = new QFileSystemWatcher(this);
watcher->addPath("/path/to/books");

connect(watcher, &QFileSystemWatcher::directoryChanged, [](const QString &path) {
    qDebug() << "Обнаружены изменения в:" << path;
    // Здесь можно добавить проверку новых FB2-файлов
});
```

---

### **🔹 Древовидный файловый браузер**  
Добавить **`QFileSystemModel` + `QTreeView`** для отображения иерархии папок.  

**Пример кода:**  
```cpp
#include <QFileSystemModel>
#include <QTreeView>

QFileSystemModel *model = new QFileSystemModel;
model->setRootPath("/path/to/books");

QTreeView *treeView = new QTreeView;
treeView->setModel(model);
treeView->setRootIndex(model->index("/path/to/books"));
```

---

### **🔹 Парсинг FB2 и редактирование метаданных**  
Librum уже поддерживает FB2, но можно улучшить:  
- Добавить **автоматическое извлечение** обложек, аннотаций.  
- Расширить **редактор метаданных** (например, для серий книг).  

**Пример парсинга FB2 (используя Qt XML):**  
```cpp
#include <QDomDocument>

QFile file("book.fb2");
if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    return;

QDomDocument doc;
if (!doc.setContent(&file)) {
    file.close();
    return;
}

QString title = doc.elementsByTagName("book-title").at(0).toElement().text();
QString author = doc.elementsByTagName("first-name").at(0).toElement().text();
```

---

### **🔹 Плагины (если нужно расширение функционала)**  
Librum использует **Qt Plugin System**, поэтому можно добавить:  
- Поддержку новых форматов (например, DJVU).  
- Экспорт библиотеки в CSV/JSON.  
- Интеграцию с онлайн-базами (например, Goodreads API).  

**Пример структуры плагина:**  
```cpp
// plugin_interface.h
class PluginInterface {
public:
    virtual QString name() const = 0;
    virtual void importBook(const QString &path) = 0;
};

// В основном коде:
QList<PluginInterface*> plugins;
```

---

## **3. Как собрать и модифицировать?**  
### **Сборка (Linux/macOS/Windows)**  
1. Клонируем репозиторий:  
   ```bash
   git clone https://github.com/Librum-Reader/Librum.git
   cd Librum
   ```
2. Устанавливаем зависимости (Qt6, CMake):  
   ```bash
   sudo apt install qt6-base-dev cmake  # Для Linux
   brew install qt6 cmake               # Для macOS
   ```
3. Собираем:  
   ```bash
   mkdir build && cd build
   cmake .. && make -j4
   ```

### **Модификация**  
- Основная логика: `src/`  
- Интерфейс: `src/ui/`  
- Метаданные: `src/core/library/`  

---

## **4. Плюсы и минусы vs Python-решение**  
| Критерий | **Librum (C++/Qt)** | **Python (PyQt)** |  
|----------|----------------------|-------------------|  
| **Производительность** | ⚡ Быстрее | 🐢 Медленнее (из-за Python) |  
| **Кастомизация** | 🛠️ Сложнее (C++), но мощнее | 🐍 Проще (Python) |  
| **Автосканирование** | Нужно добавить `QFileSystemWatcher` | Готовые библиотеки (`watchdog`) |  
| **Плагины** | Qt Plugin System | Простые Python-модули |  
| **Поддержка FB2** | Есть (но можно улучшить) | Нужно писать парсер |  

---

## **5. Итог: стоит ли выбирать Librum?**  
✅ **Да, если:**  
- Нужен **быстрый и нативный** менеджер книг.  
- Готовы **писать на C++/Qt** для кастомизации.  
- Хотите **Qt-интерфейс** с возможностью глубокой оптимизации.  

❌ **Нет, если:**  
- Нужен **простенький скриптовый менеджер** (лучше Python).  
- Не хотите разбираться в **CMake/Qt**.  

### **Что дальше?**  
1. Форкните **Librum**.  
2. Добавьте **`QFileSystemWatcher`** для автосканирования.  
3. Расширьте **поддержку метаданных FB2**.  
4. (Опционально) Создайте **плагины** для новых форматов.  

Если решите копать в этом направлении — пишите, помогу с конкретными шагами! 📚💻

