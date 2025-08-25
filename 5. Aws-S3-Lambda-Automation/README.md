# AWS S3 Lambda File Transfer Automation

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?style=flat&logo=terraform)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=flat&logo=amazonaws)](https://aws.amazon.com)
[![Python](https://img.shields.io/badge/Python-3.9-3776AB?style=flat&logo=python)](https://python.org)

A serverless automation solution that automatically transfers files from a public S3 bucket to a private S3 bucket using AWS Lambda, with complete audit logging in DynamoDB.

## 🚀 Overview

This project demonstrates a real-world DevOps use case for automated file processing and transfer between S3 buckets. When files are uploaded to a public S3 bucket, a Lambda function is automatically triggered to:

- Copy the file to a secure private bucket
- Log the operation details in DynamoDB
- Provide complete audit trail for compliance

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Public S3     │    │   AWS Lambda     │    │   Private S3    │
│     Bucket      │───▶│   Copy Function  │───▶│     Bucket      │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │    DynamoDB      │
                       │   Audit Logs     │
                       │                  │
                       └──────────────────┘
```

## 📋 Components

### Infrastructure Resources

- **Public S3 Bucket** (`devops-public-31470`) - Accepts file uploads with public read access
- **Private S3 Bucket** (`devops-private-24203`) - Secure storage with no public access
- **Lambda Function** (`devops-copyfunction`) - Handles automated file transfer
- **DynamoDB Table** (`xfusion-S3CopyLogs`) - Stores operation audit logs
- **IAM Role & Policies** - Secure permissions for Lambda execution

### Key Features

- ✅ **Event-Driven**: Automatic triggering on file upload
- ✅ **Security**: Private bucket with blocked public access
- ✅ **Audit Trail**: Complete logging of all operations
- ✅ **Error Handling**: Robust error management and logging
- ✅ **Cost Optimized**: Pay-per-request DynamoDB and serverless Lambda
- ✅ **Infrastructure as Code**: Full Terraform automation

## 🛠️ Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- Python 3.9+ for Lambda function development
- `sample.zip` file for testing (or any test file)

## 📁 Project Structure

```
├── main.tf                 # Terraform infrastructure configuration
├── lambda-function.py      # Lambda function source code
├── lambda-function.zip     # Packaged Lambda deployment (auto-generated)
├── sample.zip             # Test file for upload
└── README.md             # This documentation
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Ab-Cloud-dev/AWS-Projects.git
cd 5. Aws-S3-Lambda-Automation
```

### 2. Prepare Lambda Function

Ensure your `lambda-function.py` is ready. Make sure to provide in the script

- Private S3 Bucket name
- Dynamodb Name 

This script should handle:
- S3 event processing
- File copying between buckets
- DynamoDB logging

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

```


<img width="2000" height="1039" alt="image" src="https://github.com/user-attachments/assets/7a709724-f4e8-4196-8cab-e264270665aa" />



```

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

<img width="1872" height="1125" alt="image" src="https://github.com/user-attachments/assets/c1b2f238-5e91-497e-abdb-c40716040aac" />





### 4. Test the System

```bash
# Upload test file to public bucket
aws s3 cp sample.zip s3://devops-public-31470/

# Verify file copied to private bucket
aws s3 ls s3://devops-private-24203/

# Check DynamoDB logs
aws dynamodb scan --table-name xfusion-S3CopyLogs
```

<img width="1656" height="1125" alt="image" src="https://github.com/user-attachments/assets/0de20b69-0320-4652-8e35-95a0a60d0d50" />



<img width="1523" height="721" alt="image" src="https://github.com/user-attachments/assets/6cd966d0-de66-455b-8df7-634325dc12bc" />


<img width="2000" height="839" alt="image" src="https://github.com/user-attachments/assets/c273a4a6-dd58-4314-96c0-5e249abc3cb2" />





## 📊 Monitoring & Logging

### CloudWatch Logs
Lambda execution logs are available in:
```
/aws/lambda/devops-copyfunction
```

### DynamoDB Audit Table
Each file operation creates a log entry with:
- `LogID` - Unique identifier
- `SourceBucket` - Origin bucket name
- `DestinationBucket` - Target bucket name
- `ObjectKey` - File name/path
- `Timestamp` - Operation timestamp
- `Status` - SUCCESS/ERROR
- `ErrorMessage` - Error details (if applicable)

### Example Log Entry
```json
{
  "LogID": "550e8400-e29b-41d4-a716-446655440000",
  "SourceBucket": "devops-public-31470",
  "DestinationBucket": "devops-private-24203",
  "ObjectKey": "sample.zip",
  "Timestamp": "2024-08-25T10:30:15.123Z",
  "Status": "SUCCESS"
}
```

## 🔧 Configuration

### Environment Variables
The Lambda function uses these environment variables (automatically set by Terraform):
- `DYNAMODB_TABLE` - DynamoDB table name
- `PRIVATE_BUCKET` - Target bucket for file copies

- 

### Customization Options

**Adjust Lambda timeout:**
```hcl
resource "aws_lambda_function" "devops_copy_function" {
  timeout = 300  # 5 minutes for large files
  # ...
}
```

**Change log retention:**
```hcl
resource "aws_cloudwatch_log_group" "lambda_logs" {
  retention_in_days = 30  # Keep logs for 30 days
}
```

**Modify DynamoDB billing:**
```hcl
resource "aws_dynamodb_table" "devops_s3_copy_logs" {
  billing_mode = "PROVISIONED"
  read_capacity = 5
  write_capacity = 5
}
```

## 🔐 Security Features

- **IAM Least Privilege**: Lambda role has minimal required permissions
- **Private Bucket**: Complete public access blocking on destination bucket
- **Encryption**: CloudWatch logs can be encrypted with KMS
- **VPC Support**: Lambda can be deployed in private VPC if needed

## 💰 Cost Optimization

- **Serverless Architecture**: Pay only for actual usage
- **DynamoDB On-Demand**: No idle capacity charges
- **Log Retention**: Automatic cleanup prevents storage cost accumulation
- **S3 Lifecycle**: Can add lifecycle policies for cost optimization

## 🔍 Troubleshooting

### Common Issues

**Lambda function not triggering:**
- Check S3 bucket notification configuration
- Verify Lambda permissions for S3 invocation
- Review CloudWatch logs for errors

**Permission denied errors:**
- Ensure IAM role has correct policies
- Check S3 bucket policies
- Verify DynamoDB table permissions

**File not copying:**
- Check source and destination bucket names
- Verify Lambda function environment variables
- Review object key handling in code

### Debug Commands

```bash
# Check Lambda function logs
aws logs describe-log-streams --log-group-name /aws/lambda/devops-copyfunction

# Verify S3 bucket contents
aws s3 ls s3://devops-public-31470/ --recursive
aws s3 ls s3://devops-private-24203/ --recursive

# Check DynamoDB table items
aws dynamodb scan --table-name xfusion-S3CopyLogs --max-items 10
```

## 🧹 Cleanup

To avoid ongoing AWS charges, destroy the infrastructure when done:

```bash
terraform destroy
```

**Note**: This will delete all resources including stored files and logs.

## 🤝 Use Cases

This automation pattern is ideal for:

- **Data Archival**: Moving files from public staging to secure storage
- **Content Processing**: Triggering workflows on file uploads
- **Compliance Logging**: Maintaining audit trails for file operations
- **Multi-Environment Sync**: Copying files between development/production
- **Security Workflows**: Moving sensitive files to encrypted storage

## 📈 Scaling Considerations

For production deployments, consider:

- **Dead Letter Queues**: Handle failed Lambda executions
- **Batch Processing**: Process multiple files efficiently
- **Cross-Region Replication**: Geographic redundancy
- **Monitoring Alerts**: CloudWatch alarms for failures
- **Performance**: Lambda memory and timeout optimization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)

## 🙏 Acknowledgments

- AWS Documentation and Best Practices
- Terraform AWS Provider Documentation
- Community contributions and feedback

---

⭐ **Star this repo if you find it helpful!** ⭐
