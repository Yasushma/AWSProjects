import boto3

def lambda_handler(event, context):
    # Initialize the DynamoDB client
    dynamodb = boto3.resource('dynamodb')
    
    # Get the DynamoDB table
    table = dynamodb.Table('Customerdetails')  # Replace 'YourTableName' with your actual table name
    
    try:
        # Retrieve data from DynamoDB using primary key
        response = table.get_item(Key={'Emailid': 'sushma'})  # Replace 'PrimaryKeyName' and 'PrimaryKeyValue' with your actual primary key name and value
        
        # Extract the item from the response
        item = response.get('Item')
        
        # Process the retrieved item as needed
        if item is not None:
           
            # Perform any desired operations with the retrieved data
            # ...
            
            return item
        else:
            return {
                "statusCode": 404,
                "body": "Item not found in DynamoDB"
            }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"An error occurred: {str(e)}"
        }
