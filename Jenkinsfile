pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = "zaarahirani/selfhealing-app"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials"
    }
    stages {
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                    sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                }
            }
        }
        stage('Deploy New App Version') {
            steps {
                sh "kubectl set image deployment/selfhealing-app-deployment selfhealing-app-container=${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                sh "kubectl rollout status deployment/selfhealing-app-deployment"
            }
        }
    }
}
