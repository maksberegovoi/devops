pipeline {
    agent {
        node {
            label 'kaniko-git'
        }
    }

    environment {
        AWS_REGION   = 'us-east-2'
        ECR_REGISTRY = '164253013547.dkr.ecr.us-east-2.amazonaws.com'
        IMAGE_NAME   = 'lesson-7-ecr'
        IMAGE_TAG    = "v1.0.${BUILD_NUMBER}"
        GIT_BRANCH   = 'main'
        CHART_PATH   = 'charts/django-app'
        COMMIT_EMAIL = 'jenkins@localhost'
        COMMIT_NAME  = 'jenkins'
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push Docker Image to ECR') {
            steps {
                container('kaniko') {
                    sh """
                        /kaniko/executor \
                            --context=dir://. \
                            --dockerfile=Dockerfile \
                            --destination=${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} \
                            --cache=true
                    """
                }
            }
        }

        stage('Update Helm Chart Tag in Git') {
            steps {
                container('git') {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'github-token',
                            usernameVariable: 'GIT_USERNAME',
                            passwordVariable: 'GIT_PAT'
                        )
                    ]) {
                        sh """
                            set -e
                            git clone --branch ${GIT_BRANCH} https://\${GIT_USERNAME}:\${GIT_PAT}@github.com/maksberegovoi/devops.git gitops-repo
                            cd gitops-repo/${CHART_PATH}

                            sed -i "s|tag: .*|tag: \"${IMAGE_TAG}\"|" values.yaml

                            git config user.email "${COMMIT_EMAIL}"
                            git config user.name "${COMMIT_NAME}"
                            git add values.yaml
                            git commit -m "chore: update image tag to ${IMAGE_TAG} [skip ci]" || true
                            git push origin ${GIT_BRANCH}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}