/* eslint-disable no-template-curly-in-string */
const yaml = require('js-yaml')
const aws = require('aws-sdk')
const fs = require('fs')

const stage = process.argv[2]

function sleep (ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}

fs.readFile('serverless.yml', 'utf8', async (err, data) => {
  if (err) {
    return console.log(err)
  }

  try {
    const doc = yaml.safeLoad(data)
    const parameters = doc.resources.Resources
    const region = doc.provider.region

    const ssm = new aws.SSM({ region: region })

    for (const param of Object.keys(parameters)) {
      if (parameters[param].Type === 'AWS::SSM::Parameter') {
        console.log(`Criação da chave: ${param}`)
        const properties = parameters[param].Properties

        properties.Name = properties.Name.replace('${self:provider.moduleName}', `${doc.provider.moduleName}`)
        properties.Name = properties.Name.replace('${self:provider.stage}', `${stage}`)
        // properties.Value = `${properties.Value}`

        if (properties.Type === 'String') {
          properties.Type = 'SecureString'
        }

        if (!properties.Overwrite) {
          properties.Overwrite = true
        }

        const response = await ssm.putParameter(properties).promise()
        console.log(response)
        await sleep(1000)
      }
    }

    return true
  } catch (e) {
    console.log(e)
    return new Error(e)
  }
})
