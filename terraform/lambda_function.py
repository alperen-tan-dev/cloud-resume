import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloud-resume-stats')

def lambda_handler(event, context):
    
    response = table.get_item(Key={'id': '0'})
    item = response.get('Item')
    
    count = item['count'] if item else 0
    new_count = count + 1
    
    table.put_item(Item={'id': '0', 'count': new_count})
    
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET'
        },
        'body': json.dumps({'count': int(new_count)})
    }