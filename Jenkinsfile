
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

    parameters {
        choice(
            name: 'PROFILE_VERSION',
            choices: ['v1', 'v2', 'v3'],
            description: 'Select the profile website version to build and publish'
        )
    }

    environment {
        DOCKER_IMAGE = 'dimpulratakonda/profile-system'
    }

    stages {
        stage('Checkout Selected Version') {
            steps {
                script {
                    def branchName = params.PROFILE_VERSION == 'v1'
                        ? 'main'
                        : params.PROFILE_VERSION

                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "*/${branchName}"]],
                        userRemoteConfigs: [[
                            url: 'https://github.com/ratakondadimpul/profile_system.git'
                        ]]
                    ])
                }
            }
        }

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
                    docker build \
                      -t "$DOCKER_IMAGE:$PROFILE_VERSION" .
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

                        docker push "$DOCKER_IMAGE:$PROFILE_VERSION"
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
            echo "SUCCESS: Published ${DOCKER_IMAGE}:${PROFILE_VERSION}"
        }
        failure {
            echo 'FAILURE: Check Console Output.'
        }
        always {
            echo 'Pipeline execution finished.'
        }
    }
}
