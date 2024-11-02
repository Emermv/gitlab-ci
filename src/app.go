package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

//	func main() {
//		http.HandleFunc("/", HelloHandler)
//		http.ListenAndServe(":80", nil)
//	}

func HelloHttpHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	response := map[string]string{"message": "Hello, World!"}
	json.NewEncoder(w).Encode(response)
}

// HelloHandler returns a JSON response for the Hello endpoint
func HelloHandler() (events.APIGatewayProxyResponse, error) {
	output := map[string]string{"message": "Hello, World!"}
	jsonOutput, err := json.Marshal(output)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
			Body:       err.Error(),
		}, err
	}
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       string(jsonOutput),
	}, nil
}

// GoodbyeHandler returns a JSON response for the Goodbye endpoint
func GoodbyeHandler() (events.APIGatewayProxyResponse, error) {
	output := map[string]string{"message": "Goodbye, World!"}
	jsonOutput, err := json.Marshal(output)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
			Body:       err.Error(),
		}, err
	}
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       string(jsonOutput),
	}, nil
}

// handler is the Lambda function entry point
func handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	fmt.Printf("Path:%s Method:%s \n", event.Path, event.HTTPMethod)

	switch event.Path {
	case "/hello":
		return HelloHandler()
	case "/goodbye":
		return GoodbyeHandler()
	default:
		now := fmt.Sprintf("Time is %s", time.Now().Format(time.RFC3339))
		metadata := map[string]string{
			"now":    now,
			"path":   event.Path,
			"method": event.HTTPMethod,
			"body":   event.Body,
		}
		jsonMetadata, err := json.Marshal(metadata)
		if err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: http.StatusInternalServerError,
				Body:       err.Error(),
			}, err
		}
		return events.APIGatewayProxyResponse{
			StatusCode: 200,
			Body:       string(jsonMetadata),
		}, nil
	}
}

func main() {
	lambda.Start(handler)
}
