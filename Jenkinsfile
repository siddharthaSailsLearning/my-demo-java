pipeline {
    agent any  // Runs on Jenkins node (with Docker sock)

    environment {
        DOCKER_IMAGE = 'siddhussoft136/demo-java'  // Replace with your Docker Hub repo
        DOCKER_TAG = 'latest'
        APP_PORT = '8080'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm  // Auto-checkout from repo
            }
        }

        stage('Maven Build') {
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-17'  // Maven + JDK17 in container
                    args '-v /var/run/docker.sock:/var/run/docker.sock'  // Pass Docker sock if needed later
                }
            }
            steps {
                echo 'Building WAR with Maven...'
                sh 'mvn clean package -DskipTests'  // Builds target/demo.war (skip tests here for speed)
                sh 'mkdir -p pkg && cp target/demo.war pkg/'  // Move WAR as per original build script
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                script {
                    def image = docker.build("${env.DOCKER_IMAGE}:${env.DOCKER_TAG}")
                    env.BUILT_IMAGE = image.id
                }
            }
        }

        stage('Docker Push') {
            steps {
                echo 'Pushing image to Docker Hub...'
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                        docker.image("${env.DOCKER_IMAGE}:${env.DOCKER_TAG}").push()
                    }
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Pulling and testing image...'
                script {
                    // Pull latest (in case of concurrent pushes)
                    sh "docker pull ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}"
                    
                    // Run temp container for tests
                    def testContainer = docker.run("${env.DOCKER_IMAGE}:${env.DOCKER_TAG}", 
                                                  '-p 8080:8080 --rm', 
                                                  [], 30)  // Timeout 30s
                    
                    // Wait for startup (Tomcat ~10s)
                    sleep 15
                    
                    // Curl tests
                    sh "curl -f http://localhost:8080/demo/Hello || exit 1"  // Expect "Hello World Hello.java"
                    sh "curl -f http://localhost:8080/demo/index.jsp || exit 1"  // Expect "Hello World index.jsp"
                    
                    // Cleanup
                    docker.stop(testContainer)
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying to localhost...'
                script {
                    // Stop existing container if running (name: demo-app)
                    sh 'docker stop demo-app || true'
                    sh 'docker rm demo-app || true'
                    
                    // Run new container
                    sh "docker run -d --name demo-app -p ${env.APP_PORT}:8080 ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}"
                    
                    // Verify deployment
                    sleep 10
                    sh "curl -f http://localhost:${env.APP_PORT}/demo/Hello || exit 1"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed!'
            // Cleanup workspace if needed
            cleanWs()
        }
        success {
            echo 'Build successful! App live at http://localhost:8080/demo/Hello'
        }
        failure {
            echo 'Pipeline failed. Check logs.'
            // Optional: Slack/email notification
        }
    }
}
