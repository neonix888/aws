"""
Visitor Counter Lambda Function

This function handles GET and POST requests for a visitor counter.
- GET /count: Returns current visitor count
- POST /count: Increments and returns new visitor count
"""

import json
import os
import boto3
from decimal import Decimal

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME', 'cloud-resume-visitors')
table = dynamodb.Table(table_name)

# Custom JSON encoder for Decimal types
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj)
        return super(DecimalEncoder, self).default(obj)


def handler(event, context):
    """
    Lambda handler for visitor counter API.

    Args:
        event: API Gateway event
        context: Lambda context

    Returns:
        API Gateway response with visitor count
    """
    try:
        http_method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')

        if http_method == 'POST':
            # Increment counter
            count = increment_counter()
        else:
            # Get current count
            count = get_counter()

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({'count': count}, cls=DecimalEncoder)
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': 'Internal server error'})
        }


def get_counter():
    """Get current visitor count from DynamoDB."""
    response = table.get_item(
        Key={'id': 'visitor_count'}
    )
    item = response.get('Item', {})
    return int(item.get('count', 0))


def increment_counter():
    """Increment visitor count in DynamoDB and return new value."""
    response = table.update_item(
        Key={'id': 'visitor_count'},
        UpdateExpression='SET #count = if_not_exists(#count, :start) + :inc',
        ExpressionAttributeNames={'#count': 'count'},
        ExpressionAttributeValues={
            ':inc': 1,
            ':start': 0
        },
        ReturnValues='UPDATED_NEW'
    )
    return int(response['Attributes']['count'])
