import json
def handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps('Hola desde Lambda Canary release Version 1!')
    }