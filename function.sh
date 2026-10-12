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


