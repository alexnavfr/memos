# Профилирование многопоточных приложений: полное руководство

Профилирование многопоточных программ требует особого подхода из-за:
- Конкуренции за ресурсы
- Скрытых блокировок
- Проблем с синхронизацией памяти
- Ложного совместного доступа (false sharing)

---

## 1. Инструменты для разных платформ

### Linux (лучшие инструменты)
```bash
# 1. Perf для анализа аппаратных событий
perf stat -e cycles,cache-misses,LLC-load-misses,L1-dcache-load-misses ./app

# 2. Lock contention анализ
perf lock record ./app && perf lock report

# 3. Анализ ожидания мьютексов
valgrind --tool=drd --exclusive-threshold=100 ./app

# 4. Полный профиль с flamegraph
perf record -F 99 -g -- ./app
perf script | stackcollapse-perf.pl | flamegraph.pl > out.svg
```

### Windows
```powershell
# 1. WPR (Windows Performance Recorder)
wpr -start GeneralProfile -start CPU -start FileIO -onoff

# 2. ETW для потоков
xperf -on PROC_THREAD+LOADER+PROFILE -stackwalk Profile
```

---

## 2. Типичные проблемы и их идентификация

### 1. Конкуренция за блокировки
**Симптомы:**
- Высокий `%sys` в top
- Большое значение `avg_wait_time` в `perf lock`

**Пример диагностики:**
```bash
perf record -e contention -a ./app
perf report -n --stdio
```

### 2. Ложное совместное использование (False Sharing)
**Симптомы:**
- Высокий `cache-misses` в `perf stat`
- Необъяснимая деградация при добавлении потоков

**Диагностика:**
```bash
perf c2c record -a ./app
perf c2c report --stdio
```

### 3. Гонки данных
**Лучшие инструменты:**
- ThreadSanitizer (TSan)
```bash
clang++ -fsanitize=thread -g -O1 app.cpp
```

---

## 3. Практические примеры анализа

### Пример 1: Анализ блокировок
```cpp
std::mutex mtx;

void worker() {
    for (int i = 0; i < 1000000; ++i) {
        std::lock_guard lock(mtx);  // Hotspot!
        std::this_thread::sleep_for(1ns);
    }
}
```

**Анализ:**
```bash
perf record -g -e 'sched:sched_stat_sleep' ./app
```
Вывод покажет:
- 99% времени в `pthread_mutex_lock`
- Высокий `sched_switch` в `perf stat`

**Решение:** Уменьшить granularity блокировок.

---

### Пример 2: False Sharing
```cpp
struct Data {
    int x;  // Проблема: в одной cache-line
    int y;
};

Data data;

void thread1() { for (int i = 0; i < 1e9; ++i) ++data.x; }
void thread2() { for (int i = 0; i < 1e9; ++i) ++data.y; }
```

**Диагностика:**
```bash
perf stat -e cache-misses,L1-dcache-loads ./app
```
Вывод:
- > 80% cache-misses

**Решение:** Добавить выравнивание:
```cpp
struct alignas(64) Data {
    int x;
    int padding[15];
    int y;
};
```

---

## 4. Продвинутые техники

### 1. Off-CPU анализ
```bash
perf record -e sched:sched_stat_sleep -e sched:sched_switch -g -p <PID>
```
Покажет:
- Где потоки блокируются
- Причины ожидания (I/O, мьютексы и т.д.)

### 2. Анализ планировщика
```bash
perf sched record ./app
perf sched latency --sort max
```
Вывод:
- Максимальные задержки между пробуждением и выполнением

### 3. Memory Model анализ
```bash
perf mem record -a ./app
perf mem report --sort=mem
```
Покажет:
- Доступы к "горячим" участкам памяти
- Конфликты кэш-линий

---

## 5. Лучшие практики

1. **Итеративный подход:**
   - Сначала профилируйте однопоточную версию
   - Затем добавляйте потоки по одному

2. **Метрики для мониторинга:**
   ```bash
   watch -n 1 "cat /proc/`pidof app`/status | grep Thread"
   ```

3. **Правильная настройка тестов:**
   - Избегайте hyperthreading во время тестов
   ```bash
   taskset -c 0-3 ./app  # Фиксируем CPU
   ```

4. **Визуализация:**
   - Flame graphs для потоков:
   ```bash
   perf script | stackcollapse-perf.pl --pid | flamegraph.pl > threads.svg
   ```

---

## Сравнение инструментов

| Инструмент          | Лучшее для                  | Нагрузка | Точность |
|---------------------|----------------------------|----------|----------|
| **perf**           | Аппаратные события         | Низкая   | Высокая  |
| **Valgrind DRD**   | Гонки данных               | Очень высокая | Средняя |
| **TSan**           | Data races                 | Высокая  | Очень высокая |
| **eBPF**           | Динамический анализ ядра   | Низкая   | Высокая  |
| **VTune**          | Полный анализ             | Средняя  | Очень высокая |

---

## Чеклист для оптимизации

1. [ ] Уменьшить contention мьютексов
2. [ ] Устранить false sharing (alignas(64))
3. [ ] Проверить atomic на избыточность
4. [ ] Оптимизировать cache-line usage
5. [ ] Убедиться в отсутствии priority inversion
6. [ ] Проверить scaling (линейный рост при добавлении ядер)

