# 🌐 Cloud Architecture & DevOps Engineering Portfolio

Welcome to my curated collection of production-grade cloud infrastructure projects. This portfolio demonstrates hands-on expertise in **AWS architecture**, **Kubernetes orchestration**, **DevSecOps automation**, **Infrastructure as Code**, and **serverless computing**. Each project represents real-world scenarios with enterprise-ready solutions, comprehensive documentation, and reusable code.

---

## 🧭 About This Portfolio

Cloud Engineer with deep expertise in designing, deploying, and automating cloud-native solutions on AWS. Specialized in building scalable infrastructure, implementing CI/CD pipelines, orchestrating containerized applications, and establishing security-first architectures. This portfolio showcases practical implementations that bridge the gap between theoretical cloud knowledge and production-ready systems.

**What You'll Find Here:**
- ✅ Complete Infrastructure as Code (Terraform, CloudFormation)
- ✅ Container orchestration with Kubernetes and Docker
- ✅ Serverless automation patterns with Lambda
- ✅ CI/CD pipeline implementations
- ✅ Multi-tier application architectures
- ✅ Security and compliance best practices
- ✅ Cost optimization strategies

---

## ⚙️ Technical Stack

### Cloud & Infrastructure
- **AWS Services:** EKS, ECS, Fargate, Lambda, EC2, S3, RDS, DynamoDB, CloudFront
- **Container & Orchestration:** Kubernetes, Docker, Amazon ECS, AWS Fargate
- **Infrastructure as Code:** Terraform, CloudFormation, eksctl
- **Networking:** VPC, ALB/NLB, Route 53, API Gateway, CloudFront CDN

### DevOps & CI/CD
- **CI/CD Tools:** AWS CodePipeline, CodeBuild, GitHub Actions, Jenkins
- **Configuration Management:** Ansible, Helm Charts
- **Version Control:** Git, GitHub

### Security & Governance
- **Identity & Access:** IAM, OIDC, Service Accounts, Security Groups
- **Monitoring:** CloudWatch, CloudWatch Logs, X-Ray
- **Security Scanning:** AWS Config, GuardDuty, Security Hub

### Development & Scripting
- **Languages:** Python, Bash, YAML, JSON
- **Package Managers:** pip, npm, Helm

---

## 🚀 Featured Projects

> 📌 **Navigation:** Each project includes detailed README with step-by-step implementation guides, architecture diagrams, and troubleshooting sections.

---

## 1. 🎮 Kubernetes on AWS: EKS Fargate with 2048 Game Deployment

**📂 [View Project](./1.%20Deploying%20the%202048%20game%20with%20EKS%20Fargate/)**

### Overview
This project demonstrates production-ready Kubernetes deployment on AWS using serverless Fargate compute. Rather than managing EC2 worker nodes, this implementation leverages AWS Fargate to run containerized applications, eliminating infrastructure overhead while maintaining full Kubernetes functionality.

### What This Project Demonstrates
- **Serverless Kubernetes:** Deploy applications without managing underlying compute infrastructure
- **AWS Service Integration:** Deep integration between EKS, IAM, and AWS Load Balancer Controller
- **Security Best Practices:** OIDC authentication, service account binding, and namespace isolation
- **Production Ingress:** Automated Application Load Balancer provisioning through Kubernetes Ingress resources

### Technical Architecture
```
User Request → ALB (managed by AWS LB Controller) 
           → Ingress Resource 
           → Service 
           → Pods (running on Fargate)
```

### Key Technologies
- **Amazon EKS** - Managed Kubernetes control plane
- **AWS Fargate** - Serverless compute for containers
- **AWS Load Balancer Controller** - Kubernetes-native ALB/NLB management
- **eksctl** - Simplified EKS cluster creation
- **Helm** - Kubernetes package management

### Implementation Highlights
- ✅ Fargate profile configuration for specific namespaces
- ✅ OIDC provider setup for IAM role assumption
- ✅ IAM service accounts for secure AWS API access
- ✅ Automated load balancer provisioning via Ingress
- ✅ kubectl configuration and cluster access management

### Business Value
Eliminates the operational burden of managing Kubernetes worker nodes while providing enterprise-grade container orchestration. Ideal for teams wanting Kubernetes benefits without infrastructure complexity.

**Difficulty Level:** Intermediate to Advanced

---

## 2. 🏢 VProfile Application: AWS Lift-and-Shift Migration

**📂 [View Project](./2.%20vprofile-project-awsliftandshift/)**

### Overview
A comprehensive migration project that moves a traditional multi-tier web application from on-premises infrastructure to AWS cloud using the lift-and-shift (rehosting) strategy. This approach minimizes application changes while immediately gaining cloud benefits like scalability, high availability, and managed infrastructure.

### What This Project Demonstrates
- **Cloud Migration Strategy:** Practical implementation of lift-and-shift methodology
- **Multi-Tier Architecture:** Web, application, caching, messaging, and database layers
- **Infrastructure as Code:** Complete Terraform automation for reproducible deployments
- **AWS Networking:** VPC design with public/private subnets, NAT gateways, and routing

### Application Stack
```
Users → Route 53 DNS → Application Load Balancer 
     → Tomcat (Application Server) 
     → Memcached (Cache) + RabbitMQ (Message Queue) + MySQL (Database)
```

### Key Technologies
- **Terraform** - Infrastructure provisioning and management
- **Amazon EC2** - Virtual servers for application components
- **Application Load Balancer** - Layer 7 load balancing with health checks
- **Route 53** - DNS management and private hosted zones
- **Amazon VPC** - Network isolation and security

### Infrastructure Components
| Component | Purpose | Configuration |
|-----------|---------|---------------|
| **VPC** | Network isolation | CIDR: 10.0.0.0/16 with public/private subnets |
| **EC2 Instances** | Application hosting | Tomcat, MySQL, RabbitMQ, Memcached |
| **ALB** | Traffic distribution | Health checks, SSL termination |
| **NAT Gateway** | Outbound internet access | Enables private subnet connectivity |
| **Security Groups** | Firewall rules | Least-privilege access control |

### Implementation Highlights
- ✅ Automated infrastructure provisioning with Terraform
- ✅ Userdata scripts for service configuration
- ✅ Private hosted zone for internal service discovery
- ✅ Multi-AZ deployment for high availability
- ✅ Security group segregation by service tier

### Business Value
Demonstrates cloud migration capabilities with minimal business disruption. Provides foundation for future cloud-native optimizations like containerization, auto-scaling, and managed database services.

**Migration Strategy:** Lift-and-Shift → Future: Re-architecting for cloud-native

**Difficulty Level:** Intermediate

---

## 3. 💾 EBS Snapshot Automation with AWS Lambda

**📂 [View Project](./3.%20EBS%20Snapshot%20Automation%20Using%20Lambda/)**

### Overview
A serverless disaster recovery solution that automatically creates and manages EBS volume snapshots across multiple AWS regions. This project implements event-driven backup automation with intelligent filtering, comprehensive error handling, and detailed email reporting—all without managing any servers.

### What This Project Demonstrates
- **Serverless Automation:** Event-driven architecture using Lambda and EventBridge
- **Disaster Recovery:** Automated backup strategy for EC2 volumes
- **Multi-Region Operations:** Cross-region snapshot management
- **Operational Excellence:** Automated notifications and audit trails

### Solution Architecture
```
CloudWatch Event (Scheduled) → Lambda Function
                             → EC2 API (describe/create snapshots)
                             → SNS Topic → Email Notification
                             → CloudWatch Logs
```

### Key Technologies
- **AWS Lambda** - Serverless Python 3.13 function execution
- **Amazon EventBridge** - Scheduled triggers and event rules
- **Amazon SNS** - Email notification delivery
- **Amazon CloudWatch** - Centralized logging and monitoring
- **Boto3** - AWS SDK for Python

### Automation Workflow
1. **Scheduled Trigger:** EventBridge invokes Lambda on defined schedule (daily/weekly)
2. **Volume Discovery:** Lambda scans US-East-1 and US-East-2 for in-use volumes
3. **Snapshot Creation:** Creates point-in-time backups with descriptive metadata
4. **Notification:** Sends formatted email with snapshot details grouped by region
5. **Logging:** Records all operations in CloudWatch for troubleshooting

### Implementation Highlights
- ✅ Multi-region volume scanning (us-east-1, us-east-2)
- ✅ Intelligent filtering (only snapshots attached/in-use volumes)
- ✅ Formatted email reports with regional grouping
- ✅ Comprehensive error handling with try-except blocks
- ✅ IAM least-privilege permissions
- ✅ Configurable scheduling via EventBridge

### Business Value
Provides automated backup protection for critical workloads without manual intervention. Reduces RPO (Recovery Point Objective) and ensures business continuity. Cost-effective serverless solution that scales automatically.

**Use Cases:** 
- Regular backup schedules
- Compliance requirements
- Disaster recovery preparation
- Development environment snapshots

**Difficulty Level:** Beginner to Intermediate

---

## 4. 📁 S3 File Transfer Automation with Lambda & DynamoDB Audit Trail

**📂 [View Project](./4.%20Aws-S3-Lambda-Automation/)**

### Overview
An event-driven file processing system that automatically transfers uploaded files from a public S3 bucket to a secured private bucket while maintaining complete audit logs in DynamoDB. This project showcases serverless automation, security best practices, and compliance-focused architecture—all provisioned through Infrastructure as Code.

### What This Project Demonstrates
- **Event-Driven Architecture:** Real-time S3 event processing with Lambda
- **Security Compliance:** Automated file movement from public to private storage
- **Audit Logging:** Complete operation tracking in DynamoDB
- **Infrastructure as Code:** Full Terraform automation for reproducible deployments

### Solution Architecture
```
File Upload to Public S3 → S3 Event Notification → Lambda Function
                         → Copy to Private S3
                         → Log to DynamoDB
                         → CloudWatch Logs
```

### Key Technologies
- **AWS Lambda** - Serverless file processing function
- **Amazon S3** - Source (public) and destination (private) buckets
- **Amazon DynamoDB** - Audit log storage with pay-per-request billing
- **Terraform** - Infrastructure provisioning automation
- **Python & Boto3** - Lambda function runtime and AWS SDK

### Data Flow
1. **File Upload:** User uploads file to public S3 bucket
2. **Event Trigger:** S3 triggers Lambda via event notification
3. **File Transfer:** Lambda copies file to private, secured bucket
4. **Audit Log:** Operation details written to DynamoDB table
5. **Monitoring:** All actions logged to CloudWatch for observability

### Implementation Highlights
- ✅ S3 bucket policies with public access blocks on private bucket
- ✅ Lambda IAM role with least-privilege permissions
- ✅ DynamoDB audit table with LogID, timestamps, and status
- ✅ Comprehensive error handling and retry logic
- ✅ Terraform modules for reusable infrastructure
- ✅ CloudWatch integration for debugging and monitoring

### Security Features
- **Bucket Isolation:** Separate public and private buckets
- **Access Control:** IAM policies restricting cross-bucket access
- **Audit Trail:** Every operation logged with metadata
- **Encryption:** S3 server-side encryption enabled

### Business Value
Demonstrates compliance-ready architecture for regulated industries requiring file security and audit trails. Eliminates manual file management overhead while maintaining security posture and operational visibility.

**Use Cases:**
- Document processing workflows
- Secure file archival
- Compliance logging
- Multi-environment file synchronization

**Difficulty Level:** Intermediate

---

## 5. 🌐 AWS Serverless 3-Tier Web Application

**📂 [View Project](./5.%20AWS%20Serverless%203%20tier%20Architecture/)**

### Overview
A fully serverless student management system built entirely on AWS managed services, demonstrating modern cloud-native application architecture. This project eliminates server management while providing automatic scaling, high availability, and pay-per-use pricing—showcasing the power of serverless computing for web applications.

### What This Project Demonstrates
- **Serverless Architecture:** Zero server management with fully managed AWS services
- **3-Tier Design:** Clean separation of presentation, application, and data layers
- **Global Distribution:** CloudFront CDN for worldwide low-latency access
- **RESTful API Design:** API Gateway with Lambda integration

### Solution Architecture
```
CloudFront CDN → S3 Static Website (Frontend)
User → API Gateway (REST API)
    → Lambda Functions (Business Logic)
    → DynamoDB (Data Storage)
```

### Technology Stack by Layer

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Presentation** | S3 + CloudFront | Static HTML/CSS/JS hosting with global CDN |
| **API** | API Gateway | RESTful endpoints with CORS, throttling, and caching |
| **Compute** | Lambda (Python) | Serverless business logic execution |
| **Database** | DynamoDB | NoSQL data storage with auto-scaling |

### Key Technologies
- **Amazon S3** - Static website hosting
- **Amazon CloudFront** - CDN for global content delivery
- **API Gateway** - Managed REST API with request/response transformation
- **AWS Lambda** - Serverless compute for GET/POST operations
- **Amazon DynamoDB** - Serverless NoSQL database with pay-per-request
- **AWS IAM** - Fine-grained access control and permissions

### Implementation Highlights
- ✅ S3 static website hosting with bucket policies
- ✅ CloudFront distribution with custom SSL support
- ✅ API Gateway with Lambda proxy integration
- ✅ CORS configuration for cross-origin requests
- ✅ DynamoDB with partition key design for efficient queries
- ✅ IAM roles for Lambda execution and DynamoDB access
- ✅ Query string parameters for GET operations
- ✅ Request body parsing for POST operations

### Application Features
- **Student Management:** Create and retrieve student records
- **RESTful Operations:** GET (retrieve) and POST (create) endpoints
- **Form Validation:** Client-side and server-side validation
- **Responsive Design:** Mobile-friendly web interface

### Business Value
Demonstrates ability to build production-ready web applications without managing infrastructure. Zero upfront costs with automatic scaling to handle traffic spikes. Perfect foundation for startups and MVPs requiring rapid deployment.

**Cost Optimization:**
- Pay only for actual API calls (no idle costs)
- DynamoDB on-demand billing
- CloudFront caching reduces origin requests
- Lambda millisecond-level billing

**Difficulty Level:** Intermediate

---

## 6. 🐳 Containerized Application with CI/CD on Amazon ECS

**📂 [View Project](./6.%20Containerized%20App%20Deployment%20with%20CICD%20on%20ECS/)**

### Overview
A complete end-to-end CI/CD pipeline demonstrating modern DevOps practices for containerized applications. This project automates the entire software delivery lifecycle—from code commit to production deployment—using AWS native services. Features blue-green deployments, automated testing, and infrastructure as code.

### What This Project Demonstrates
- **Continuous Integration:** Automated build and test on every commit
- **Continuous Deployment:** Automated container deployment to ECS
- **Container Orchestration:** ECS cluster management with Fargate
- **Pipeline Automation:** GitHub integration with AWS CodePipeline

### CI/CD Pipeline Flow
```
GitHub Push → CodePipeline Trigger
           → CodeBuild (Build Docker Image)
           → Push to ECR
           → Update Task Definition
           → ECS Service Update
           → ALB Health Checks
           → Traffic Switch
```

### Technology Stack
- **Amazon ECS** - Container orchestration service
- **Amazon ECR** - Private Docker registry with image scanning
- **AWS CodePipeline** - Continuous delivery orchestration
- **AWS CodeBuild** - Managed build service
- **Application Load Balancer** - Traffic distribution and health checks
- **Amazon RDS PostgreSQL** - Managed relational database
- **Docker** - Container runtime and image building
- **GitHub** - Source code repository

### Pipeline Stages

#### Stage 1: Source
- GitHub webhook triggers on code commit
- Pulls latest code from main branch
- Passes source artifact to build stage

#### Stage 2: Build
- CodeBuild compiles application
- Runs unit tests and security scans
- Builds Docker image with versioning
- Pushes image to ECR with tags
- Generates imagedefinitions.json

#### Stage 3: Deploy
- Updates ECS task definition with new image
- ECS creates new task revision
- Rolling update replaces old containers
- ALB performs health checks
- Routes traffic to healthy tasks

### Implementation Highlights
- ✅ Automated Docker image building with buildspec.yml
- ✅ ECR image scanning on push for vulnerabilities
- ✅ ECS task definitions with environment variables
- ✅ IAM roles for CodeBuild with ECS permissions
- ✅ Application Load Balancer with target groups
- ✅ RDS PostgreSQL integration for data persistence
- ✅ Rolling updates with zero-downtime deployments
- ✅ CloudWatch container logs and metrics

### Security Considerations
- **Image Scanning:** ECR scans for CVEs on every push
- **IAM PassRole:** Secure role assumption for ECS tasks
- **Secrets Management:** Environment variables from Secrets Manager
- **Network Isolation:** ECS tasks in private subnets
- **Security Groups:** Restricted ingress/egress rules

### Business Value
Demonstrates modern DevOps maturity with automated testing, building, and deployment. Reduces deployment time from hours to minutes while improving reliability and consistency. Enables rapid iteration and feature delivery.

**Key Metrics:**
- Deployment frequency: Multiple times per day
- Lead time: Minutes from commit to production
- MTTR: Rapid rollback capabilities
- Change failure rate: Reduced through automation

**Difficulty Level:** Advanced

---

## 🎯 Learning Outcomes

By exploring these projects, you'll gain practical knowledge in:

### Cloud Architecture
- Designing multi-tier applications on AWS
- Implementing serverless and container-based solutions
- Network architecture with VPCs, subnets, and load balancers
- Multi-region deployment strategies

### Infrastructure as Code
- Terraform for AWS resource provisioning
- CloudFormation stack management
- Version-controlled infrastructure
- Modular and reusable IaC patterns

### Container & Kubernetes
- Docker containerization best practices
- Kubernetes deployment and service management
- ECS vs EKS use cases
- Fargate serverless containers

### CI/CD & Automation
- Pipeline design and implementation
- Automated testing and deployment
- Blue-green deployment strategies
- GitOps workflows

### Security & Compliance
- IAM roles and policies (least privilege)
- Security group and NACL configuration
- Audit logging and compliance tracking
- Secrets management

---

## 🛠️ How to Use This Portfolio

### For Recruiters & Hiring Managers
1. **Browse Project Summaries** - Quick understanding of scope and complexity
2. **Review Architecture Diagrams** - Visual representation of technical decisions
3. **Assess Code Quality** - Well-documented, production-ready implementations
4. **Evaluate Problem-Solving** - Each project includes troubleshooting sections

### For Engineers & Learners
1. **Clone the Repository** - All code is ready to deploy
2. **Follow Step-by-Step Guides** - Detailed README in each project folder
3. **Customize for Your Needs** - Modular code designed for reusability
4. **Learn by Doing** - Deploy in your AWS account (watch for costs!)

### For Potential Collaborators
1. **Fork the Projects** - Extend functionality or add new features
2. **Submit Pull Requests** - Contributions welcome with attribution
3. **Report Issues** - Help improve documentation and code
4. **Share Feedback** - Suggestions for improvements

---



*Cost Legend: $ = <$5/day, $$ = $5-20/day, $$$ = >$20/day (approximate)

---

## 📚 Additional Resources

### Documentation
- Each project folder contains detailed README with:
  - Architecture diagrams
  - Step-by-step deployment instructions
  - Configuration files and code samples
  - Troubleshooting guides
  - Cost optimization tips

### Prerequisites
- AWS Account with appropriate IAM permissions
- AWS CLI installed and configured
- Basic understanding of cloud concepts
- Familiarity with command-line tools

### Recommended Learning Path
1. Start with **EBS Snapshot Automation** (simplest serverless project)
2. Progress to **S3 Lambda Automation** (event-driven architecture)
3. Build **Serverless 3-Tier App** (full application stack)
4. Deploy **VProfile Migration** (infrastructure complexity)
5. Implement **ECS CI/CD Pipeline** (DevOps automation)
6. Master **EKS Fargate Deployment** (Kubernetes orchestration)

---

## 💡 About the Author

Cloud Engineer passionate about building scalable, secure, and cost-effective solutions on AWS. This portfolio represents hands-on learning through real-world implementations, not just theoretical knowledge. Every project has been deployed, tested, and documented to help others learn cloud engineering.

**Skills Demonstrated:**
- ☁️ AWS Solution Architecture
- 🐳 Container Orchestration (Kubernetes, ECS)
- 🔄 CI/CD Pipeline Design
- 🏗️ Infrastructure as Code (Terraform)
- 🔒 Security & Compliance
- 📊 Cost Optimization
- 📝 Technical Documentation

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to:
- Open issues for bugs or improvements
- Submit pull requests with enhancements
- Share your implementations and learnings
- Suggest new project ideas

Please ensure any code contributions follow AWS best practices and include appropriate documentation.

---

## 📄 License

This project is open source and available for educational purposes. When reusing code:
- Provide attribution to the original author
- Maintain existing license notices
- Do not use for commercial purposes without permission

---

## 🔗 Connect & Learn More

- 📧 **Email:** mohammed.abdullah700@gmail.com
- 💼 **LinkedIn:** [Connect with me](https://www.linkedin.com/in/your-profile)
- 🌐 **GitHub:** [@Ab-Cloud-dev](https://github.com/Ab-Cloud-dev)

---

> ⭐ **If you found this portfolio helpful, please consider giving it a star!** Your feedback helps improve the content and motivates further contributions to the cloud community.

---

**Last Updated:** October 2025  
**Portfolio Version:** 2.0  
**AWS Region:** Primarily us-east-1, us-east-2

---

<div align="center">

### ✨ Built with passion for cloud engineering and continuous learning ✨

</div>
