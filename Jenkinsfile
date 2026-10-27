pipeline {
    agent any
    options {
        timestamps()
        timeout(time: 5, unit: 'MINUTES')
        buildDiscarder(logRotator(
            numToKeepStr: '10',
            artifactNumToKeepStr: '5'
        ))
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/ratakondadimpul/profile_system.git'
            }
        }
        stage('Validate Files') {
            steps {
                sh '''
                    set -eu
                    echo "Checking required files..."
                    test -f index.html
                    test -f image.png
                    echo "Both required files exist."
                '''
            }
        }
        stage('Validate HTML') {
            steps {
                sh '''
                    set -eu
                    echo "Checking basic HTML structure..."
                    grep -Eiq '<!doctype html' index.html
                    grep -Eiq '<html([[:space:]>])' index.html
                    grep -Eiq '<head([[:space:]>])' index.html
                    grep -Eiq '<body([[:space:]>])' index.html
                    grep -Eiq '</html[[:space:]]*>' index.html
                    echo "Basic HTML structure validation passed."
                '''
            }
        }
        stage('Archive Website') {
            steps {
                archiveArtifacts(
                    artifacts: 'index.html,image.png',
                    fingerprint: true
                )
            }
        }
    }
    post {
        success {
            echo 'SUCCESS: Profile System pipeline completed.'
        }
        failure {
            echo 'FAILURE: Check the Console Output for errors.'
        }
        always {
            echo 'Pipeline execution finished.'
        }
    }
}
