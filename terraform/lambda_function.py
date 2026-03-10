import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloud-resume-stats')

def lambda_handler(event, context):
    # Veritabanından sayıyı almayı dene
    response = table.get_item(Key={'id': '0'})
    item = response.get('Item')
    
    # Eğer tabloda veri yoksa 0'dan başla, varsa olanı al
    count = item['count'] if item else 0
    new_count = count + 1
    
    # Yeni sayıyı kaydet
    table.put_item(Item={'id': '0', 'count': new_count})
    
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET'
        },
        'body': json.dumps({'count': int(new_count)})
    }