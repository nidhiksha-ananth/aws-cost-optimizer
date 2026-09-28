import boto3

ec2 = boto3.client("ec2")

TAG_KEY = "AutoStop"
TAG_VALUE = "true"


def handler(event, context):
    instances = ec2.describe_instances(
        Filters=[
            {"Name": f"tag:{TAG_KEY}", "Values": [TAG_VALUE]},
            {"Name": "instance-state-name", "Values": ["stopped"]},
        ]
    )

    instance_ids = [
        i["InstanceId"]
        for r in instances["Reservations"]
        for i in r["Instances"]
    ]

    if not instance_ids:
        print("No tagged stopped instances found. Nothing to start.")
        return {"started": []}

    print(f"Starting instances: {instance_ids}")
    ec2.start_instances(InstanceIds=instance_ids)

    return {"started": instance_ids}
