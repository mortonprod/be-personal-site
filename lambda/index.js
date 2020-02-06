var AWS = require('aws-sdk');
var ses = new AWS.SES();
 
var RECEIVER = 'alex@alexandermorton.co.uk';
var SENDER = 'alex@alexandermorton.co.uk';

var response = {
 "isBase64Encoded": false,
 "headers": { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': 'alexandermorton.co.uk'},
 "statusCode": 200,
 "body": "{\"result\": \"Success.\"}"
 };

exports.handler = function (event, context,callback) {
    console.log('Received event:', event);
    sendEmail(JSON.parse(event.body), function (err, data) {
      console.error(`Error: ${JSON.stringify(err)}`);
      if(err) {
        const response = {
          statusCode: 400,
          headers: {
            "Access-Control-Allow-Origin" : "*", // Required for CORS support to work
            "Access-Control-Allow-Credentials" : true // Required for cookies, authorization headers with HTTPS
          },
          body: JSON.stringify({ "message": "Sent" })
        };
    
        callback(null, response);
      }
        // context.done(err, null);
        const response = {
          statusCode: 200,
          headers: {
            "Access-Control-Allow-Origin" : "*", // Required for CORS support to work
            "Access-Control-Allow-Credentials" : true // Required for cookies, authorization headers with HTTPS
          },
          body: JSON.stringify({ "message": "Sent" })
        };
    
        callback(null, response);
    });
};
 
function sendEmail (event, done) {
    var params = {
        Destination: {
            ToAddresses: [
                RECEIVER
            ]
        },
        Message: {
            Body: {
                Text: {
                    Data: 'name: ' + event.name + '\nemail: ' + event.email + '\nnote: ' + event.note,
                    Charset: 'UTF-8'
                }
            },
            Subject: {
                Data: 'Website Referral Form: ' + event.name,
                Charset: 'UTF-8'
            }
        },
        Source: SENDER
    };
    ses.sendEmail(params, done);
}