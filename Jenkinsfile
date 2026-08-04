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

        stage('Generate ECR auth') {
            steps {
                container('awscli') {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'aws-ecr-credentials',
                            usernameVariable: 'AWS_ACCESS_KEY_ID',
                            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                        )
                    ]) {
                        sh '''
                            ECR_HOST=$(echo "${ECR_REGISTRY}" | cut -d'/' -f1)
                            TOKEN=$(aws ecr get-login-password --region "${AWS_REGION}")
                            AUTH=$(echo -n "AWS:${TOKEN}" | base64 -w 0)
                            mkdir -p /kaniko/.docker
                            echo "{ \\"auths\\": { \\"${ECR_HOST}\\": { \\"auth\\": \\"${AUTH}\\" } } }" > /kaniko/.docker/config.json
                        '''
                    }
                }
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

        stage('Update Helm Chart & Push to Git') {
            steps {
                container('yq') {
                    sh """
                        yq -i '.image.repository = "${ECR_REGISTRY}/${IMAGE_NAME}" | .image.tag = "${IMAGE_TAG}"' ${CHART_PATH}/values.yaml
                    """
                }
                container('git') {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'github-token',
                            usernameVariable: 'GIT_USERNAME',
                            passwordVariable: 'GIT_PAT'
                        )
                    ]) {
                        sh """
                            git clone --branch ${GIT_BRANCH} https://\${GIT_USERNAME}:\${GIT_PAT}@github.com/maksberegovoi/devops.git gitops-repo
                            cd gitops-repo
                            git config user.email "${COMMIT_EMAIL}"
                            git config user.name "${COMMIT_NAME}"
                            git add ${CHART_PATH}/values.yaml
                            git diff --cached --quiet || git commit -m "chore: update image tag to ${IMAGE_TAG} [skip ci]"
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