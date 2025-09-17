import json
import boto3
import os
import uuid
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client('s3')

BUCKET_NAME = os.environ['UPLOAD_BUCKET_NAME']
UPLOAD_PREFIX = "uploads/"

def handler(event, context):
    """
    Generates a presigned URL for uploading a file to S3.
    """
    logger.info(json.dumps(event))
    
    # The body of the POST request from the frontend
    body = json.loads(event.get('body', '{}'))
    file_name = body.get('fileName')
    
    if not file_name:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'fileName is required'})
        }

    # Generate a unique key to prevent filename collisions
    unique_key = f"{UPLOAD_PREFIX}{uuid.uuid4()}-{file_name}"

    try:
        presigned_url = s3_client.generate_presigned_url(
            'put_object',
            Params={'Bucket': BUCKET_NAME, 'Key': unique_key},
            ExpiresIn=300  # URL is valid for 5 minutes
        )
        
        # We need to enable CORS in API Gateway for this to work
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*', # For dev; production should be more restrictive
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST'
            },
            'body': json.dumps({
                'uploadUrl': presigned_url,
                'key': unique_key
            })
        }
    except Exception as e:
        logger.error(f"Error generating presigned URL: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Could not generate upload URL'})
        }