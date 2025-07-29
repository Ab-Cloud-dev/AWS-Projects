# 🌐 Online Portfolio: Cloud Architecture & DevSecOps Project Samples

Welcome to this curated collection of real-world cloud infrastructure projects demonstrating my expertise in **AWS architecture**, **DevSecOps**, **FinOps**, and **multi-account governance**. This portfolio showcases production-grade solutions with reusable Infrastructure as Code (IaC), secure CI/CD pipelines, and automation patterns.

---

## 🧭 Summary

Experienced Cloud Architect with a focus on delivering scalable, secure, and cost-efficient cloud solutions using AWS, Terraform, GitHub Actions, and FinOps tooling. Specialized in building cloud-native platforms with enterprise-grade governance, security posture management, and end-to-end automation.

---

## ⚙️ Core Technologies & Skills

- **Cloud Platforms:** AWS (Organizations, Control Tower, SCPs, ECS, Lambda), Azure, GCP  
- **Security & Governance:** IAM, WAF, Security Hub, GuardDuty, AWS Config, WIZ, Prisma Cloud, Cloud Custodian  
- **DevOps & IaC:** Terraform, CloudFormation, GitHub Actions, Jenkins, Ansible, Scalr  
- **DevSecOps:** Snyk (SCA & IaC), OWASP ZAP (DAST), SonarQube  
- **FinOps & Observability:** Apptio Cloudability, Harness, AWS Billing, QuickSight, Power BI, X-Ray  

---

## 🚀 Project Highlights

> 📌 For complete code, see individual folders inside this repo.

---

### ✅ 1. S3-Static WebHosting

**Use Cases:**  

-Product landing pages
Host marketing or informational pages for startups or applications.

-Company or team documentation
Share internal or public-facing documentation with versioning support.

-Event or campaign pages
Quickly launch and take down simple static pages for specific campaigns.

-Learning AWS
A beginner-friendly way to understand AWS S3, IAM permissions, bucket policies, and static web hosting concepts.



---

### ✅ 2. Deploying the 2048 game with EKS Fargate



**Tools Used:**  

 - EKS Cluster: Managed Kubernetes control plane in AWS
   
 - Fargate: Serverless container hosting for application pods
   
 - 2048 Game Application: Web-based game running in pods
   
 - AWS Load Balancer Controller: Manages AWS load balancers for ingress traffic
   
 - IAM Integration: Secure authentication between Kubernetes and AWS services

**Key Sections:**

 - Prerequisites Setup: Installing AWS CLI, kubectl, and configuring credentials
   
 - EKS Cluster Creation: Setting up the managed Kubernetes cluster with Fargate

 - Application Deployment: Deploying the 2048 game with proper Fargate profiles

 - AWS Load Balancer Controller: Setting up ingress management with proper IAM roles

 - Security Integration: OIDC provider and service account configuration

**Security Features**

 - OIDC Integration: Enables secure IAM role assumption without long-term credentials
 
 - Least Privilege: IAM policy grants only necessary permissions
 
 - Service Account Binding: Links Kubernetes service accounts to AWS IAM roles
 
 - Namespace Isolation: Application runs in dedicated namespace
   

   The documentation explains not just what each command does, but why it's necessary in the overall architecture. This should help anyone understand and replicate your EKS deployment process.

### ✅ 3.  VProfile Application Migration to AWS: Lift-and-Shift Strategy

This project demonstrates the migration of the VProfile application from an on-premises data center to AWS cloud infrastructure using a lift-and-shift (rehosting) strategy. The migration maintains the existing application architecture while leveraging AWS managed services for improved scalability and reliability.
   
### AWS Services Utilized

| Service | Purpose | Implementation |
|---------|---------|----------------|
| **Terraform** | Infrastructure as Code | Provisions EC2 instances, VPC, Security Groups, NAT Gateway, Internet Gateway, Subnets, and Routing |
| **EC2 Instances** | Compute Resources | Hosts application services (Tomcat, RabbitMQ, Memcached, MySQL) |
| **Application Load Balancer (ALB)** | Traffic Distribution | Manages and distributes incoming traffic across application instances |
| **Amazon S3** | Object Storage | Provides scalable storage solutions |
| **Route 53** | DNS Management | Handles domain name resolution and private hosted zones |

---

## 🛠️ How to Use This Portfolio

1. Browse each project folder
2. Read the individual `README.md` or comments inside code
3. Fork, reuse, and extend into your own cloud projects
4. Contributions welcome (with attribution)

---

> ✨ This repository is built to help hiring teams, tech evaluators, and cloud builders assess production-ready thinking in real-world cloud engineering scenarios.
