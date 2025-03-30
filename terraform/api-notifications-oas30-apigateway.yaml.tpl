openapi: "3.0.1"
paths:
  /notifications/email/send:
    post:
      responses:
        "200":
          description: "200 response"
          headers:
            Content-Type:
              schema:
                type: "string"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Empty"
      x-amazon-apigateway-integration:
        type: "aws"
        credentials: "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${role_name}"
        httpMethod: "POST"
        uri: "arn:aws:apigateway:${AWS_REGION}:sqs:path/${AWS_ACCOUNT_ID}/${queue_name}"
        responses:
          default:
            statusCode: "200"
            responseParameters:
              method.response.header.Content-Type: "'application/json'"
            responseTemplates:
              application/json: "#set($response = $input.path('$.SendMessageResponse.SendMessageResult'))\n\
                {\n  \"status\": \"sucesso\",\n  \"mensagem\": \"Sua mensagem foi\
                \ enviada com sucesso para a fila SQS.\",\n  \"messageId\": \"$response.MessageId\"\
                \n}\n"
        requestParameters:
          integration.request.header.Content-Type: "'application/x-www-form-urlencoded'"
        requestTemplates:
          application/json: "Version=2012-11-05&Action=SendMessage&MessageBody=$input.body"
        passthroughBehavior: "when_no_match"
        timeoutInMillis: 29000
