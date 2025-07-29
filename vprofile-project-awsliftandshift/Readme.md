# VProfile Application Migration to AWS: Lift-and-Shift Strategy

## Executive Summary

This project demonstrates the migration of the VProfile application from an on-premises data center to AWS cloud infrastructure using a lift-and-shift (rehosting) strategy. The migration maintains the existing application architecture while leveraging AWS managed services for improved scalability and reliability.

## Project Objectives

- **Primary Goal**: Migrate traditional web application stack from local data center to AWS cloud
- **Strategy**: Lift-and-shift approach with minimal code changes
- **Outcome**: Cloud-based infrastructure with enhanced availability and management capabilities

## Architecture Overview

### AWS Services Utilized

| Service | Purpose | Implementation |
|---------|---------|----------------|
| **Terraform** | Infrastructure as Code | Provisions EC2 instances, VPC, Security Groups, NAT Gateway, Internet Gateway, Subnets, and Routing |
| **EC2 Instances** | Compute Resources | Hosts application services (Tomcat, RabbitMQ, Memcached, MySQL) |
| **Application Load Balancer (ALB)** | Traffic Distribution | Manages and distributes incoming traffic across application instances |
| **Amazon S3** | Object Storage | Provides scalable storage solutions |
| **Route 53** | DNS Management | Handles domain name resolution and private hosted zones |

## Lift-and-Shift Migration Strategy

### Definition
**Lift-and-shift** (rehosting) involves moving applications from one environment to another without modifying the application code or architecture. The process "lifts" existing virtual machines, operating systems, configurations, and data, then "shifts" them to equivalent cloud infrastructure.

### Advantages ✅
- **Rapid Migration**: Minimal disruption with fast deployment timeline
- **Cost-Effective**: Lower upfront investment due to reduced development effort
- **Business Continuity**: Preserves existing business logic and operational workflows
- **Risk Mitigation**: Maintains proven application functionality

### Considerations ⚠️
- **Limited Optimization**: Doesn't leverage cloud-native features (auto-scaling, serverless)
- **Legacy Constraints**: May inherit existing performance bottlenecks and security vulnerabilities
- **Operational Costs**: Potential for higher ongoing costs without cloud-specific optimizations
- **Modernization Path**: Often serves as the first phase in a broader cloud modernization strategy

## Application Request Flow

### 1. Client Request Initiation
- User browser sends HTTP/HTTPS request to **Application Load Balancer (ALB)**
- ALB performs SSL termination for HTTPS traffic
- Routing decisions made based on listener rules (path-based, host-based routing)

### 2. Load Balancer Processing
- ALB forwards requests to healthy Tomcat instances in Auto Scaling Group
- Traffic distributed across multiple availability zones for high availability
- Health checks ensure only operational instances receive traffic

### 3. Application Server Processing
- **Tomcat servers** (port 8080) execute Java web application logic
- **Remote IP Valve** configured to preserve original client IP through X-Forwarded-For headers
- Application processes business logic and determines data requirements

### 4. Data Layer Interactions

#### Caching Strategy
- **Cache Check**: Application queries **Memcached** for requested data
  - **Cache Hit**: Data returned immediately, reducing database load
  - **Cache Miss**: Triggers database query and cache population

#### Database Operations
- **MariaDB (MySQL)** handles persistent data storage
- Stores user profiles, application state, transaction records
- Data retrieved on cache misses and subsequently cached for future requests

#### Message Queue Processing
- **RabbitMQ** manages asynchronous tasks and background processing
- Handles email notifications, order processing, and other decoupled operations
- Enables horizontal scaling of background workers independent of web traffic

### 5. Response Generation
- Tomcat compiles response using cached and/or database data
- ALB receives processed response and forwards to client browser
- End-to-end request processing maintains original protocol (HTTP/HTTPS)

## Implementation Process

### Phase 1: Infrastructure Setup
1. **AWS CLI and Terraform Installation**
   - Configure local development environment
   - Set up AWS credentials and regional preferences

2. **Infrastructure Provisioning**
   ```bash
 
   ```

### Phase 2: Service Deployment




1. **Application Services Configuration**
   - Execute userdata scripts for service-specific installations:
     - Tomcat application server setup
     - MariaDB database configuration
     - RabbitMQ message broker installation

2. **DNS Configuration**
   - Update FQDN names in `src/main/resources/application.properties`
   - Configure Route 53 private hosted zone entries
   - Ensure proper service discovery and communication

### Phase 3: Validation and Testing

#### Connectivity Verification
- **Load Balancer Health Check**: Confirm ALB URL accessibility
- **Application Login**: Validate authentication with admin_vp credentials
- **Functional Testing**: Verify core application features and data flow

#### Performance Validation
- Monitor response times and throughput
- Validate caching effectiveness
- Confirm database connectivity and query performance

## Security Considerations

- **Network Security**: VPC with private subnets for database and cache layers
- **Access Control**: Security groups configured for least-privilege access
- **SSL/TLS**: ALB handles SSL termination for encrypted client communications
- **Database Security**: MariaDB isolated in private subnet with controlled access

## Monitoring and Maintenance

### Key Metrics to Monitor
- **Application Performance**: Response times, error rates, throughput
- **Infrastructure Health**: EC2 instance status, Auto Scaling Group metrics
- **Database Performance**: Connection counts, query performance, storage utilization
- **Cache Effectiveness**: Hit/miss ratios, memory utilization

### Operational Best Practices
- Regular security patching and updates
- Database backup and recovery procedures
- Auto Scaling Group configuration optimization
- Cost monitoring and optimization

## Future Considerations

This lift-and-shift migration establishes the foundation for further cloud optimization initiatives:

1. **Containerization**: Migrate to ECS or EKS for improved resource utilization
2. **Database Modernization**: Consider RDS for managed database services
3. **Serverless Components**: Implement AWS Lambda for background processing
4. **Monitoring Enhancement**: Deploy CloudWatch and X-Ray for comprehensive observability
5. **Security Hardening**: Implement AWS WAF and enhanced security monitoring

## Conclusion

The VProfile application has been successfully migrated to AWS using a lift-and-shift strategy, providing immediate cloud benefits while maintaining application stability. This migration serves as a stepping stone for future cloud-native optimizations and demonstrates the viability of rapid cloud adoption with minimal business disruption.