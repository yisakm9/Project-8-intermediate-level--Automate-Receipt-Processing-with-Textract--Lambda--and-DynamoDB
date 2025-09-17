import json
import boto3
import os
import uuid
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3_client = boto3.client('s3')
textract_client = boto3.client('textract')
dynamodb = boto3.resource('dynamodb')
ses_client = boto3.client('ses') # <-- ADD SES CLIENT

# Get environment variables
TABLE_NAME = os.environ['DYNAMODB_TABLE_NAME']
SENDER_EMAIL = os.environ['SENDER_EMAIL']
RECIPIENT_EMAIL = os.environ['RECIPIENT_EMAIL']
table = dynamodb.Table(TABLE_NAME)

def handler(event, context):
    """
    This function is triggered by an S3 event and processes the uploaded receipt.
    """
    logger.info("## EVENT RECEIVED")
    logger.info(json.dumps(event))

    # 1. Get the S3 bucket and object key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    logger.info(f"Processing receipt from bucket: {bucket_name}, key: {object_key}")

    try:
        # 2. Call Amazon Textract to analyze the document
        response = textract_client.analyze_document(
            Document={'S3Object': {'Bucket': bucket_name, 'Name': object_key}},
            FeatureTypes=['FORMS']
        )
        
        # 3. Process the Textract response
        extracted_data = {}
        for block in response['Blocks']:
            if block['BlockType'] == 'LINE':
                if 'TOTAL' in block['Text'].upper():
                    extracted_data['total_amount'] = block['Text']

        logger.info(f"Extracted data: {extracted_data}")
        
        # 4. Generate a unique ID and prepare the item for DynamoDB
        receipt_id = str(uuid.uuid4())
        item = {
            'receipt_id': receipt_id,
            's3_bucket': bucket_name,
            's3_key': object_key,
            'upload_timestamp': event['Records'][0]['eventTime'],
            'extracted_data': extracted_data
        }
        
        if 'total_amount' in extracted_data:
            item['total_amount'] = extracted_data['total_amount']

        # 5. Store the data in the DynamoDB table
        table.put_item(Item=item)
        logger.info(f"Successfully stored receipt data in DynamoDB with ID: {receipt_id}")

        # 6. Send a confirmation email using SES <-- NEW SECTION
        email_subject = f"Receipt Processed Successfully: {object_key}"
        email_body = f"""
            Hello,

            The receipt '{object_key}' has been successfully processed and its data has been stored.

            Receipt ID: {receipt_id}
            Extracted Data: {json.dumps(extracted_data, indent=2)}

            Thank you!
        """
        ses_client.send_email(
            Source=SENDER_EMAIL,
            Destination={'ToAddresses': [RECIPIENT_EMAIL]},
            Message={
                'Subject': {'Data': email_subject},
                'Body': {'Text': {'Data': email_body}}
            }
        )
        logger.info(f"Successfully sent confirmation email to {RECIPIENT_EMAIL}")

        return {
            'statusCode': 200,
            'body': json.dumps(f"Successfully processed receipt {object_key}")
        }

    except Exception as e:
        logger.error(f"Error processing receipt: {str(e)}")
        raise e