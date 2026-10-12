Для проекта на C/C++ CI/CD pipeline в Jenkins будет выглядеть несколько иначе, так как процесс сборки и тестирования C/C++ проектов отличается от Python. В этом примере я покажу, как настроить CI/CD pipeline для простого проекта на C/C++ с использованием Jenkins.

### Предположим, что у нас есть простой проект:
- Проект написан на C/C++.
- Используется Git для управления версиями.
- Для сборки используется `Makefile`.
- Тесты написаны с использованием `CUnit` или `Google Test`.
- Проект развертывается на удаленном сервере через SSH.

### Шаги для настройки CI/CD pipeline в Jenkins:

#### 1. Установка Jenkins
1. Установите Jenkins на ваш сервер. Вы можете следовать официальной документации: [Jenkins Installation](https://www.jenkins.io/doc/book/installing/).
2. После установки откройте Jenkins в браузере и завершите первоначальную настройку.

#### 2. Установка необходимых плагинов
1. Перейдите в **Manage Jenkins** -> **Manage Plugins**.
2. Установите следующие плагины:
   - **Git**: для работы с Git-репозиториями.
   - **Pipeline**: для создания pipeline.
   - **SSH Pipeline Steps**: для выполнения команд по SSH.

#### 3. Настройка Credentials
1. Перейдите в **Manage Jenkins** -> **Manage Credentials**.
2. Добавьте учетные данные для доступа к вашему Git-репозиторию (например, SSH-ключ или логин/пароль).
3. Добавьте учетные данные для доступа к вашему production серверу через SSH.

#### 4. Создание Jenkins Pipeline
1. Создайте новый **Pipeline** в Jenkins.
2. В разделе **Pipeline** выберите **Pipeline script from SCM**.
3. Укажите ваш Git-репозиторий и выберите учетные данные для доступа к нему.
4. Укажите путь к Jenkinsfile в репозитории (например, `Jenkinsfile`).

#### 5. Создание Jenkinsfile
`Jenkinsfile` — это файл, который описывает этапы pipeline. Создайте его в корне вашего репозитория.

Пример `Jenkinsfile` для простого проекта на C/C++:

```groovy
pipeline {
    agent any

    environment {
        // Укажите переменные окружения, если необходимо
        PROJECT_NAME = "my-cpp-project"
        REMOTE_USER = "deploy-user"
        REMOTE_HOST = "your-production-server.com"
        REMOTE_DIR = "/var/www/my-cpp-project"
    }

    stages {
        stage('Checkout') {
            steps {
                // Получение кода из Git-репозитория
                git branch: 'main', credentialsId: 'your-git-credentials', url: 'git@github.com:your-username/your-repo.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                // Установка необходимых зависимостей (например, компилятора, библиотек)
                sh 'sudo apt-get update && sudo apt-get install -y build-essential cmake libcunit1-dev'
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

        stage('Deploy to Production') {
            steps {
                // Развертывание на production сервере через SSH
                sshagent(credentials: ['your-ssh-credentials']) {
                    sh """
                        rsync -avz --delete . ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}
                        ssh ${REMOTE_USER}@${REMOTE_HOST} 'cd ${REMOTE_DIR} && make'
                        ssh ${REMOTE_USER}@${REMOTE_HOST} 'sudo systemctl restart ${PROJECT_NAME}'
                    """
                }
            }
        }
    }

    post {
        success {
            // Действия при успешном завершении pipeline
            echo 'Pipeline completed successfully!'
        }
        failure {
            // Действия при неудачном завершении pipeline
            echo 'Pipeline failed!'
        }
    }
}
```

#### 6. Запуск Pipeline
1. Сохраните `Jenkinsfile` в вашем репозитории.
2. Вернитесь в Jenkins и запустите pipeline вручную или дождитесь автоматического запуска при пуше в репозиторий (если настроены webhooks).

#### 7. Настройка Webhooks (опционально)
1. Перейдите в настройки вашего Git-репозитория (например, на GitHub).
2. Добавьте webhook, который будет отправлять запросы в Jenkins при каждом пуше в репозиторий.
3. Укажите URL вашего Jenkins сервера и путь к webhook (например, `http://your-jenkins-server/github-webhook/`).

### Итог
Теперь у вас настроен CI/CD pipeline для простого проекта на C/C++ с использованием Jenkins. При каждом изменении кода в репозитории Jenkins автоматически:
1. Получает код.
2. Устанавливает зависимости.
3. Собирает проект.
4. Запускает тесты.
5. Развертывает приложение на production сервере.

Этот pipeline можно расширять и адаптировать под нужды вашего проекта. Например, можно добавить этапы статического анализа кода, интеграции с другими инструментами и т.д.
