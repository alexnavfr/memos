На macOS 10.15 Catalina можно поднять локальный CI/CD pipeline с использованием Jenkins. Это полезно для тестирования и отладки pipeline перед его развертыванием на production сервере. Ниже я подробно опишу, как это сделать.

---

### Шаги для настройки локального CI/CD pipeline на macOS 10.15 Catalina

#### 1. Установка Homebrew
Homebrew — это пакетный менеджер для macOS, который упрощает установку программ. Если он у вас еще не установлен, выполните в терминале:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2. Установка Jenkins
1. Установите Jenkins с помощью Homebrew:
   ```bash
   brew install jenkins-lts
   ```
2. Запустите Jenkins:
   ```bash
   brew services start jenkins-lts
   ```
3. Откройте Jenkins в браузере по адресу: `http://localhost:8080`.
4. Следуйте инструкциям на экране для первоначальной настройки. Вам нужно будет:
   - Скопировать пароль из файла, который указан на экране (например, `/Users/your-user/.jenkins/secrets/initialAdminPassword`).
   - Установить рекомендуемые плагины.

#### 3. Установка необходимых инструментов
Для сборки и тестирования C/C++ проекта на macOS вам понадобятся:
- Компилятор C/C++ (например, `gcc` или `clang`).
- Утилита `make`.
- CMake (если используется).
- Git.

Установите их с помощью Homebrew:

```bash
brew install gcc make cmake git
```

#### 4. Настройка Jenkins Pipeline
1. Создайте новый **Pipeline** в Jenkins.
2. В разделе **Pipeline** выберите **Pipeline script** или **Pipeline script from SCM** (если вы хотите использовать Jenkinsfile из репозитория).
3. Если вы используете локальный репозиторий, укажите путь к нему.

#### 5. Создание Jenkinsfile
Создайте `Jenkinsfile` в корне вашего проекта. Пример для C/C++ проекта:

```groovy
pipeline {
    agent any

    environment {
        // Укажите переменные окружения, если необходимо
        PROJECT_NAME = "my-cpp-project"
    }

    stages {
        stage('Checkout') {
            steps {
                // Получение кода из локального репозитория
                git branch: 'main', url: 'file:///path/to/your/local/repo'
            }
        }

        stage('Install Dependencies') {
            steps {
                // Установка необходимых зависимостей (если нужно)
                sh 'brew install cmake'
            }
        }

        stage('Build') {
            steps {
                // Сборка проекта с использованием Makefile
                sh 'make'
            }
        }

        stage('Run Tests') {
            steps {
                // Запуск тестов
                sh 'make test'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

#### 6. Запуск Pipeline
1. Сохраните `Jenkinsfile` в вашем репозитории.
2. Вернитесь в Jenkins и запустите pipeline вручную.

#### 7. Локальное развертывание (опционально)
Если вы хотите развернуть проект локально, добавьте этап развертывания в `Jenkinsfile`. Например:

```groovy
stage('Deploy Locally') {
    steps {
        sh 'cp ./your-binary /usr/local/bin/your-binary'
    }
}
```

#### 8. Настройка Webhooks (опционально)
Если вы хотите автоматически запускать pipeline при изменении кода в локальном репозитории, можно использовать утилиту `watchexec` для отслеживания изменений:

1. Установите `watchexec`:
   ```bash
   brew install watchexec
   ```
2. Запустите отслеживание изменений в репозитории:
   ```bash
   watchexec -w /path/to/your/repo -- curl -X POST http://localhost:8080/job/your-job/build
   ```

---

### Итог
Теперь у вас настроен локальный CI/CD pipeline на macOS 10.15 Catalina с использованием Jenkins. Вы можете:
- Собирать и тестировать C/C++ проект.
- Автоматически запускать pipeline при изменении кода.
- Развертывать проект локально.

Этот подход позволяет тестировать и отлаживать pipeline перед его развертыванием на production сервере.
