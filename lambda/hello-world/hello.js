module.exports.handler = async (event) => {
  console.log('Event: ', event)
  let responseMessage = 'Hello, World!';
  let responseCode = 200;

  if (event.queryStringParameters && event.queryStringParameters['Name']) {
    responseMessage = 'Hello, ' + event.queryStringParameters['Name'] + '!';
    if (event.queryStringParameters['Name'] === '503') {
      responseCode = 503;
    }
  }

  return {
    statusCode: responseCode,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: responseMessage,
    }),
  }
}
