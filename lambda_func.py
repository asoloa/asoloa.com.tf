import os
import json
import boto3
dynamodb = boto3.resource('dynamodb')

env_table = os.environ.get('DYNAMODB_TABLE_NAME')
env_table_pk = os.environ.get('DYNAMODB_TABLE_PK')
env_table_item = os.environ.get('DYNAMODB_TABLE_ITEM')

table = dynamodb.Table(env_table)

def lambda_handler(event, context):
    response = table.get_item(Key={
        env_table_pk: '0'
    })

    # Avoid KeyError by checking if `env_table_item` field exists in the response
    if env_table_item in response["Item"]:
        views = response["Item"][env_table_item] + 1
    else:
        views = 1

    table.put_item(
        Item={
            env_table_pk: '0',
            env_table_item: views
        }
    )

    return views