const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');

const client = new SESClient({});

const RECEIVER = 'alex@alexandermorton.co.uk';
const SENDER = 'alex@alexandermorton.co.uk';

const ALLOWED_ORIGINS = [
  'https://archive.alexandermorton.co.uk'
];

const EMAIL_REGEX = /^[\w\-.]+@([\w-]+\.)+[\w-]{2,6}$/;

const MAX_NAME_LENGTH = 100;
const MAX_EMAIL_LENGTH = 254;
const MAX_NOTE_LENGTH = 5000;

function getCorsOrigin(event) {
  const origin = (event.headers && (event.headers.origin || event.headers.Origin)) || '';
  return ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];
}

function validateFields(body) {
  if (!body.name || typeof body.name !== 'string' ||
      body.name.trim().length < 2 || body.name.length > MAX_NAME_LENGTH) {
    return 'Name must be between 2 and 100 characters';
  }
  if (!body.email || typeof body.email !== 'string' ||
      body.email.length > MAX_EMAIL_LENGTH || !EMAIL_REGEX.test(body.email)) {
    return 'Invalid email address';
  }
  if (!body.note || typeof body.note !== 'string' ||
      body.note.trim().length === 0 || body.note.length > MAX_NOTE_LENGTH) {
    return 'Message must be between 1 and 5000 characters';
  }
  return null;
}

exports.handler = async function (event) {
  const corsOrigin = getCorsOrigin(event);

  let body;
  try {
    body = JSON.parse(event.body);
  } catch (e) {
    return {
      statusCode: 400,
      headers: { 'Access-Control-Allow-Origin': corsOrigin },
      body: JSON.stringify({ message: 'Invalid request body' })
    };
  }

  const validationError = validateFields(body);
  if (validationError) {
    return {
      statusCode: 400,
      headers: { 'Access-Control-Allow-Origin': corsOrigin },
      body: JSON.stringify({ message: validationError })
    };
  }

  const safeName = body.name.replace(/[\r\n]/g, ' ').trim();
  const safeEmail = body.email.trim();
  const safeNote = body.note.trim();

  const params = {
    Destination: { ToAddresses: [RECEIVER] },
    Message: {
      Body: {
        Text: {
          Data: `name: ${safeName}\nemail: ${safeEmail}\nnote: ${safeNote}`,
          Charset: 'UTF-8'
        }
      },
      Subject: {
        Data: `Website Referral Form: ${safeName}`,
        Charset: 'UTF-8'
      }
    },
    Source: SENDER
  };

  try {
    await client.send(new SendEmailCommand(params));
    return {
      statusCode: 200,
      headers: { 'Access-Control-Allow-Origin': corsOrigin },
      body: JSON.stringify({ message: 'Sent' })
    };
  } catch (err) {
    console.error('SES error:', err.message);
    return {
      statusCode: 500,
      headers: { 'Access-Control-Allow-Origin': corsOrigin },
      body: JSON.stringify({ message: 'Failed to send email' })
    };
  }
};
