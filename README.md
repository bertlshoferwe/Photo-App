# Photo App - Google Photos-like App with AWS, Terraform, Jenkins

## Overview
This project is a simple **Google Photos-like app** that allows users to upload, manage, and back up photos using AWS services. The infrastructure is set up using **Terraform** to manage AWS resources, and **Jenkins** is used for continuous integration and deployment (CI/CD). The app includes features such as:

- Frontend built with **React** (deployed on **S3**).
- Backend with **Lambda functions**.
- Image storage using **S3** with lifecycle management policies.
- **DynamoDB** for storing photo metadata.
- **AWS Rekognition** for automatic image tagging.
- **Auto-backup** to ensure data is always available, with **cross-region replication** for disaster recovery.

## Prerequisites

### 1. **AWS Setup**
Make sure you have an **AWS account** and the necessary credentials. You will need **AWS Access Key** and **Secret Key** to deploy infrastructure using Terraform and Jenkins.

### 2. **Tools**
- **Terraform**: To deploy AWS infrastructure.
- **Jenkins**: To automate the CI/CD pipeline.
- **AWS CLI**: For interacting with AWS services from your terminal.

### 3. **Install Jenkins Plugins**
Ensure the following Jenkins plugins are installed:
- **Git Plugin**: For GitHub integration.
- **Terraform Plugin**: To run Terraform commands from Jenkins.
- **Pipeline Plugin**: For Jenkins Pipeline (Declarative or Scripted).
- **AWS Credentials Plugin**: For AWS authentication.

---

## Setting Up the Project

### 1. **Clone the Repository**
```bash
git clone https://github.com/your-username/photo-app.git
cd photo-app
2. Configure AWS Credentials
In Jenkins:

Go to Manage Jenkins → Manage Credentials → (Global) → Add Credentials.
Choose AWS Credentials and enter your Access Key and Secret Key.
Use these credentials in your pipeline for AWS authentication.
Infrastructure Deployment with Terraform
1. Initialize Terraform

terraform init
2. Review Terraform Plan
Before applying, review the changes that Terraform will make:


terraform plan
3. Apply Terraform Configuration
Deploy the infrastructure (S3, Lambda, DynamoDB, Rekognition, etc.):


terraform apply -auto-approve
Jenkins CI/CD Pipeline
1. Set Up the Jenkins Pipeline
Go to Jenkins Dashboard.
Click New Item, select Pipeline, and give it a name, e.g., photo-app-pipeline.
In the Pipeline Script section, define the pipeline script. You can either copy it into the Jenkinsfile in the root of your repository or configure it directly in Jenkins.
2. Pipeline Script

pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'  // Modify to your region
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')  // Add credentials in Jenkins
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')  // Add credentials in Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Frontend Deployment') {
            steps {
                script {
                    sh 'cd frontend && npm install && npm run build'
                    sh 'aws s3 sync frontend/build/ s3://your-photo-app-bucket --delete'
                }
            }
        }

        stage('Backend Deployment') {
            steps {
                script {
                    sh 'cd backend && npm install'
                    sh 'zip -r function.zip .'
                    sh 'aws lambda update-function-code --function-name photo-app-lambda --zip-file fileb://function.zip'
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
3. Trigger the Pipeline
Trigger the pipeline manually by clicking Build Now in Jenkins.
Set up GitHub Webhooks to trigger the Jenkins job when code is pushed to the repository.
App Features
1. Frontend
The frontend is built with React and deployed to AWS S3. It allows users to upload, view, and manage their photos.

S3 Bucket: Stores uploaded images.
DynamoDB: Stores metadata for each image (e.g., tags, upload time).
Rekognition: Automatically tags images with labels.
2. Backend (Lambda)
The backend uses AWS Lambda to handle requests, such as image tagging and processing. The Lambda function is automatically updated during the Jenkins pipeline deployment.

AWS Lambda: Functions for processing photos, triggering backup events, etc.
CloudWatch Logs: Used to log the Lambda function execution details.
3. Backup & Disaster Recovery
The app has an automated backup system:

S3 Cross-Region Replication: Ensures photos are replicated across regions for disaster recovery.
Lifecycle Policies: Transition old photos to Glacier storage for cost optimization.
Monitoring and Notifications
1. AWS CloudWatch
CloudWatch is used for monitoring Lambda function performance, S3 usage, and other AWS resource metrics.

Security Considerations
IAM Roles and Policies: Ensure that only necessary permissions are granted to the AWS resources.
S3 Bucket Permissions: Make sure your S3 buckets are not publicly accessible.
Lambda Permissions: Lambda functions should have restricted access to the necessary resources (S3, DynamoDB, etc.).
