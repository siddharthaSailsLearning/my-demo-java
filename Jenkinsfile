pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        DOCKERHUB_USER = "${DOCKERHUB_CREDENTIALS_USR}"
        DOCKERHUB_PASS = "${DOCKERHUB_CREDENTIALS_PSW}"
        IMAGE_NAME = "siddhussoft136/java-app"
    }

    triggers {
        githubPush() // Triggers automatically when push happens
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/siddharthaSailsLearning/my-demo-java.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $IMAGE_NAME:latest .'
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    sh "echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh 'docker push $IMAGE_NAME:latest'
                }
            }
        }

        stage('Deploy Locally') {
            steps {
                script {
                    // Stop any old container
                    sh 'docker rm -f my-java-app || true'
                    // Pull latest image
                    sh 'docker pull $IMAGE_NAME:latest'
                    // Run container
                    sh 'docker run -d --name my-java-app -p 8081:8080 $IMAGE_NAME:latest'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
