
pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 10, unit: 'MINUTES')
        buildDiscarder(logRotator(
            numToKeepStr: '10',
            artifactNumToKeepStr: '5'
        ))
    }

    environment {
        DOCKER_IMAGE = 'dimpulratakonda/profile-system'
        IMAGE_TAG = 'v1'
    }

    stages {
        stage('Validate Files') {
            steps {
                sh '''
                    set -eu
                    test -f index.html
                    test -f image.png
                    test -f Dockerfile
                    echo "Required files exist."
                '''
            }
        }

        stage('Validate HTML') {
            steps {
                sh '''
                    set -eu
                    grep -Eiq '<!doctype html' index.html
                    grep -Eiq '<html([[:space:]>])' index.html
                    grep -Eiq '<head([[:space:]>])' index.html
                    grep -Eiq '<body([[:space:]>])' index.html
                    grep -Eiq '</html[[:space:]]*>' index.html
                    echo "HTML validation passed."
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    set -eu
                    export PATH="/usr/local/bin:$PATH"
                    docker build -t "$DOCKER_IMAGE:$IMAGE_TAG" .
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        set -eu
                        export PATH="/usr/local/bin:$PATH"

                        echo "$DOCKER_PASSWORD" |
                            docker login \
                                --username "$DOCKER_USERNAME" \
                                --password-stdin

                        docker push "$DOCKER_IMAGE:$IMAGE_TAG"
                        docker logout
                    '''
                }
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
            echo 'SUCCESS: Docker image published to Docker Hub.'
        }
        failure {
            echo 'FAILURE: Check Console Output.'
        }
        always {
            echo 'Pipeline execution finished.'
        }
    }
}
