const AWS = require('aws-sdk');

const s3 = new AWS.S3();
const dynamoDB = new AWS.DynamoDB();

exports.handler = async (event) => {
    console.log('LAMBDA déclenchée !');
    console.log('LAMBDA A BIEN DETECTE UN ELEMENT AJOUT');
    
    try {
        for (const record of event.Records) {
            const jobType = record.dynamodb.NewImage.jobType.S;
            console.log('Job Type:', jobType);
            
            if (jobType === 'addToS3') {
                const content = record.dynamodb.NewImage.content.S;
                const id = generateId()
                await writeToS3(content,id);
                console.log('Content written to S3:', content);
            } else if (jobType === 'addToDynamoDb') {
                const content = record.dynamodb.NewImage.content.S;
                const id = generateId(); // Replace with your ID generation logic
                await writeToDynamoDb(content, id);
                console.log('Content written to DynamoDB:', content);
            } else {
                console.log('Invalid jobType:', jobType);
            }
        }
        
        return { statusCode: 200, body: 'Success' };
    } catch (error) {
        console.error('Error:', error);
        return { statusCode: 500, body: 'Error' };
    }
};

async function writeToS3(content,id) {
    const idString = id.toString();
    const params = {
        Bucket: 'feyez',
        Key: idString,
        Body: content
    };
    
    await s3.putObject(params).promise();
}

async function writeToDynamoDb(content, id) {
    const params = {
        TableName: 'dynamoDbForLambda',
        Item: {
            content: { S: content },
            id: { N: id.toString() }
        }
    };
    
    await dynamoDB.putItem(params).promise();
}

function generateId() {
    const timestamp = Date.now();
    return timestamp;
}