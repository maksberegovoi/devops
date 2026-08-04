# 🚀 CI/CD Pipeline: Jenkins + Helm + Terraform + Argo CD

Повний GitOps CI/CD-процес для Django-застосунку на Amazon EKS:

1. **Jenkins** автоматично збирає Docker-образ (Kaniko) та пушить його в **Amazon ECR**
2. **Jenkins** оновлює тег образу в Helm chart (`charts/django-app/values.yaml`) у Git-репозиторії
3. **Argo CD** відстежує зміни в Git та автоматично синхронізує застосунок у кластері

---

## 📐 Схема CI/CD

```text
┌──────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Developer   │────▶│  Git Repository  │────▶│  Jenkins (CI)    │
│  push code   │     │  (GitHub)        │     │  Kubernetes Pod  │
└──────────────┘     └──────────────────┘     └──────────────────┘
                                                       │
                                              ┌────────▼────────┐
                                              │  Kaniko Agent   │
                                              │  Build Image    │
                                              └────────┬────────┘
                                                       │
                                              ┌────────▼────────┐
                                              │  Amazon ECR     │
                                              │  Push Image     │
                                              └────────┬────────┘
                                                       │
                                              ┌────────▼────────┐
                                              │  Update Helm    │
                                              │  Chart Tag in   │
                                              │  Git (values)   │
                                              └────────┬────────┘
                                                       │
                                              ┌────────▼────────┐
                                              │  Argo CD (CD)   │
                                              │  Auto-Sync      │
                                              └────────┬────────┘
                                                       │
                                              ┌────────▼────────┐
                                              │  EKS Cluster    │
                                              │  Django Pods    │
                                              └─────────────────┘
```

---

## 🏗️ Архітектура

| Компонент | Опис |
|-----------|------|
| **Terraform** | Інфраструктура як код: VPC, EKS, ECR, RDS, S3 backend |
| **Jenkins** | CI-сервер, встановлений через Helm, з Kubernetes agents (Kaniko + Git) |
| **Kaniko** | Збірка Docker-образу без Docker daemon у Kubernetes pod |
| **Amazon ECR** | Реєстр Docker-образів |
| **Helm** | Управління Kubernetes-застосунками (django-app chart) |
| **Argo CD** | GitOps-інструмент для автоматичної синхронізації застосунку |
| **RDS/Aurora** | База даних PostgreSQL |

---

## 📁 Структура проекту

```text
devops/
├── main.tf                    # Root Terraform module
├── variables.tf               # Змінні (GitHub PAT, AWS credentials)
├── providers.tf               # AWS, Helm, Kubernetes providers
├── outputs.tf                 # Вихідні дані інфраструктури
├── Jenkinsfile                # Jenkins Declarative Pipeline
├── Dockerfile                 # Django production image
├── charts/
│   └── django-app/            # Helm chart для Django-застосунку
│       ├── Chart.yaml
│       ├── values.yaml        # Тег образу оновлюється Jenkins
│       ├── secret.yaml
│       └── templates/
│           ├── _helpers.tpl
│           ├── configmap.yaml
│           ├── deployment.yaml
│           ├── hpa.yaml
│           └── service.yaml
├── modules/
│   ├── s3-backend/            # S3 bucket + DynamoDB для tfstate
│   ├── vpc/                   # VPC з public/private subnets
│   ├── ecr/                   # ECR repository
│   ├── eks/                   # EKS cluster + node groups
│   ├── rds/                   # RDS/Aurora PostgreSQL
│   ├── jenkins/               # Jenkins через Helm + JCasC
│   │   ├── jenkins.tf
│   │   ├── values.yaml        # JCasC: Kubernetes cloud + credentials
│   │   └── variables.tf
│   └── argo_cd/               # Argo CD через Helm
│       ├── argo_cd.tf
│       ├── values.yaml
│       └── charts/            # Argo CD Application manifest
│           └── templates/
│               └── application.yaml
└── core/                      # Django application source
```

---

## 🔧 Передумови

- AWS CLI (`aws configure`)
- Terraform ≥ 1.0
- Helm ≥ 3.0
- kubectl
- Docker
- GitHub Personal Access Token (з правами `repo`)

---

## 🚀 Крок 1: Розгортання інфраструктури (Terraform)

### 1.1 Ініціалізація

```bash
# Встановити змінні середовища для AWS credentials
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"

# Ініціалізувати Terraform
terraform init
```

### 1.2 Перевірка конфігурації

```bash
# Форматування
terraform fmt -recursive -check

# Валідація
terraform validate

# План змін
terraform plan
```

### 1.3 Застосування

```bash
terraform apply -auto-approve
```

Це створить:
- VPC з public/private subnets
- EKS cluster з node groups
- ECR repository
- RDS PostgreSQL
- Jenkins (через Helm) з Kubernetes cloud
- Argo CD (через Helm) з Application manifest

### 1.4 Налаштування kubeconfig

```bash
aws eks update-kubeconfig --region us-east-2 --name lesson-7-eks
```

---

## 🔧 Крок 2: Налаштування Jenkins

### 2.1 Отримати доступ до Jenkins

```bash
# Отримати LoadBalancer URL
kubectl get svc -n jenkins

# Отримати початковий пароль адміністратора
kubectl exec -it svc/jenkins -n jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

### 2.2 Налаштування credentials

Jenkins автоматично налаштовується через **JCasC** (Configuration as Code) з `modules/jenkins/values.yaml`:

| Credential ID | Тип | Призначення |
|---------------|-----|-------------|
| `github-token` | String | GitHub PAT для push змін у Git |
| `aws-ecr-credentials` | Username/Password | AWS credentials для push в ECR |

### 2.3 Kubernetes Cloud

JCasC автоматично налаштовує **Kubernetes cloud** з pod template `kaniko-git`:
- Контейнер `kaniko` — збірка Docker-образу
- Контейнер `git` — оновлення Helm chart у Git

### 2.4 Створення Pipeline job

1. Відкрийте Jenkins UI
2. **New Item** → назвіть `django-app-pipeline` → виберіть **Pipeline**
3. У розділі **Pipeline**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/maksberegovoi/devops.git`
   - Script Path: `Jenkinsfile`
4. Збережіть та запустіть build

---

## 🔧 Крок 3: Jenkins Pipeline (Jenkinsfile)

`Jenkinsfile` реалізує declarative pipeline з наступними стадіями:

### 3.1 Checkout
Клонує репозиторій з кодом Django-застосунку.

### 3.2 Build & Push Docker Image to ECR
- Використовує **Kaniko** для збірки образу без Docker daemon
- Автентифікується в ECR через AWS credentials
- Пушить образ з тегом `v1.0.${BUILD_NUMBER}`

```groovy
/kaniko/executor \
    --context $(pwd) \
    --dockerfile $(pwd)/Dockerfile \
    --destination=${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} \
    --cache=true
```

### 3.3 Update Helm Chart Tag in Git
- Клонує GitOps-репозиторій
- Оновлює `tag` у `charts/django-app/values.yaml`
- Комітить та пушить зміни в `main`

```bash
sed -i "s|tag: .*|tag: ${IMAGE_TAG}|" values.yaml
git commit -m "chore: update image tag to ${IMAGE_TAG} [skip ci]"
git push origin main
```

---

## 🔧 Крок 4: Argo CD

### 4.1 Отримати доступ до Argo CD

```bash
# Отримати пароль адміністратора
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Отримати LoadBalancer URL
kubectl get svc -n argocd argo-cd-argocd-server
```

### 4.2 Argo CD Application

Argo CD Application (`django-app`) налаштований через Helm chart `modules/argo_cd/charts`:

```yaml
spec:
  source:
    repoURL: https://github.com/maksberegovoi/devops.git
    targetRevision: main
    path: charts/django-app
    helm:
      valueFiles:
        - values.yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 4.3 Автоматична синхронізація

Коли Jenkins оновлює тег образу в `values.yaml` і пушить у Git:
1. Argo CD виявляє зміни в репозиторії (протягом ~3 хвилин)
2. Автоматично синхронізує застосунок у кластері
3. Kubernetes rolling update замінює pod'и з новим образом

---

## 🔄 Повний цикл CI/CD

```text
1. Developer push code → GitHub
2. Jenkins pipeline запускається (webhook або вручну)
3. Kaniko збирає Docker-образ
4. Образ пушиться в ECR з тегом v1.0.N
5. Jenkins оновлює tag у charts/django-app/values.yaml
6. Jenkins комітить та пушить зміни в main
7. Argo CD виявляє зміни в Git
8. Argo CD синхронізує застосунок у EKS
9. Нові pod'и запускаються з новим образом
```

---

## 🧪 Перевірка

### Перевірка Helm charts

```bash
helm lint charts/django-app
helm lint modules/argo_cd/charts
```

### Перевірка Terraform

```bash
terraform fmt -recursive -check
terraform init -backend=false
terraform validate
```

### Перевірка застосунку

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
kubectl get configmap
```

### Перевірка Argo CD

```bash
kubectl -n argocd get applications
kubectl -n argocd get application django-app -o yaml
```

---

## 🧹 Очищення

```bash
# Видалити Helm release
helm uninstall django-app

# Видалити ECR repository
aws ecr delete-repository --repository-name lesson-7-ecr --region us-east-2 --force

# Знищити всю інфраструктуру
terraform destroy -auto-approve
```

---

## 📚 Документація

- [Jenkins Pipeline](https://www.jenkins.io/doc/book/pipeline/)
- [Jenkins Configuration as Code](https://www.jenkins.io/projects/jcasc/)
- [Kaniko](https://github.com/GoogleContainerTools/kaniko)
- [Argo CD](https://argo-cd.readthedocs.io/)
- [Helm](https://helm.sh/docs/)
- [Terraform](https://developer.hashicorp.com/terraform/docs)
