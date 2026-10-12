# Formatting Perl source code scripts

## Prompt:
_Perl. как отформатировать исходный код perl в соответсвии со стандартом через CLI, командную строку_

Вот несколько способов форматирования Perl-кода через командную строку:

## 1. **perltidy** (наиболее популярный инструмент)

### Установка:
```bash
# Debian/Ubuntu
sudo apt-get install perltidy

# CentOS/RHEL/Fedora
sudo yum install perltidy

# Через CPAN
cpanm Perl::Tidy
```

### Основное использование:
```bash
# Форматировать файл
perltidy script.pl

# Форматировать с сохранением в другой файл
perltidy script.pl -o formatted.pl

# Изменить форматирование на месте (создаст backup)
perltidy -b script.pl

# Использовать конкретный профиль стиля
perltidy --profile=perltidyrc script.pl
```

### Примеры с параметрами:
```bash
# Стиль K&R (по умолчанию)
perltidy -kr script.pl

# Стиль GNU
perltidy -gnu script.pl

# Стиль BSD/Allman
perltidy -bl script.pl

# Кастомные настройки
perltidy -i=4 -ci=4 -l=80 -nola script.pl
```

## 2. **perlcritic** (для проверки соответствия стандартам)

### Установка:
```bash
cpanm Perl::Critic
```

### Использование:
```bash
# Проверить код
perlcritic script.pl

# Автоматически исправить нарушения
perlcritic --brutal --statistics-only script.pl
```

## 3. **Конфигурационные файлы**

### Создать конфиг perltidy:
```bash
# Генерировать конфиг по умолчанию
perltidy -dpro > .perltidyrc

# Пример .perltidyrc
-indent-columns=4
-maximum-line-length=80
-brace-vertical-tightness=1
-line-up-parentheses
```

## 4. **Интеграция с редакторами**

### Для быстрого форматирования из командной строки:
```bash
# Форматировать все .pl файлы в директории
find . -name "*.pl" -exec perltidy -b {} \;

# Форматировать с выводом в stdout
cat messy.pl | perltidy
```

## 5. **Популярные пресеты стилей**

```bash
# PBP (Perl Best Practices)
perltidy -pbp script.pl

# Строгий стиль
perltidy -st script.pl

# С минимальными изменениями
perltidy -noll -pt=2 script.pl
```

## 6. **Опции для CI/CD пайплайнов**

```bash
# Проверить, нуждается ли код в форматировании
perltidy --check script.pl

# Выход с кодом ошибки если код не отформатирован
perltidy --assert-tidy script.pl
```

## Пример полной команды с типичными настройками:
```bash
perltidy \
  -i=4 \          # 4 пробела на отступ
  -ci=4 \         # отступ для продолжения строк
  -l=80 \         # максимальная длина строки
  -vt=2 \         # вертикальные табы
  -cti=1 \        # отступ для закрывающей скобки
  -pt=1 \         # приоритет скобок
  -bt=2 \         # табы для блоков
  -sbt=2 \        # табы для вложенных блоков
  -bbt=2 \        # табы для блоков в подпрограммах
  -nsfs \         # не форматировать строки
  -bar \          # открывающая скобка всегда на новой строке
  -bbs \          # отступ перед открывающей скобкой блока
  -noll \         # не переносить длинные строки
  script.pl
```

## Рекомендации:

1. **Сначала проверьте**: `perltidy -st script.pl | less`
2. **Создайте конфиг**: Настройте `.perltidyrc` под ваш проект
3. **Используйте pre-commit хуки**: Для автоматического форматирования перед коммитом
4. **Комбинируйте с perlcritic**: Для проверки качества кода

Для большинства проектов достаточно:
```bash
perltidy -b -pbp *.pl *.pm
```

Это автоматически отформатирует все файлы в соответствии с Perl Best Practices.
