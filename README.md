AWS EC2 Scheduler with Lambda & EventBridge (Terraform)
======================================================

This project automates the start and stop of an AWS EC2 instance at specific times using AWS Lambda, EventBridge (CloudWatch Events), and Terraform.

------------------------------------------------------
FEATURES
------------------------------------------------------
- Automatically starts EC2 at 7:00 PM IST.
- Automatically stops EC2 at 7:30 PM IST.
- Uses a single Lambda function for both actions (start/stop).
- Infrastructure fully managed with Terraform.
- Cost-effective (Lambda & EventBridge are free for this use case).

------------------------------------------------------
PROJECT STRUCTURE
------------------------------------------------------
.
├── main.tf                # Terraform script for Lambda, IAM, EventBridge
├── lambda_function.py     # Lambda function to start/stop EC2
├── lambda.zip             # Zipped Lambda code (auto-created before terraform apply)
└── README.txt             # Project documentation

------------------------------------------------------
PREREQUISITES
------------------------------------------------------
- AWS CLI configured with valid credentials.
- Terraform installed.
- Python 3.x for packaging the Lambda code.
- An existing EC2 instance (replace INSTANCE_ID in lambda_function.py).

------------------------------------------------------
SETUP INSTRUCTIONS
------------------------------------------------------
1. Clone the repository:
   git clone https://github.com/<your-username>/ec2-scheduler.git
   cd ec2-scheduler

2. Update lambda_function.py:
   - Replace INSTANCE_ID and REGION with your EC2 details.

3. Package the Lambda code:
   zip lambda.zip lambda_function.py

4. Initialize Terraform:
   terraform init

5. Apply infrastructure:
   terraform apply
   (Type 'yes' when prompted.)

This will:
- Create IAM role for Lambda.
- Deploy the Lambda function.
- Create EventBridge rules for 7:00 PM (start) and 7:30 PM (stop).

------------------------------------------------------
TESTING
------------------------------------------------------
Manually invoke the Lambda from AWS Console:
   { "action": "start" }   # Start EC2
   { "action": "stop" }    # Stop EC2

------------------------------------------------------
TEARDOWN
------------------------------------------------------
To remove all resources:
   terraform destroy

------------------------------------------------------
FUTURE ENHANCEMENTS
------------------------------------------------------
- Add multiple EC2 instances via variable list.
- Make start/stop times configurable via variables.
- Add Slack/Email notification on instance actions.

------------------------------------------------------
AUTHOR
------------------------------------------------------
Angad BAndal

