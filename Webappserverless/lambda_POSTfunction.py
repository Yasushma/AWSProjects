import json
import boto3
client = boto3.client('dynamodb')
def lambda_handler(event, context):
    PutItem = client.put_item(
        TableName='Customerdetails',

        Item = {
            'Emailid': {'S': event['Emailid']},
            'FirstName': {'S': event['FirstName']},
            'LastName': {'S': event['LastName']}
        }
    )
    response = {
      'statusCode': 200,
      'body': json.dumps(PutItem)
    }
    return response