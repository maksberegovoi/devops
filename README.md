## Infrastructure & Project Structure

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

## Deployment Guide
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
