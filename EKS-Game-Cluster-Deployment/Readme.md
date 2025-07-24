# EKS 2048 Game Deployment Guide

This documentation explains the step-by-step process of deploying a 2048 game application on Amazon EKS (Elastic Kubernetes Service) using Fargate and AWS Load Balancer Controller.



## Overview

The deployment creates:
- An EKS cluster running on AWS Fargate
- A 2048 game application with proper load balancing
- AWS Load Balancer Controller for ingress management
- Proper IAM roles and service accounts for AWS integration

## Prerequisites Setup



### 1. Install Required Tools

```bash
# Install zip utility for extracting AWS CLI
apt install zip -y

# Extract and install AWS CLI v2
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials and region
aws configure
```<img width="1089" height="238" alt="Screenshot_1" src="https://github.com/user-attachments/assets/ce2940a9-a30d-47d9-b77a-055f582cb907" />


**Significance**: Sets up the AWS CLI tool needed to interact with AWS services. The `aws configure` command prompts for your AWS Access Key, Secret Key, default region, and output format.



### 2. Install kubectl

```bash
# Download kubectl binary for EKS version 1.33.0
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl


# Make kubectl executable
chmod +x ./kubectl


# Install kubectl to user's bin directory and update PATH
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH


# Persist PATH changes to bashrc
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
```


**Significance**: kubectl is the command-line tool for communicating with Kubernetes clusters. This installs the specific version compatible with EKS 1.33.0 and ensures it's available in your PATH permanently.


## EKS Cluster Creation


### 3. Create EKS Cluster

# First Installing ekctl by downloading the below script from [here](https://eksctl.io/installation/#for-unix:~:text=Limited%3A%20List%2C%20Read-,For%20Unix,%C2%B6,-To%20download%20the)



```bash

# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl
```


```bash

# You can Create Script of the above command run it ( as shown below--script is created with the file name eks.sh)
<img width="563" height="89" alt="Screenshot_3" src="https://github.com/user-attachments/assets/e3ff0fa2-a15d-4b5f-94ae-d8e9f19f3e06" />

# Create EKS cluster with Fargate profile
eksctl create cluster --name game-2048-cluster --region us-east-1 --fargate
```




```bash
# Create EKS cluster with Fargate profile
eksctl create cluster --name game-2048-cluster --region us-east-1 --fargate
```


**Significance**: Creates a managed Kubernetes cluster in AWS. The `--fargate` flag means pods will run on AWS Fargate (serverless containers) instead of EC2 instances, eliminating the need to manage worker nodes.



### 4. Configure kubectl Context



```bash
# Update kubeconfig to connect to the new cluster
aws eks update-kubeconfig --name game-2048-cluster --region us-east-1
```

**Significance**: Updates your local kubectl configuration to point to the newly created EKS cluster, allowing you to run kubectl commands against it.



## Application Deployment



### 5. Create Fargate Profile for Application


```bash
# Create Fargate profile for the game-2048 namespace
eksctl create fargateprofile \
    --cluster game-2048-cluster \
    --region us-east-1 \
    --name alb-sample-app \
    --namespace game-2048
```


**Significance**: Fargate profiles determine which pods run on Fargate. This creates a profile specifically for the `game-2048` namespace, ensuring the application pods will run on Fargate infrastructure.



### 6. Deploy the 2048 Game Application


```bash
# Deploy the 2048 game application
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/examples/2048/2048_full.yaml
```


**Significance**: Deploys the complete 2048 game application stack, including:
- Deployment (application pods)
- Service (internal load balancing)
- Ingress (external access configuration)


### 7. Monitor Pod Status


```bash
# Watch pods in the game-2048 namespace
kubectl get pods -n game-2048 -w
```


<img width="1540" height="693" alt="Screenshot_4" src="https://github.com/user-attachments/assets/103d8f7e-0697-4503-ad97-365ef6e04583" />



**Significance**: Monitors the deployment progress. The `-w` flag watches for changes in real-time, showing when pods transition from Pending to Running state.


## AWS Load Balancer Controller Setup


### 8. Associate OIDC Provider

```bash
# Associate IAM OIDC identity provider with the cluster
eksctl utils associate-iam-oidc-provider --cluster game-2048-cluster --approve
```


**Significance**: Enables the cluster to assume IAM roles using OpenID Connect. This is required for pods to authenticate with AWS services using IAM roles instead of long-term credentials.


### 9. Create IAM Policy

```bash
# Download the required IAM policy for Load Balancer Controller
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json

# Create IAM policy for AWS Load Balancer Controller
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```


<img width="1489" height="305" alt="Screenshot_5" src="https://github.com/user-attachments/assets/69642238-5e4c-48c2-a2f0-306e7d5f10f1" />



**Significance**: Creates an IAM policy that grants the Load Balancer Controller the necessary permissions to:
- Create and manage Application Load Balancers (ALB)
- Create and manage Network Load Balancers (NLB)
- Manage target groups and security groups
- Read EC2 and EKS resources


### 10. Create Service Account with IAM Role


```bash
# Create service account with attached IAM role
eksctl create iamserviceaccount \
  --cluster=game-2048-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::<account-ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```


**Significance**: Creates a Kubernetes service account that's linked to an IAM role. This enables the Load Balancer Controller pods to assume the IAM role and interact with AWS services securely.


## Helm Installation and Load Balancer Controller Deployment


### 11. Install Helm

```bash
# Install Helm package manager
sudo snap install helm --classic

# Add EKS Helm repository
helm repo add eks https://aws.github.io/eks-charts
```


**Significance**: Helm is a package manager for Kubernetes that simplifies the deployment of complex applications. The EKS charts repository contains AWS-maintained Helm charts, including the Load Balancer Controller.



### 12. Deploy AWS Load Balancer Controller


```bash
# Install AWS Load Balancer Controller using Helm
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
  --set clusterName=game-2048-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=<Enter-VPC-ID>
```


**Significance**: This command deploys the AWS Load Balancer Controller using Helm with specific configuration parameters:


- **`clusterName=game-2048-cluster`**: Specifies the EKS cluster name for the controller to manage
- **`serviceAccount.create=false`**: Tells Helm not to create a new service account since we created one in step 10
- **`serviceAccount.name=aws-load-balancer-controller`**: Uses the existing service account with IAM role bindings
- **`region=us-east-1`**: Specifies the AWS region where load balancers will be created
- **`vpcId=vpc-070843a4500c9bf06`**: Identifies the VPC where the EKS cluster and load balancers reside


The controller will now automatically:
- Monitor Kubernetes Ingress resources
- Create AWS Application Load Balancers (ALB) or Network Load Balancers (NLB) as needed
- Manage target groups and register pods as targets
- Handle SSL termination and routing rules

  
<img width="1214" height="358" alt="Screenshot_6" src="https://github.com/user-attachments/assets/adabc3d3-7a6b-4f56-a7f8-33259d0c9a12" />


## Verification


### 13. Monitor Load Balancer Controller Deployment

```bash
# Watch the Load Balancer Controller deployment status
kubectl get deployment -n kube-system aws-load-balancer-controller -w

# Check current status
kubectl get deployment -n kube-system aws-load-balancer-controller
```


**Significance**: Verifies that the AWS Load Balancer Controller is properly deployed and running. This controller will automatically create AWS load balancers based on Kubernetes Ingress resources.


## Architecture Summary


The completed setup creates:

1. **EKS Cluster**: Managed Kubernetes control plane in AWS
2. **Fargate**: Serverless container hosting for application pods
3. **2048 Game Application**: Web-based game running in pods
4. **AWS Load Balancer Controller**: Manages AWS load balancers for ingress traffic
5. **IAM Integration**: Secure authentication between Kubernetes and AWS services

## Security Features


- **OIDC Integration**: Enables secure IAM role assumption without long-term credentials
- **Least Privilege**: IAM policy grants only necessary permissions
- **Service Account Binding**: Links Kubernetes service accounts to AWS IAM roles
- **Namespace Isolation**: Application runs in dedicated namespace


## Next Steps


After completing these steps, you should have:
- A running 2048 game accessible via an AWS Application Load Balancer
- Proper monitoring and logging capabilities
- A scalable, serverless Kubernetes application platform

To access the application, check the ingress resource for the external load balancer URL:


<img width="1832" height="811" alt="Screenshot_8" src="https://github.com/user-attachments/assets/2b453dd2-3ecd-476e-a520-d18c04344d15" />


<img width="1489" height="926" alt="Screenshot_9" src="https://github.com/user-attachments/assets/6db10fbc-ed76-4718-8a07-d3281c9dafb0" />

```bash
kubectl get ingress -n game-2048
```
