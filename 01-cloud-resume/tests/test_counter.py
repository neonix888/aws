"""
Unit tests for the visitor counter Lambda function.

Uses moto to mock AWS services for testing.
"""

import json
import os
import pytest
from unittest.mock import patch
import boto3
from moto import mock_aws


# Set environment variable before importing the handler
os.environ['TABLE_NAME'] = 'test-visitors'


@pytest.fixture
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ['AWS_ACCESS_KEY_ID'] = 'testing'
    os.environ['AWS_SECRET_ACCESS_KEY'] = 'testing'
    os.environ['AWS_SECURITY_TOKEN'] = 'testing'
    os.environ['AWS_SESSION_TOKEN'] = 'testing'
    os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'


@pytest.fixture
def dynamodb_table(aws_credentials):
    """Create a mock DynamoDB table."""
    with mock_aws():
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

        table = dynamodb.create_table(
            TableName='test-visitors',
            KeySchema=[
                {'AttributeName': 'id', 'KeyType': 'HASH'}
            ],
            AttributeDefinitions=[
                {'AttributeName': 'id', 'AttributeType': 'S'}
            ],
            BillingMode='PAY_PER_REQUEST'
        )

        # Wait for table to be created
        table.meta.client.get_waiter('table_exists').wait(TableName='test-visitors')

        # Initialize counter
        table.put_item(Item={'id': 'visitor_count', 'count': 0})

        yield table


@mock_aws
def test_get_counter(dynamodb_table):
    """Test getting the current visitor count."""
    # Import handler after mocking
    from src.lambda.counter import get_counter

    # Patch the table reference
    with patch('src.lambda.counter.table', dynamodb_table):
        count = get_counter()
        assert count == 0


@mock_aws
def test_increment_counter(dynamodb_table):
    """Test incrementing the visitor count."""
    from src.lambda.counter import increment_counter

    with patch('src.lambda.counter.table', dynamodb_table):
        # First increment
        count = increment_counter()
        assert count == 1

        # Second increment
        count = increment_counter()
        assert count == 2


@mock_aws
def test_handler_get(dynamodb_table):
    """Test the Lambda handler with GET request."""
    from src.lambda.counter import handler

    with patch('src.lambda.counter.table', dynamodb_table):
        event = {
            'requestContext': {
                'http': {
                    'method': 'GET'
                }
            }
        }

        response = handler(event, None)

        assert response['statusCode'] == 200
        body = json.loads(response['body'])
        assert 'count' in body


@mock_aws
def test_handler_post(dynamodb_table):
    """Test the Lambda handler with POST request."""
    from src.lambda.counter import handler

    with patch('src.lambda.counter.table', dynamodb_table):
        event = {
            'requestContext': {
                'http': {
                    'method': 'POST'
                }
            }
        }

        response = handler(event, None)

        assert response['statusCode'] == 200
        body = json.loads(response['body'])
        assert body['count'] == 1


def test_cors_headers():
    """Test that CORS headers are present in response."""
    from src.lambda.counter import handler

    with mock_aws():
        # Create table for this test
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        table = dynamodb.create_table(
            TableName='test-visitors',
            KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
            AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}],
            BillingMode='PAY_PER_REQUEST'
        )
        table.meta.client.get_waiter('table_exists').wait(TableName='test-visitors')
        table.put_item(Item={'id': 'visitor_count', 'count': 0})

        with patch('src.lambda.counter.table', table):
            event = {'requestContext': {'http': {'method': 'GET'}}}
            response = handler(event, None)

            assert 'Access-Control-Allow-Origin' in response['headers']
            assert response['headers']['Access-Control-Allow-Origin'] == '*'
