##1) First Creating the DynamoDB with the student as partition key

```
aws application-autoscaling put-scaling-policy --service-namespace 'dynamodb' --resource-id 'table/console_e264d683-c20f-45b9-bbfa-fcf2dc7cc743;' --scalable-dimension 'dynamodb:table:ReadCapacityUnits' --policy-name 'console_e264d683-c20f-45b9-bbfa-fcf2dc7cc743;-scaling-policy' --policy-type 'TargetTrackingScaling' --target-tracking-scaling-policy-configuration '{"PredefinedMetricSpecification":{"PredefinedMetricType":"DynamoDBReadCapacityUtilization"},"TargetValue":70}' 

aws dynamodb create-table --table-name 'Student' --attribute-definitions '{"AttributeName":"studentid","AttributeType":"S"}' --billing-mode 'PAY_PER_REQUEST' --key-schema '{"AttributeName":"studentid","KeyType":"HASH"}' --table-class 'STANDARD'
```

##2) Create an Role

Name- studentlambdarole
Select Trust Entity -- Lambda
Policies -- AWSLambdaBasicExecutionRole
            AmazonDynamoDBFullAccess

Description : Allows Lambda functions to call AWS services on your behalf.

##3) Create Lambda

Function Name: getStudent

Runtime: Python 3.13
Architecture x86_64

Execution Role: studentlambdarole

##4) Provisioning Lambda Code 
Add code, script Name : Python-get-Student.py
and edit the dynamodb table name in our case it is 'Student'
and deploy

##5) Create another Lambda Function 

Name: insertStudent
Runtime: Python3.13
Architecture x86_64

Execution Role: studentlambdarole

    You can test 
    
    {
            "studentid": "002",
            "name": "test",
            "class": "6",
            "age": "age"

}

You should see in the DynamoDB table(under explore table option)

and retrieve same test by using the getStudent Lambda and simply click Test

##6) Create Rest API

Api Name: student_api

Then create a method 
