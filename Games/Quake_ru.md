# Quake on macos catalina

## Prompt 1:
_как запустить Quake на macos catalina_

На **macOS Catalina (10.15)** оригинальный Quake **напрямую не запускается**, потому что система **не поддерживает 32-битные приложения**. Но Quake отлично запускается через **source-port’ы** (современные движки).

Ниже — **самый простой и рабочий способ**.

---

## ✅ Способ 1: QuakeSpasm (рекомендуется)

### 1️⃣ Скачать QuakeSpasm

Самый популярный и стабильный движок.

* GitHub: [https://github.com/sezero/quakespasm](https://github.com/sezero/quakespasm)
* Готовые сборки под macOS обычно есть в разделе **Releases**

Ищи файл вида:

```
QuakeSpasm-macOS.zip
```

> Работает на Catalina, поддерживает OpenGL, высокие разрешения, моды.

---

### 2️⃣ Где взять файлы игры (PAK)

Нужен **оригинальный Quake** (любой легальный источник):

* Steam → Quake (1996)
* GOG
* Старый CD 🙂

Нужен файл:

```
PAK0.PAK
```

(и `PAK1.PAK`, если есть)

Они лежат в:

```
id1/
```

---

### 3️⃣ Подготовить структуру папок

Например:

```
Quake/
 ├── QuakeSpasm.app
 └── id1/
     ├── pak0.pak
     └── pak1.pak
```

❗️Именно папка **id1** обязательна.

---

### 4️⃣ Запуск

* Просто **двойной клик по QuakeSpasm.app**
* Или перетащи папку `id1` рядом с приложением

Если macOS ругается на безопасность:

```
System Settings → Security → Open anyway
```

---

## 🎮 Управление и настройки

В консоли (клавиша `~`):

```text
vid_restart
```

```text
bind w +forward
bind s +back
bind a +moveleft
bind d +moveright
```

---

## ✅ Способ 2: vkQuake (если проблемы с OpenGL)

Если OpenGL на Catalina ведёт себя плохо:

* [https://github.com/Novum/vkQuake](https://github.com/Novum/vkQuake)
* Использует **Vulkan через MoltenVK**
* Немного сложнее, но стабильнее на старых Mac

---

## ❌ Что НЕ сработает

* Оригинальный `quake.app` (32-бит ❌)
* DOSBox без сильных костылей
* Wine (не поддерживает 32-бит на Catalina)

---

## 💡 Хочешь:

* Quake + **HD-текстуры**
* Quake с **модами** (Arcane Dimensions)
* Запуск через **Terminal**
* Или сборку **из исходников под твой Mac**

Напиши — подстрою инструкцию под твой уровень 👍
