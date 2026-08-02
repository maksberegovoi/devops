pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.14.0-debug
    command:
    - sleep
    args:
    - 99d
    volumeMounts:
    - name: aws-secret
      mountPath: /root/.aws
  - name: git
    image: alpine/git:v2.32.0
    command:
    - sleep
    args:
    - 99d
  volumes:
  - name: aws-secret
    emptyDir: {}
'''
        }
    }

    environment {
        AWS_REGION     = 'us-east-2'
        ECR_REGISTRY   = '164253013547.dkr.ecr.us-east-2.amazonaws.com'
        ECR_REPOSITORY = 'lesson-7-ecr'
        IMAGE_TAG      = "v${BUILD_NUMBER}"
    }

    stages {
        stage('Build & Push to ECR via Kaniko') {
            steps {
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                      --context=dir://. \
                      --dockerfile=Dockerfile \
                      --destination=${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} \
                      --destination=${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                    '''
                }
            }
        }

        stage('Update Helm Values & Git Push') {
            steps {
                container('git') {
                    sh '''
                    git config --global user.email "jenkins-ci@example.com"
                    git config --global user.name "Jenkins CI"

                    # Обновляем тег образа в values.yaml
                    sed -i "s/tag: .*/tag: \"${IMAGE_TAG}\"/" charts/django-app/values.yaml

                    git add charts/django-app/values.yaml
                    git commit -m "ci: update image tag to ${IMAGE_TAG} [skip ci]" || true
                    git push origin HEAD:main
                    '''
                }
            }
        }
    }
}