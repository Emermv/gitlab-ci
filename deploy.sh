#!/bin/bash

# Set the AWS region and profile
region="eu-west-1"
profile="personal-key"

# Create the layer
layer_name="mylayer"
layer_zip="mylayer.zip"
pip install -r requirements.txt -t python/
cd python
zip -r ../$layer_zip .
cd ..
aws lambda publish-layer-version --layer-name $layer_name --description "Python dependencies" --zip-file fileb://$layer_zip --compatible-runtimes python3.8 --region $region --profile $profile
layer_arn=$(aws lambda list-layer-versions --layer-name $layer_name --query 'LayerVersions[0].LayerVersionArn' --output text --region $region --profile $profile)

# Create the Lambda function
lambda_name="fpl-top-scorer"
handler_name="lambda_function.lambda_handler"
zip_file="lambda_function.zip"
runtime="python3.8"
role_arn=$(aws iam get-role --role-name lambda_basic_execution --query 'Role.Arn' --output text --profile $profile)
aws lambda create-function --function-name $lambda_name --handler $handler_name --runtime $runtime --role $role_arn --zip-file fileb://$zip_file --layers $layer_arn --region $region --profile $profile

# Create the API Gateway
rest_api_name="fpl-top-scorer-api"
description="API for retrieving the top scorer for a given game week of the Fantasy Premier League"
rest_api_id=$(aws apigateway create-rest-api --name $rest_api_name --description "$description" --query 'id' --output text --region $region --profile $profile)
resource_id=$(aws apigateway get-resources --rest-api-id $rest_api_id --query 'items[0].id' --output text --region $region --profile $profile)
aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_id --http-method GET --authorization-type NONE --region $region --profile $profile
uri="arn:aws:apigateway:$region:lambda:path/2015-03-31/functions/arn:aws:lambda:$region:$(aws sts get-caller-identity --query 'Account' --output text --profile $profile):function:$lambda_name/invocations"
aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_id --http-method GET --type AWS_PROXY --integration-http-method POST --uri $uri --region $region --profile $profile
aws apigateway create-deployment --rest-api-id $rest_api_id --stage-name prod --region $region --profile $profile
endpoint_url="https://$(aws apigateway get-rest-apis --query 'items[0].id' --output text --region $region --profile $profile).execute-api.$region.amazonaws.com/prod"

# Update the Lambda function with the API Gateway trigger
aws lambda add-permission --function-name $lambda_name --statement-id apigateway-test-2 --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:$region:$(aws sts get-caller-identity --query 'Account' --output text --profile $profile):$rest_api_id/*/GET/" --region $region --profile $profile
aws lambda create-event-source-mapping --function-name $lambda_name --batch-size 1 --event-source-arn "arn:aws:execute-api:$region:$(aws sts get-caller-identity --query 'Account' --output text --profile $profile):$rest_api_id/*/GET/" --region $region --