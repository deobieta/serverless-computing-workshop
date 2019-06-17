import from_layer as fl

def lambda_handler(event, context):
    name = fl.get_name()
    return {
        'statusCode': 200,
        'body': 'Hola ' + name + ' desde lambda con layers!'
    }