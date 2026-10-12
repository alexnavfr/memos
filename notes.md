# Save

## Prompt:
_Спасибо. Расскажи подробнее о пункте 4 - "Подключи clangd + nvim/VSCode для анализа кода". О пункте 5 - "Добавь функцию автосборки CMake с выводом ошибок в цвете". Так же какие настройки можно сделать для автодополнения через `zsh-autosuggestions`. Отдельно расскажи о синхронизиции истории `zsh_history` и других настроек через гит._

Отличные вопросы! Разберём каждый из пунктов подробно:

---

## 🔍 **4. Подключи `clangd` + `nvim` / `VSCode` для анализа кода**

### 🔧 Что такое `clangd`?

`clangd` — это **язык-сервер (LSP)** для C/C++. Он предоставляет:

* автодополнение,
* переход к определению (`Go to Definition`),
* подсказки типов,
* исправления,
* подсветку ошибок в реальном времени.

### ✅ Установка `clangd`

```bash
sudo apt install clangd
```

На macOS (через brew):

```bash
brew install llvm
brew link --force llvm  # если требуется
```

Проверь:

```bash
clangd --version
```

---

### 🧠 Подключение к **nvim** (Neovim)

#### Требования:

* `nvim` >= 0.9
* Плагинный менеджер (например, `lazy.nvim` или `packer.nvim`)
* Установлен `clangd`

#### Пример настройки с `nvim-lspconfig`:

```lua
-- init.lua
require'lspconfig'.clangd.setup {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_dir = require('lspconfig/util').root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
}
```

#### Дополнительно:

* Подключи `nvim-cmp` для автодополнения.
* Используй `telescope.nvim` и `trouble.nvim` для навигации по ошибкам.

---

### 💡 Подключение к **VSCode**

1. Установи расширение: **"clangd"**
2. Открой `.cpp`/`.h` проект → появится сообщение `clangd not found`
3. Перейди в настройки:

   ```
   "clangd.path": "/usr/bin/clangd"
   ```
4. Убедись, что в корне проекта есть `compile_commands.json`:

   ```bash
   cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
   ```

---

## 🛠️ **5. Автосборка CMake + цветной вывод ошибок**

Добавим в `.zshrc` функцию:

```zsh
function build() {
  mkdir -p build && cd build
  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. && \
  make -j$(nproc) |& ccze -A
}
```

### ✨ Объяснение:

* `cmake` генерирует Make-файлы и `compile_commands.json` (нужен `clangd`)
* `make -j$(nproc)` — параллельная сборка
* `|& ccze -A` — цветной вывод через `ccze`

#### Установка `ccze`:

```bash
sudo apt install ccze      # Linux
brew install ccze          # macOS
```

---

## ⚙️ **Настройка автодополнения `zsh-autosuggestions`**

### Установка:

Если используешь Oh-My-Zsh:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

И добавь в `.zshrc`:

```zsh
plugins=(git zsh-autosuggestions)
```

### Полезные настройки:

```zsh
# Цвет предложений (серый)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Подтверждать предложенное через → (по умолчанию работает)
bindkey '^ ' autosuggest-accept  # Ctrl+Space применяет предложение
```

---

## 🔄 **Синхронизация `.zshrc`, `.zsh_history` и конфигов через Git**

### ✅ Что можно синхронизировать:

* `~/.zshrc`
* `~/.aliases`
* `~/.zsh_history`
* `~/.config/nvim/`
* `~/.wezterm.lua`, `~/.tmux.conf`, и т.д.

---

### 📦 Создание репозитория конфигурации

```bash
mkdir -p ~/dotfiles
cd ~/dotfiles
git init
```

Добавь туда ссылки:

```bash
ln -s ~/.zshrc zshrc
ln -s ~/.zsh_history zsh_history
ln -s ~/.config/nvim nvim
ln -s ~/.wezterm.lua wezterm.lua
```

Добавь в `.gitignore`, если нужно:

```
*.swp
*.backup
.cache/
```

---

### 🧠 Пример `.zshrc` для использования истории из общего репо:

```zsh
HISTFILE=~/.dotfiles/zsh_history
HISTSIZE=10000
SAVEHIST=10000
```

И добавь в `crontab` или `precmd` в `.zshrc`, чтобы `git commit -am` делал автоматически:

```zsh
precmd() {
  git -C ~/.dotfiles add .zsh_history
  git -C ~/.dotfiles commit -am "Auto-save zsh history $(date +%F_%T)" > /dev/null 2>&1
}
```

---

## 📘 Дополнительные полезные ресурсы

* `clangd` документация: [https://clangd.llvm.org/](https://clangd.llvm.org/)
* `nvim-lspconfig`: [https://github.com/neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
* `dotfiles` в стиле профессионалов:

  * [https://github.com/mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
  * [https://github.com/junegunn/dotfiles](https://github.com/junegunn/dotfiles)
* CMake + Clangd интеграция: [https://github.com/MaskRay/ccls/wiki/Build-Database](https://github.com/MaskRay/ccls/wiki/Build-Database)

---

Если хочешь, могу:

* собрать шаблон `.dotfiles` в архиве,
* дать конфигурацию `nvim` с `clangd`,
* или готовую минимальную сборку `wezterm + zsh + clangd`.

Скажи, что из этого тебе нужно 😊

