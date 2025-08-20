import boto3
import json
import datetime

def lambda_handler(event, context):
    # Only process US East regions
    regions = ['us-east-1', 'us-east-2']

    snapshots_created = []
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

    for region in regions:
        ec2 = boto3.client('ec2', region_name=region)
        try:
            volumes = ec2.describe_volumes(Filters=[{'Name': 'status', 'Values': ['in-use']}])['Volumes']
            for volume in volumes:
                volume_id = volume['VolumeId']
                snapshot = ec2.create_snapshot(
                    VolumeId=volume_id,
                    Description=f"Snapshot of {volume_id} - {timestamp}"
                )
                snapshots_created.append({
                    "Region": region,
                    "VolumeId": volume_id,
                    "SnapshotId": snapshot['SnapshotId']
                })
        except Exception as e:
            print(f"Error in region {region}: {str(e)}")

    # SNS notification with readable format
    sns = boto3.client('sns')

    # Create readable email message
    total_snapshots = len(snapshots_created)
    subject = f"EBS Snapshot Report - {total_snapshots} snapshots created"

    # Build readable message
    message = f"""
EBS SNAPSHOT CREATION REPORT
============================
Date: {timestamp}
Regions Processed: us-east-1, us-east-2
Total Snapshots Created: {total_snapshots}

SNAPSHOT DETAILS:
"""

    if snapshots_created:
        # Group by region for better readability
        us_east_1_snapshots = [s for s in snapshots_created if s['Region'] == 'us-east-1']
        us_east_2_snapshots = [s for s in snapshots_created if s['Region'] == 'us-east-2']

        if us_east_1_snapshots:
            message += f"\n📍 US-EAST-1 ({len(us_east_1_snapshots)} snapshots):\n"
            message += "-" * 50 + "\n"
            for snapshot in us_east_1_snapshots:
                message += f"  • Volume: {snapshot['VolumeId']}\n"
                message += f"    Snapshot: {snapshot['SnapshotId']}\n\n"

        if us_east_2_snapshots:
            message += f"\n📍 US-EAST-2 ({len(us_east_2_snapshots)} snapshots):\n"
            message += "-" * 50 + "\n"
            for snapshot in us_east_2_snapshots:
                message += f"  • Volume: {snapshot['VolumeId']}\n"
                message += f"    Snapshot: {snapshot['SnapshotId']}\n\n"
    else:
        message += "\nNo snapshots were created (no in-use volumes found).\n"

    message += f"""
SUMMARY:
========
✅ Total Snapshots: {total_snapshots}
🗂️  Regions Checked: 2 (us-east-1, us-east-2)
📅 Created: {timestamp}

This is an automated report from AWS Lambda EBS Snapshot function.
"""

    sns.publish(
        TopicArn="arn:aws:sns:REGION:ACCOUNT_ID:TOPIC_NAME",  # Replace with your actual SNS topic ARN
        Subject=subject,
        Message=message
    )

    return {
        'statusCode': 200,
        'body': json.dumps(snapshots_created)
    }