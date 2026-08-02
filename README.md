# Infrastructure & Project Structure

```text
lesson-7/
├── main.tf                  # Root module connecting VPC, ECR, S3, EKS
├── backend.tf               # S3 Remote State + DynamoDB Lock configuration
├── outputs.tf               # Infrastructure outputs
├── modules/
│   ├── s3-backend/          # S3 bucket for tfstate & DynamoDB table for locks
│   ├── vpc/                 # VPC with Public/Private subnets, IGW, NAT Gateway
│   ├── ecr/                 # ECR repository with scan-on-push & lifecycle rules
│   └── eks/                 # Amazon EKS Cluster + Managed Node Groups (t3.small)
│   └── jenkins/             # Module for Helm installation Jenkins
│   └── agro_cd/             # Module for Helm installation AgroCD
│   └── rds/                 # Module for RDS
├── charts/
│   └── django-app/          # Custom Helm Chart
│       ├── templates/
│       │   ├── configmap.yaml   # Environment variables from Lesson 4
│       │   ├── deployment.yaml  # Deployment referencing ECR image & envFrom
│       │   ├── service.yaml     # Service type LoadBalancer
│       │   └── hpa.yaml         # Horizontal Pod Autoscaler (2 min, 6 max)
│       ├── Chart.yaml
│       └── values.yaml          # Values configuration for image, service & scaling
├── Dockerfile               # Production multi-stage Docker build for Django
├── docker-compose.yml       # Local development setup
├── core/                    # Django application source code
└── requirements.txt         # Python dependencies
```

# Flexible RDS / Aurora Terraform Module

This module provisions either a **Single Amazon RDS Instance** or an **Amazon Aurora Cluster** based on a single boolean variable (`use_aurora`).

## Features
- Conditional creation of Single RDS (`aws_db_instance`) or Aurora (`aws_rds_cluster`).
- Managed `DB Subnet Group` and `Security Group`.
- Dynamic `Parameter Group` setup according to engine type.


## Usage Example

### 1. Standard PostgreSQL RDS Instance
```hcl
module "rds" {
  source     = "./modules/rds"
  
  name       = "my-app-db"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  use_aurora     = false
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t4g.micro"
  
  db_name        = "app_db"
  admin_username = "db_user"
  admin_password = "SecurePassword123!"
}
```

### 2. High-Availability Aurora PostgreSQL Cluster
```hcl
module "rds" {
  source     = "./modules/rds"
  
  name       = "my-aurora-cluster"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  use_aurora     = true
  engine         = "aurora-postgresql"
  engine_version = "15.4"
  instance_class = "db.r6g.large"
  
  db_name        = "app_db"
  admin_username = "db_user"
  admin_password = "SecurePassword123!"
}
```

# End-to-End GitOps Pipeline (Jenkins + Argo CD + EKS)

Project provisions an Amazon EKS cluster with Terraform, installs **Jenkins** and **Argo CD** via Helm, and implements an automated GitOps CI/CD delivery pipeline.

## 🏗 Architecture Overview

```text
+--------------+        +-------------------+        +----------------+
|  Developer   | ---->  | Push Code to Git  | ---->  |  Jenkins CI    |
+--------------+        +-------------------+        +----------------+
                                                              |
                                                    (Build Image via Kaniko)
                                                              v
+--------------+        +-------------------+        +----------------+
| Argo CD Sync | <----  | Update Helm Tag   | <----  |  Push to ECR   |
| to EKS Pods  |        | in Git Repository |        +----------------+
+--------------+        +-------------------+
```
1. Provision Infrastructure with Terraform
```bash
# Initialize Terraform
terraform init

# Validate Configuration
terraform validate

# Apply Resources (VPC, EKS, ECR, Jenkins, Argo CD)
terraform apply -auto-approve
```

2. Verify Jenkins CI Job
```bash
# Get the Jenkins external URL & initial admin password:

kubectl get svc -n jenkins

kubectl exec -it svc/jenkins -n jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword

# Open Jenkins dashboard in your browser.

# Create a Pipeline job pointing to your Git repository's Jenkinsfile.

# Run the build. Kaniko will build the image, push it to ECR, and commit the updated IMAGE_TAG to charts/django-app/values.yaml.
```

3. Verify Argo CD GitOps Deployment

```bash
# Retrieve Argo CD admin password:

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Get Argo CD UI LoadBalancer address:

kubectl get svc -n argocd argo-cd-argocd-server

# Open Argo CD UI and verify that the django-app Application is status Synced and Healthy.

# Whenever Jenkins updates the image tag in Git, Argo CD auto-detects changes within 3 minutes and updates running pods in Kubernetes.
```

# Access Grafana Monitoring Dashboard
```bash
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
```

# Deployment Guide
Initialize local state
```bash
   terraform init
   ```

Apply infrastructure (VPC, S3, DynamoDB, ECR, EKS)
```bash
terraform apply -auto-approve
```

Migrate state to S3 Remote Backend
```bash
terraform init -migrate-state
```

Configure Local Kubeconfig
```bash
aws eks update-kubeconfig --region us-east-2 --name lesson-7-eks
```

Build & Push Docker Image to ECR

```bash
# Authenticate Docker to AWS ECR
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 164253013547.dkr.ecr.us-east-2.amazonaws.com

# Build Docker Image
docker build -t [164253013547.dkr.ecr.us-east-2.amazonaws.com/lesson-7-ecr:latest](https://164253013547.dkr.ecr.us-east-2.amazonaws.com/lesson-7-ecr:latest) .

# Push to ECR
docker push [164253013547.dkr.ecr.us-east-2.amazonaws.com/lesson-7-ecr:latest](https://164253013547.dkr.ecr.us-east-2.amazonaws.com/lesson-7-ecr:latest)
```

## Authenticate Docker to AWS ECR
```bash
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 164253013547.dkr.ecr.us-east-2.amazonaws.com
```
## Build Docker Image
```bash
docker build -t [164253013547.dkr.ecr.us-east-2.amazonaws.com/lesson-7-ecr:latest](https://164253013547.dkr.ecr.us-east-2.amazonaws.com/lesson-7-ecr:latest) .
```
## Push to ECR
```bash
docker push [164253013547.dkr.ecr.us-east-2.amazonaws.com/lesson-7-ecr:latest](https://164253013547.dkr.ecr.us-east-2.amazonaws.com/lesson-7-ecr:latest)
```

4. Deploy Application via Helm Chart

## Install Helm Release
```bash
helm install django-app ./charts/django-app
```

## Verify Kubernetes Resources
```bash
kubectl get pods
kubectl get svc
kubectl get hpa
kubectl get configmap
```


## Helm Chart Features
Deployment: Pulls image from ECR with envFrom mounting environment variables.

ConfigMap: Stores non-sensitive runtime configurations (DEBUG, ALLOWED_HOSTS, DB_ENGINE).

Service: Type LoadBalancer exposing port 80 externally via AWS ELB.

HPA: Scales pods dynamically from 2 to 6 replicas based on 70% CPU utilization.

## Uninstall Helm Chart to remove AWS Load Balancer
```bash
helm uninstall django-app
```

## Force delete ECR repository images
```bash
aws ecr delete-repository --repository-name lesson-7-ecr --region us-east-2 --force
```

## Destroy AWS Infrastructure ( optional )
```bash
terraform destroy -auto-approve
```
