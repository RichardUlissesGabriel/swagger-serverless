import React from 'react'
import SwaggerUI from "swagger-ui-react"
import "swagger-ui-react/swagger-ui.css"
const config = require('./config.json')

function App() {
  return (
    <div className="App">
      <header className="App-header">
      <SwaggerUI url= {config.srcSwaggerFile} />
      </header>
    </div>
  );
}

export default App