package main

import (
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbiface"
)

const tableName = "Persons"

// Declare a new DynamoDB instance. Note that this is safe for concurrent
// use.
var db dynamodbiface.DynamoDBAPI = dynamodb.New(session.New(), aws.NewConfig().WithRegion("us-east-1"))

func getItems(sub string) ([]Person, error) {
	// Prepare the input for the query.
	input := &dynamodb.QueryInput{
		TableName: aws.String(tableName),
		KeyConditions: map[string]*dynamodb.Condition{
			"Sub": {
				ComparisonOperator: aws.String("EQ"),
				AttributeValueList: []*dynamodb.AttributeValue{
					{
						S: aws.String(sub),
					},
				},
			},
		},
	}
	var resp1, err1 = db.Query(input)
	if err1 != nil {
		fmt.Println(err1)
		return nil, err1
	} else {
		ps := []Person{}
		err1 = dynamodbattribute.UnmarshalListOfMaps(resp1.Items, &ps)
		if err1 != nil {
			return nil, err1
		}
		return ps, nil
	}
}

// Add a record to DynamoDB.
func putItem(e *Person) error {
	av, err := dynamodbattribute.MarshalMap(e)
	if err != nil {
		panic(fmt.Sprintf("failed to DynamoDB marshal Record, %v", err))
	}
	input := &dynamodb.PutItemInput{
		TableName: aws.String(tableName),
		Item:      av,
	}

	_, err = db.PutItem(input)
	return err
}
