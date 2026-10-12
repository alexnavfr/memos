# Git attribs

## atribs

Хорошо 👍
Файл **`.gitattributes`** помогает унифицировать работу с концами строк, кодировками и файлами на разных ОС (Windows/Linux).
Для C++/Qt-проектов можно взять такой универсальный шаблон:

---

## 📄 `.gitattributes`

```gitattributes
# ------------------------------------
# Handle line endings
# ------------------------------------

# By default, normalize all text files to LF in repo
* text=auto eol=lf

# Explicitly set for common source code
*.c      text eol=lf
*.cpp    text eol=lf
*.h      text eol=lf
*.hpp    text eol=lf
*.pro    text eol=lf
*.pri    text eol=lf
CMakeLists.txt text eol=lf

# Scripts
*.sh     text eol=lf
*.bat    text eol=crlf
*.cmd    text eol=crlf

# Configs
*.yml    text eol=lf
*.yaml   text eol=lf
*.json   text eol=lf
*.xml    text eol=lf
*.txt    text eol=lf

# ------------------------------------
# Binary files (no end-of-line changes)
# ------------------------------------
*.png    binary
*.jpg    binary
*.jpeg   binary
*.gif    binary
*.bmp    binary
*.ico    binary
*.svg    binary
*.pdf    binary

*.dll    binary
*.exe    binary
*.so     binary
*.dylib  binary
*.lib    binary
*.a      binary
*.pdb    binary

# ------------------------------------
# Prevent merge conflicts in project files
# ------------------------------------

# Qt Creator/Visual Studio project files (treat as binary)
/*.pro.user   binary
/*.sln        text eol=crlf
/*.vcxproj    text eol=crlf
/*.filters    text eol=crlf
```

---

### 🔑 Что делает этот файл

* **`text=auto eol=lf`** → все текстовые файлы в репозитории хранятся с LF (Linux стиль).
* На Windows при checkout Git автоматически конвертирует в CRLF (если включено `core.autocrlf`).
* Явно указаны **исключения для скриптов** (`.bat`, `.cmd` → CRLF).
* **Бинарники** объявлены как `binary`, чтобы Git не пытался их изменять/мерджить.
* Файлы проектов (Qt/Visual Studio) помечены так, чтобы избежать конфликтов.

---

⚡ В итоге:

* исходники и конфиги → всегда LF в репо;
* скрипты Windows → CRLF;
* бинарные файлы → не трогаются Git’ом.

---

Хочешь, я ещё распишу **настройки `git config`**, чтобы на Windows и Linux не путались концы строк (например `core.autocrlf` и `core.eol`)?

