const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');

const client = new SESClient({});

const RECEIVER = 'alex@alexandermorton.co.uk';
const SENDER = 'alex@alexandermorton.co.uk';

exports.handler = async function (event) {
  console.log('Received event:', event);

  let body;
  try {
    body = JSON.parse(event.body);
  } catch (e) {
    return {
      statusCode: 400,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ message: 'Invalid request body' })
    };
  }

  if (!body.name || !body.email || !body.note) {
    return {
      statusCode: 400,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ message: 'Missing required fields' })
    };
  }

  const params = {
    Destination: { ToAddresses: [RECEIVER] },
    Message: {
      Body: {
        Text: {
          Data: `name: ${body.name}\nemail: ${body.email}\nnote: ${body.note}`,
          Charset: 'UTF-8'
        }
      },
      Subject: {
        Data: `Website Referral Form: ${body.name}`,
        Charset: 'UTF-8'
      }
    },
    Source: SENDER
  };

  try {
    await client.send(new SendEmailCommand(params));
    return {
      statusCode: 200,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ message: 'Sent' })
    };
  } catch (err) {
    console.error('SES error:', err);
    return {
      statusCode: 500,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ message: 'Failed to send email' })
    };
  }
};
