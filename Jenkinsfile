// Jenkinsfile (Declarative Pipeline)

pipeline {
    // agent any
    agent { docker { image 'python:3.10.1-alpine' } }
    stages {
        stage('build') {
            steps {
                sh 'python3 --version'
            }
        }
    }
}
