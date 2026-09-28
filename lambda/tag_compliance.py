import boto3

ec2 = boto3.client("ec2")
sns = boto3.client("sns")

import os
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")

# Every resource should have these tags. This is a simple, common FinOps
# governance check -- untagged resources are one of the most common real
# reasons companies can't tell which team/project is driving their AWS bill.
REQUIRED_TAGS = ["Project", "Owner"]


def handler(event, context):
    instances = ec2.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": ["running", "stopped"]}]
    )

    non_compliant = []

    for reservation in instances["Reservations"]:
        for instance in reservation["Instances"]:
            tags = {t["Key"]: t["Value"] for t in instance.get("Tags", [])}
            missing = [t for t in REQUIRED_TAGS if t not in tags]
            if missing:
                non_compliant.append({
                    "instance_id": instance["InstanceId"],
                    "missing_tags": missing,
                })

    print(f"Non-compliant instances: {non_compliant}")

    if non_compliant and SNS_TOPIC_ARN:
        message_lines = [
            f"- {item['instance_id']}: missing {', '.join(item['missing_tags'])}"
            for item in non_compliant
        ]
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="Tagging Compliance: Untagged EC2 Instances Found",
            Message="The following instances are missing required tags:\n\n" + "\n".join(message_lines),
        )

    return {"non_compliant_count": len(non_compliant), "details": non_compliant}
