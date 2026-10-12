Для настройки SonarQube локально на macOS Catalina для анализа C++ проекта, выполните следующие шаги:

### Шаг 1: Установка SonarQube
1. **Скачайте SonarQube**:
   - Перейдите на [официальный сайт SonarQube](https://www.sonarqube.org/downloads/) и скачайте последнюю версию SonarQube.

2. **Установите SonarQube**:
   - Распакуйте скачанный архив в удобное место, например, в `~/sonarqube`.

3. **Запустите SonarQube**:
   - Откройте терминал и перейдите в директорию, куда вы распаковали SonarQube:
     ```bash
     cd ~/sonarqube/bin/macosx-universal-64
     ```
   - Запустите SonarQube:
     ```bash
     ./sonar.sh start
     ```
   - Проверьте, что SonarQube запустился, открыв в браузере `http://localhost:9000`.

### Шаг 2: Установка SonarScanner
1. **Скачайте SonarScanner**:
   - Перейдите на [официальный сайт SonarScanner](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/) и скачайте версию для macOS.

2. **Установите SonarScanner**:
   - Распакуйте скачанный архив в удобное место, например, в `~/sonar-scanner`.

3. **Настройте SonarScanner**:
   - Откройте файл `~/sonar-scanner/conf/sonar-scanner.properties` и добавьте следующие строки:
     ```properties
     sonar.host.url=http://localhost:9000
     sonar.login=your_token
     ```
   - Замените `your_token` на токен, который вы создадите в SonarQube (см. следующий шаг).

### Шаг 3: Создание проекта в SonarQube
1. **Создайте проект**:
   - Откройте SonarQube в браузере (`http://localhost:9000`).
   - Перейдите в раздел "Projects" и нажмите "Create new project".
   - Введите имя проекта и нажмите "Generate" для создания токена.

2. **Сохраните токен**:
   - Скопируйте сгенерированный токен и используйте его в настройках SonarScanner.

### Шаг 4: Настройка CMake для анализа кода
1. **Добавьте SonarScanner в CMake**:
   - В корне вашего проекта создайте файл `sonar-project.properties` с содержимым:
     ```properties
     sonar.projectKey=your_project_key
     sonar.projectName=Your Project Name
     sonar.projectVersion=1.0
     sonar.sources=src
     sonar.cfamily.build-wrapper-output=bw-output
     sonar.sourceEncoding=UTF-8
     sonar.cxx.file.suffixes=.cpp,.hpp,.c,.h
     sonar.cxx.compiler.charset=UTF-8
     sonar.cxx.compiler.encoding=UTF-8
     ```

2. **Создайте Build Wrapper**:
   - Скачайте и установите [Build Wrapper](https://docs.sonarqube.org/latest/analysis/languages/cfamily/).
   - Используйте Build Wrapper для сборки проекта:
     ```bash
     build-wrapper-macosx-x86 --out-dir bw-output cmake --build .
     ```

### Шаг 5: Запуск анализа
1. **Запустите SonarScanner**:
   - В терминале перейдите в корневую директорию вашего проекта и выполните:
     ```bash
     ~/sonar-scanner/bin/sonar-scanner
     ```

2. **Проверьте результаты**:
   - Откройте SonarQube в браузере и проверьте результаты анализа вашего проекта.

### Шаг 6: Интеграция с Qt5
1. **Добавьте логирование**:
   - Используйте библиотеку логирования, например, `spdlog` или `Boost.Log`, для записи логов в файл.

2. **Отображение логов в GUI**:
   - Создайте интерфейс в Qt5 для отображения логов. Например, используйте `QTextEdit` или `QPlainTextEdit` для вывода содержимого лог-файла.

### Шаг 7: Настройка CI/CD (опционально)
1. **Интеграция с GitHub Actions или Jenkins**:
   - Настройте автоматический запуск SonarScanner при каждом коммите или пулл-реквесте.

Теперь ваш проект настроен для статического анализа кода с использованием SonarQube.