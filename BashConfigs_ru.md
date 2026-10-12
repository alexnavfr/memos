# Bash Configs

## Prompt:
_Bash. Напиши статью о том как конфигуривать терминал со средой bash. Настройки для alias, path, разные переменные. как в цикле добавлять добавочные скрипты по типу `functions.sh`, `aliasesGit.sh` и так далее_

# Настройка терминала Bash: конфигурация, алиасы, пути и скрипты

Bash (Bourne Again SHell) - это мощная командная оболочка, используемая по умолчанию во многих Unix-системах. Правильная настройка bash может значительно повысить вашу продуктивность.

## Основные конфигурационные файлы

Bash использует несколько конфигурационных файлов:

- `~/.bashrc` - выполняется при каждом запуске интерактивной оболочки
- `~/.bash_profile` или `~/.profile` - выполняется при логине
- `~/.bash_logout` - выполняется при выходе из оболочки

## Настройка переменных окружения

### Переменная PATH

```bash
# Добавление путей к PATH
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="./node_modules/.bin:$PATH"

# Удаление дубликатов из PATH
export PATH=$(echo $PATH | awk -v RS=: '!($0 in a) {a[$0]; printf("%s%s", length(a) > 1 ? ":" : "", $0)}')
```

### Пользовательские переменные

```bash
# Основные настройки
export EDITOR="vim"
export VISUAL="code"
export PAGER="less"

# Цвета для ls
export LS_COLORS="di=1;34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

# История команд
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT="%d/%m/%y %T "

# Языковые настройки
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
```

## Создание алиасов (псевдонимов)

### Основные алиасы

```bash
# Навигация
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"

# Безопасные операции
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# Удобные сокращения
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"

# Системные команды
alias df="df -h"
alias du="du -h"
alias free="free -m"

# Сетевые команды
alias myip="curl http://ipecho.net/plain; echo"
alias ports="netstat -tulanp"
```

### Git алиасы (aliasesGit.sh)

```bash
# Статус и информация
alias gs="git status"
alias gb="git branch"
alias gl="git log --oneline --decorate --graph"
alias glo="git log --oneline --decorate --graph --all"

# Коммиты
alias ga="git add"
alias gc="git commit -m"
alias gca="git commit --amend"
alias gcan="git commit --amend --no-edit"

# Ветки
alias gco="git checkout"
alias gcb="git checkout -b"
alias gbd="git branch -d"

# Пуши и пулы
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gpl="git pull"
alias gpr="git pull --rebase"

# Диффы
alias gd="git diff"
alias gds="git diff --staged"
alias gdw="git diff --word-diff"
```

### Пользовательские функции (functions.sh)

```bash
# Создание директории и переход в нее
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Поиск в истории
hg() {
    history | grep "$1"
}

# Поиск файла
ff() {
    find . -type f -name "*$1*"
}

# Поиск в файлах
ftext() {
    grep -rnw '.' -e "$1"
}

# Сжатие файлов
compress() {
    tar cvzf "$1.tar.gz" "$1"
}

# Распаковка
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar x "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Получение погоды
weather() {
    curl "wttr.in/${1:-Moscow}"
}
```

## Организация конфигурации с модульной системой

### Основной .bashrc

```bash
# ~/.bashrc

# Если оболочка не интерактивная, выходим
case $- in
    *i*) ;;
      *) return;;
esac

# Основные настройки
export DOTFILES="$HOME/.dotfiles"

# Source all files from config directory
for file in "$DOTFILES"/bash/*.sh; do
    if [ -f "$file" ]; then
        source "$file"
    fi
done

# Автодополнение
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Настройка prompt (можно вынести в отдельный файл)
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\$ "
```

### Структура каталогов

```
~/
├── .bashrc
└── .dotfiles/
    └── bash/
        ├── aliases.sh
        ├── functions.sh
        ├── aliasesGit.sh
        ├── docker.sh
        ├── kubernetes.sh
        └── nodejs.sh
```

### Скрипт для автоматического обновления

```bash
#!/bin/bash
# update-dotfiles.sh

DOTFILES_DIR="$HOME/.dotfiles"

echo "Updating dotfiles from $DOTFILES_DIR"

# Source all bash config files
for config_file in "$DOTFILES_DIR"/bash/*.sh; do
    if [ -f "$config_file" ]; then
        echo "Sourcing $config_file"
        source "$config_file"
    fi
done

echo "Dotfiles updated successfully!"
```

## Дополнительные настройки

### Цветовая схема терминала

```bash
# В ~/.bashrc или отдельном файле colors.sh
export TERM=xterm-256color

# Цвета для man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;38;5;74m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[38;5;246m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[04;38;5;146m'
```

### Настройки для разработки

```bash
# В файле development.sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Python virtualenv
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

# Go lang
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
```

## Советы по организации

1. **Используйте version control** для ваших dotfiles
2. **Комментируйте** ваши настройки для будущего себя
3. **Тестируйте изменения** в отдельной сессии перед применением
4. **Организуйте по темам** - разделяйте настройки по разным файлам
5. **Используйте условные проверки** для кроссплатформенности

```bash
# Проверка ОС
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux specific settings
    alias open="xdg-open"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OS specific settings
    alias flushdns="sudo killall -HUP mDNSResponder"
fi
```

Такая модульная система настройки bash позволяет легко поддерживать конфигурацию, делиться настройками между системами и быстро восстанавливать рабочее окружение.
