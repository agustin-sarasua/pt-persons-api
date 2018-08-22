package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
	uuid "github.com/satori/go.uuid"
)

var ginLambda *ginadapter.GinLambda

var errorLogger = log.New(os.Stderr, "ERROR ", log.Llongfile)
var infoLogger = log.New(os.Stdout, "INFO ", log.Llongfile)

func getClaimsSub(ctx events.APIGatewayProxyRequestContext) string {
	jc, _ := json.Marshal(ctx.Authorizer)
	r := make(map[string]map[string]interface{})
	err := json.Unmarshal([]byte(jc), &r)
	if err != nil {
		fmt.Printf("Something went wrong %v", err)
	}
	fmt.Printf("Printing sub: %s ", r["claims"]["sub"].(string))
	return r["claims"]["sub"].(string)
}

func createPerson(c *gin.Context) {
	// the methods are available in your instance of the GinLambda
	// object and receive the http.Request object
	// RequestContext
	apiGwContext, _ := ginLambda.GetAPIGatewayContext(c.Request)
	sub := getClaimsSub(apiGwContext)
	// apiGwStageVars, _ := ginLambda.GetAPIGatewayStageVars(c.Request)

	// stage variables are stored in a map[string]string
	// stageVarValue := apiGwStageVars["MyStageVar"]

	p := Person{}
	uid, _ := uuid.NewV4()
	p.ID = uid.String()

	err := c.BindJSON(&p)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": err.Error(),
		})
	}

	if p.Name == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Name not found",
		})
		return
	}

	p.Sub = sub
	err = putItem(&p)
	if err != nil {
		fmt.Printf("Error saving item in db %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": err.Error(),
		})
	}
	c.JSON(http.StatusAccepted, p)
}

func getPerson(c *gin.Context) {
	pets := make([]Person, 2)
	c.JSON(200, pets)
}

func getPersons(c *gin.Context) {
	apiGwContext, _ := ginLambda.GetAPIGatewayContext(c.Request)
	sub := getClaimsSub(apiGwContext)
	items, err := getItems(sub)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": err.Error(),
		})
	}
	c.JSON(200, items)
}

// Handler is the main entry point for Lambda. Receives a proxy request and
// returns a proxy response
func Handler(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	if ginLambda == nil {
		// stdout and stderr are sent to AWS CloudWatch Logs
		log.Printf("Gin cold start")
		r := gin.Default()
		r.GET("/persons", getPersons)
		r.POST("/persons", createPerson)

		ginLambda = ginadapter.New(r)
	}

	return ginLambda.Proxy(req)
}

func main() {
	lambda.Start(Handler)
}
