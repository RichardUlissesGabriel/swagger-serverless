const yaml = require('js-yaml')
const fs = require('fs')

fs.readFile('serverless.yml', 'utf8', function (err, data) {
  if (err) {
    return console.log(err)
  }
  try {
    const doc = yaml.safeLoad(data)
    const allFuncs = doc.functions
    let layers = []

    Object.keys(allFuncs).forEach(func => {
      if (allFuncs[func].layers) {
        allFuncs[func].layers.forEach(layer => {
          layer = layer.replace('#{AWS::Region}', '')
          layer = layer.replace('#{AWS::AccountId}', '')
          // eslint-disable-next-line no-template-curly-in-string
          layer = layer.replace('-${self:provider.stage}', '')
          layer = layer.split(':')[6]
          layers.push(layer)
        })
      }
    })

    layers = [...new Set(layers)]

    console.log(layers.join(','))
    return true
  } catch (e) {
    console.log(e)
  }
})
