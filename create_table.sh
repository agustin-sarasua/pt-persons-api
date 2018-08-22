aws dynamodb create-table --cli-input-json file://create_persons_table.json --region us-east-1
# {
#     "TableDescription": {
#         "TableArn": "arn:aws:dynamodb:us-east-1:161262005667:table/Persons",
#         "AttributeDefinitions": [
#             {
#                 "AttributeName": "Id",
#                 "AttributeType": "S"
#             },
#             {
#                 "AttributeName": "Sub",
#                 "AttributeType": "S"
#             }
#         ],
#         "ProvisionedThroughput": {
#             "NumberOfDecreasesToday": 0,
#             "WriteCapacityUnits": 5,
#             "ReadCapacityUnits": 5
#         },
#         "TableSizeBytes": 0,
#         "TableName": "Persons",
#         "TableStatus": "CREATING",
#         "TableId": "9d863d82-8f4c-4f52-9411-7a2f4cec2d60",
#         "KeySchema": [
#             {
#                 "KeyType": "HASH",
#                 "AttributeName": "Sub"
#             },
#             {
#                 "KeyType": "RANGE",
#                 "AttributeName": "Id"
#             }
#         ],
#         "ItemCount": 0,
#         "CreationDateTime": 1534979740.527
#     }
# }
