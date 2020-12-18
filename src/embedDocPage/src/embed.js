/* eslint-disable import/no-absolute-path */

const getParameter = require('/opt/getParameter')

module.exports.get = async (event, context, callback) => {
  console.log(event)
  console.log(context)
  const key = `/apiGatewayDocumentation/${event.requestContext.stage || 'dev'}/CLOUDFRONT`
  const parameters = await getParameter([key])
  const url = parameters[0][key].Value
  const html = `
    <html>
      <body>
      <iframe src="https://${url}?host=${event.requestContext.domainPrefix}&stage=${event.requestContext.stage}" width="100%" height="100%" frameBorder="0">Browser not compatible.</iframe>
      </body>
    </html>
  `
  const response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/html'
    },
    body: html
  }
  callback(null, response)
}
