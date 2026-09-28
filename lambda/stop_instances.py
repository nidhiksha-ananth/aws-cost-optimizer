import boto3

ec2 = boto3.client("ec2")

# Only touches instances explicitly tagged this way -- never touches
# untagged or production-tagged instances. This tag-based safety check
# is the single most important line in this whole function.
TAG_KEY = "AutoStop"
TAG_VALUE = "true"


def handler(event, context):
    instances = ec2.describe_instances(
        Filters=[
            {"Name": f"tag:{TAG_KEY}", "Values": [TAG_VALUE]},
            {"Name": "instance-state-name", "Values": ["running"]},
        ]
    )

    instance_ids = [
        i["InstanceId"]
        for r in instances["Reservations"]
        for i in r["Instances"]
    ]

    if not instance_ids:
        print("No tagged running instances found. Nothing to stop.")
        return {"stopped": []}

    print(f"Stopping instances: {instance_ids}")
    ec2.stop_instances(InstanceIds=instance_ids)

    return {"stopped": instance_ids}
