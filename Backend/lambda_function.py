import boto3
import json
import uuid
import time

rekognition = boto3.client("rekognition")
dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")

TABLE_NAME = "photo-app-metadata"

def lambda_handler(event, context):
    # Handle API Gateway request
    if event.get("httpMethod") == "GET":
        image_id = event.get("queryStringParameters", {}).get("image_id")

        if not image_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing image_id parameter"})
            }

        table = dynamodb.Table(TABLE_NAME)
        response = table.get_item(Key={"image_id": image_id})

        if "Item" not in response:
            return {
                "statusCode": 404,
                "body": json.dumps({"error": "Image metadata not found"})
            }

        return {
            "statusCode": 200,
            "body": json.dumps(response["Item"])
        }
    
    # Handle S3 event (image upload)
    elif "Records" in event:
        for record in event["Records"]:
            bucket = record["s3"]["bucket"]["name"]
            key = record["s3"]["object"]["key"]

            image_id = str(uuid.uuid4())
            upload_time = int(time.time())

            # Analyze image using Rekognition
            try:
                response = rekognition.detect_labels(
                    Image={"S3Object": {"Bucket": bucket, "Name": key}},
                    MaxLabels=10,
                    MinConfidence=75
                )
                labels = [label["Name"] for label in response["Labels"]]
            except Exception as e:
                return {
                    "statusCode": 500,
                    "body": json.dumps({"error": f"Rekognition error: {str(e)}"})
                }

            # Store metadata in DynamoDB
            table = dynamodb.Table(TABLE_NAME)
            table.put_item(Item={
                "image_id": image_id,
                "bucket": bucket,
                "key": key,
                "labels": labels,
                "upload_time": upload_time
            })

            print(f"Processed image {key} - Labels: {labels}")

        return {
            "statusCode": 200,
            "body": json.dumps("Image processed successfully!")
        }

    return {
        "statusCode": 405,
        "body": json.dumps({"error": "Method not allowed"})
    }