# Сравнительный анализ кросс платформенных эмуляторов терминала

## Prompt:
_Terminal. Подготовь сравнительный анализ эмуляторов терминала. Выбери наиболее современные. Критерии: 
- кросс платформенный Windows, Linux, macOs Catalina
- поддержка `zsh`
- быстрый 
- поддержка табов.
Предложи настройки. Одновременно добавь настройки `zsh` разработчика С++ использующего `git`. Рекомендации и советы приветсвуются. Ссылки на примеры и интересные ресурсы будут отличным бонусом._ (см. Prompts.md)

Вот **сравнительный анализ современных эмуляторов терминала**, соответствующих следующим критериям:

---

## 🔍 **Критерии выбора**

* ✅ Кроссплатформенность (Windows, Linux, macOS Catalina)
* ✅ Поддержка `zsh`
* ✅ Высокая скорость работы
* ✅ Поддержка вкладок (tabs)

---

## 🖥️ Сравнительная таблица

| Эмулятор             | Платформы                  | `zsh` | Вкладки | Скорость         | Особенности                       |
| -------------------- | -------------------------- | ----- | ------- | ---------------- | --------------------------------- |
| **Alacritty**        | ✅ Win / Linux / macOS      | ✅     | ❌¹      | 🚀 Очень быстрая | GPU-ускорение, минимализм         |
| **Kitty**            | ✅ Win (WSL2), Linux, macOS | ✅     | ✅       | 🚀 Очень быстрая | Поддержка графики, табов, сплитов |
| **WezTerm**          | ✅ Win / Linux / macOS      | ✅     | ✅       | ⚡ Быстрая        | Сплиты, табы, Lua-настройки       |
| **Warp**             | ❌ Только macOS             | ✅     | ✅       | ⚡ Быстрая        | ИИ-подсказки, UI                  |
| **iTerm2**           | ❌ Только macOS             | ✅     | ✅       | ⚡ Быстрая        | Расширенные функции               |
| **Windows Terminal** | ✅ Win (WSL2)               | ✅     | ✅       | ⚡ Быстрая        | Поддержка WSL, вкладки            |

> ¹Alacritty не поддерживает табы напрямую, но можно использовать `tmux` или `zellij`.

---

## ✅ **Рекомендованный выбор: WezTerm или Kitty**

Оба терминала:

* Очень быстрые (GPU-ускорение)
* Поддерживают вкладки и сплиты
* Поддерживают `zsh`
* Имеют хорошую кроссплатформенность
* Гибко настраиваются

**Личный совет**:
Если хочешь универсальное решение с гибкой настройкой и удобством – **WezTerm**. Если хочешь более простую конфигурацию и графические возможности – **Kitty**.

---

## ⚙️ Пример базовой настройки `zsh` для C++/Git разработчика

```zsh
# ~/.zshrc

# Стильный и информативный prompt
# Установка через https://ohmyz.sh/
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Стиль prompt (через Oh-My-Zsh theme или Starship)
ZSH_THEME="agnoster"

# История
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Цветной вывод GCC, CMake и др.
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Удобный алиасы для git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# C++ компиляция
alias g++11='g++ -std=c++11 -Wall -Wextra -g'
alias g++20='g++ -std=c++20 -Wall -Wextra -g'

# Навигация
alias ..='cd ..'
alias ...='cd ../..'

# Подсказки и подсветка
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

---

## 🧰 Инструменты для повышения продуктивности

| Инструмент          | Назначение                                 | Установка                                                                                         |      |
| ------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------- | ---- |
| **Oh-My-Zsh**       | Упрощённое управление конфигурацией zsh    | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` |      |
| **Starship Prompt** | Кроссплатформенный быстрый prompt          | \`curl -sS [https://starship.rs/install.sh](https://starship.rs/install.sh)                       | sh\` |
| **tmux**            | Мультиплексор терминала (табов и окон)     | `sudo apt install tmux`                                                                           |      |
| **fzf**             | Мгновенный fuzzy-поиск по истории и файлам | `git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install`                |      |

---

## 🔧 WezTerm — пример конфигурации

`~/.wezterm.lua`:

```lua
local wezterm = require 'wezterm'

return {
  font = wezterm.font("JetBrains Mono", { weight = "Regular" }),
  font_size = 12.0,
  color_scheme = "Dracula",
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  default_prog = { "/bin/zsh", "-l" },
  use_fancy_tab_bar = true,
  window_background_opacity = 0.95,
}
```

---

## 📚 Полезные ссылки

* **WezTerm:** [https://wezfurlong.org/wezterm/](https://wezfurlong.org/wezterm/)
* **Kitty:** [https://sw.kovidgoyal.net/kitty/](https://sw.kovidgoyal.net/kitty/)
* **Oh My Zsh:** [https://ohmyz.sh/](https://ohmyz.sh/)
* **Starship Prompt:** [https://starship.rs/](https://starship.rs/)
* **Awesome Terminal Fonts:** [https://github.com/ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts)
* **CheatSheet по Git:** [https://education.github.com/git-cheat-sheet-education.pdf](https://education.github.com/git-cheat-sheet-education.pdf)
* **C++ Dev Environment Setup:** [https://github.com/vi/C++20-Include-What-You-Use-Template](https://github.com/vi/C++20-Include-What-You-Use-Template)

---

## 💡 Советы разработчику C++:

1. Используй **Nerd Fonts** (JetBrains Mono, Fira Code) — они поддерживают значки и улучшают UX.
2. Настрой автодополнение через `zsh-autosuggestions`.
3. Сохраняй историю команд в `~/.zsh_history` и синхронизируй через git между машинами.
4. Подключи `clangd` + `nvim`/`VSCode` для анализа кода.
5. Добавь функцию автосборки CMake с выводом ошибок в цвете:

   ```zsh
   function build() {
     mkdir -p build && cd build && cmake .. && make -j$(nproc)
   }
   ```

---

Хочешь архив с готовой zsh-конфигурацией, алиасами и шрифтами? Могу собрать и прислать.
