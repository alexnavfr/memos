Vim для начинающих: Часть 2 / Vim for Beginners: Part 2

Русская версия

Навигация следующего уровня

```
Ctrl+f     страница вниз (forward)
Ctrl+b     страница вверх (backward)
{          параграф вверх  
}          параграф вниз
%          перейти к парной скобке

/text      поиск текста (n - след., N - пред.)
?text      поиск в обратном направлении
:noh       убрать подсветку поиска (no highlight)
```

Редактирование продвинутее

```
dw         удалить слово (delete word)
cw         изменить слово (change word) - удаляет и переводит в insert mode
D          удалить до конца строки
C          изменить до конца строки

r          заменить один символ (replace)
R          заменить несколько символов (replace mode)
J          объединить строки (join)
```

Работа с несколькими файлами

```
:e file.txt    открыть другой файл (edit)
:sp file.txt   открыть горизонтально (split)
:vsp file.txt  открыть вертикально (vertical split)
Ctrl+w + стрелки  переключение между окнами
:bd           закрыть буфер (buffer delete)
```

Полезные комбинации

```
.          повторить последнюю команду (самая мощная команда!)
>>         сдвинуть строку вправо (tab)
<<         сдвинуть строку влево
ddp        поменять строки местами (delete, put)
```

Визуальный режим (Visual mode)

```
v          войти в визуальный режим (посимвольно)
V          визуальный режим построчно
Ctrl+v     визуальный блоковый режим

После выделения:
y          скопировать (yank)
d          удалить (delete)
>          сдвинуть вправо
<          сдвинуть влево
```

---

English Version

Next-Level Navigation

```
Ctrl+f     page down (forward)
Ctrl+b     page up (backward)
{          paragraph up
}          paragraph down
%          jump to matching bracket

/text      search text (n - next, N - previous)
?text      search backwards
:noh       remove search highlight
```

Advanced Editing

```
dw         delete word
cw         change word - deletes and enters insert mode
D          delete to end of line
C          change to end of line

r          replace one character
R          replace multiple characters (replace mode)
J          join lines
```

Working with Multiple Files

```
:e file.txt    open another file (edit)
:sp file.txt   open horizontally (split)
:vsp file.txt  open vertically (vertical split)
Ctrl+w + arrows  switch between windows
:bd           close buffer (buffer delete)
```

Useful Combinations

```
.          repeat last command (most powerful command!)
>>         indent line right
<<         unindent line left
ddp        swap lines (delete, put)
```

Visual Mode

```
v          enter visual mode (character-wise)
V          visual mode line-wise
Ctrl+v     visual block mode

After selection:
y          yank (copy)
d          delete
>          indent right
<          indent left
```

Практическое упражение / Practical Exercise

Russian: Откройте файл, попробуйте:

1. i - ввод текста, Esc - возврат
2. dd - удалить строку, u - отменить
3. v - выделить текст, y - скопировать, p - вставить
4. :sp - разделить окно, Ctrl+w w - переключиться

English: Open a file, try:

1. i - insert text, Esc - return
2. dd - delete line, u - undo
3. v - select text, y - yank, p - paste
4. :sp - split window, Ctrl+w w - switch

Что дальше? / What's Next?

· Russian: Введите vimtutor в терминале - интерактивное обучение
· English: Type vimtutor in terminal - interactive tutorial

Запомните: Практика по 15 минут в день лучше, чем 2 часа раз в неделю!
Remember:15 minutes daily practice beats 2 hours once a week!