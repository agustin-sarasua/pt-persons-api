####################################################################
# Create the Rest API
####################################################################

aws apigateway create-rest-api --name 'Persons API' --region us-east-1
# {
#     "apiKeySource": "HEADER",
#     "name": "Persons API",
#     "createdDate": 1534978997,
#     "endpointConfiguration": {
#         "types": [
#             "EDGE"
#         ]
#     },
#     "id": "42pk7zp5q6"
# }

####################################################################
# Create the Resources
####################################################################

aws apigateway get-resources --rest-api-id 42pk7zp5q6 --region us-east-1
# {
#     "items": [
#         {
#             "path": "/",
#             "id": "8ugz2ke4q1"
#         }
#     ]
# }

# Create resource /persons
aws apigateway create-resource --rest-api-id 42pk7zp5q6 \
      --region us-east-1 \
      --parent-id 8ugz2ke4q1 \
      --path-part persons
# {
#     "path": "/persons",
#     "pathPart": "persons",
#     "id": "qh0p66",
#     "parentId": "8ugz2ke4q1"
# }

####################################################################
# Create Authorizer for the endpoints (cognito user pool)
####################################################################

# Create Authorizer (AUTH)
aws apigateway create-authorizer --rest-api-id 42pk7zp5q6 \
        --name 'Persons_API_Authorizer' \
        --type COGNITO_USER_POOLS \
        --provider-arns 'arn:aws:cognito-idp:us-east-1:161262005667:userpool/us-east-1_3IwH7mpoM' \
        --identity-source 'method.request.header.Authorization' \
        --authorizer-result-ttl-in-seconds 300
# {
#     "authType": "cognito_user_pools",
#     "identitySource": "method.request.header.Authorization",
#     "name": "Persons_API_Authorizer",
#     "providerARNs": [
#         "arn:aws:cognito-idp:us-east-1:161262005667:userpool/us-east-1_3IwH7mpoM"
#     ],
#     "type": "COGNITO_USER_POOLS",
#     "id": "5zxrm0"
# }

# Get AUTHORIZERS
aws apigateway get-authorizers --rest-api-id 42pk7zp5q6

####################################################################
# Create Method Request and enable responses on Resources
####################################################################

# Enable GET (AUTH) for /persons
aws apigateway put-method --rest-api-id 42pk7zp5q6 \
       --resource-id qh0p66 \
       --http-method GET \
       --authorization-type COGNITO_USER_POOLS \
       --authorizer-id 5zxrm0 \
       --region us-east-1
# {
#     "apiKeyRequired": false,
#     "httpMethod": "GET",
#     "authorizationType": "COGNITO_USER_POOLS",
#     "authorizerId": "5zxrm0"
# }

# Enable POST (AUTH) for /places
aws apigateway put-method --rest-api-id 42pk7zp5q6 \
       --resource-id qh0p66 \
       --http-method POST \
       --authorization-type COGNITO_USER_POOLS \
       --authorizer-id 5zxrm0 \
       --region us-east-1
# {
#     "apiKeyRequired": false,
#     "httpMethod": "POST",
#     "authorizationType": "COGNITO_USER_POOLS",
#     "authorizerId": "5zxrm0"
# }

# Enable 200 OK to GET /places
aws apigateway put-method-response --rest-api-id 42pk7zp5q6 \
       --resource-id qh0p66 --http-method GET \
       --status-code 200  --region us-east-1
# {
#     "statusCode": "200"
# }

# Enable 200 OK to POST /places
aws apigateway put-method-response --rest-api-id 42pk7zp5q6 \
       --resource-id qh0p66 --http-method POST \
       --status-code 200  --region us-east-1
# {
#     "statusCode": "200"
# }

####################################################################
# Now Integrate with the Backend
# NOTE: Create the backend Lambda
####################################################################
# Create Rol for the lambda function
./create_rol.sh

# Create the lambda
./create_lambda.sh
# {
#     "TracingConfig": {
#         "Mode": "PassThrough"
#     },
#     "CodeSha256": "7KgjPNzyXH0wyN7vMBjhKkC6StMXJpYRcWtU56tuYuU=",
#     "FunctionName": "persons-api",
#     "CodeSize": 5633981,
#     "RevisionId": "68b0f719-cdc5-444e-95f5-46cf49d19fb3",
#     "MemorySize": 128,
#     "FunctionArn": "arn:aws:lambda:us-east-1:161262005667:function:persons-api",
#     "Version": "$LATEST",
#     "Role": "arn:aws:iam::161262005667:role/PersonsAPILambdaRole",
#     "Timeout": 3,
#     "LastModified": "2018-08-22T23:36:26.674+0000",
#     "Handler": "main",
#     "Runtime": "go1.x",
#     "Description": ""
# }

# Integrate GET /persons with Lambda function
aws apigateway put-integration --rest-api-id 42pk7zp5q6 \
        --resource-id qh0p66 \
        --http-method GET \
        --type AWS_PROXY \
        --integration-http-method POST \
        --region us-east-1 \
        --uri 'arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:161262005667:function:persons-api/invocations'
# {
#     "passthroughBehavior": "WHEN_NO_MATCH",
#     "timeoutInMillis": 29000,
#     "uri": "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:161262005667:function:persons-api/invocations",
#     "httpMethod": "POST",
#     "cacheNamespace": "qh0p66",
#     "type": "AWS_PROXY",
#     "cacheKeyParameters": []
# }

# Integrate POST /persons with Lambda function
aws apigateway put-integration --rest-api-id 42pk7zp5q6 \
        --resource-id qh0p66 \
        --http-method POST \
        --type AWS_PROXY \
        --integration-http-method POST \
        --region us-east-1 \
        --uri 'arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:161262005667:function:persons-api/invocations'
# {
#     "passthroughBehavior": "WHEN_NO_MATCH",
#     "timeoutInMillis": 29000,
#     "uri": "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:161262005667:function:persons-api/invocations",
#     "httpMethod": "POST",
#     "cacheNamespace": "qh0p66",
#     "type": "AWS_PROXY",
#     "cacheKeyParameters": []
# }

#### NOTE
# Retrive previous integration
aws apigateway get-integration --rest-api-id 42pk7zp5q6 --resource-id 9fq64m --http-method GET

# Create Integration Response for GET /persons
aws apigateway put-integration-response --rest-api-id 42pk7zp5q6 \
       --resource-id qh0p66 --http-method GET \
       --status-code 200 --selection-pattern ""  \
       --region us-east-1
# {
#     "selectionPattern": "",
#     "statusCode": "200"
# }

# Create Integration Response for POST /persons
aws apigateway put-integration-response --rest-api-id 42pk7zp5q6 \
       --resource-id qh0p66 --http-method POST \
       --status-code 200 --selection-pattern ""  \
       --region us-east-1
# {
#     "selectionPattern": "",
#     "statusCode": "200"
# }


# Add Execution Permision API - Lambda to /persons
aws lambda add-permission \
--function-name persons-api \
--statement-id 'persons_allow_permission' \
--action lambda:InvokeFunction \
--principal apigateway.amazonaws.com \
--source-arn 'arn:aws:execute-api:us-east-1:161262005667:42pk7zp5q6/*/*/persons' \
--region us-east-1
# {
#     "Statement": "{\"Sid\":\"persons_allow_permission\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"apigateway.amazonaws.com\"},\"Action\":\"lambda:InvokeFunction\",\"Resource\":\"arn:aws:lambda:us-east-1:161262005667:function:persons-api\",\"Condition\":{\"ArnLike\":{\"AWS:SourceArn\":\"arn:aws:execute-api:us-east-1:161262005667:42pk7zp5q6/*/*/persons\"}}}"
# }


####################################################################
# Deploy de API to stage
# NOTE: Create the backend Lambda
####################################################################

aws apigateway create-deployment --rest-api-id 42pk7zp5q6 \
       --region us-east-1 \
       --stage-name test \
       --stage-description 'Test stage' \
       --description 'First deployment'
# {
#     "description": "First deployment",
#     "id": "dft5cm",
#     "createdDate": 1534981276
# }

