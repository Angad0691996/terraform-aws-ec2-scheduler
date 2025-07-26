import boto3

INSTANCE_ID = "i-01eede97e50884138"  # <-- Replace with your EC2 ID
REGION = "ap-south-1"

def lambda_handler(event, context):
    action = event.get("action", "start")
    ec2 = boto3.client("ec2", region_name=REGION)

    if action == "start":
        ec2.start_instances(InstanceIds=[INSTANCE_ID])
        return f"EC2 instance {INSTANCE_ID} started."
    elif action == "stop":
        ec2.stop_instances(InstanceIds=[INSTANCE_ID])
        return f"EC2 instance {INSTANCE_ID} stopped."
    else:
        return f"Unknown action: {action}"
