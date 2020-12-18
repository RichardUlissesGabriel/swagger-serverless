import React from 'react';
import SwaggerUI from "swagger-ui-react"
import "swagger-ui-react/swagger-ui.css"

const query = window.location.search.substring(1)
const host = query.split("&")[0].split("=")[1]
const stage = query.split("&")[1].split("=")[1]

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <SwaggerUI url={`https://files-apigateway-documentation-account-${stage}.s3.amazonaws.com/${host}/${host}-${stage}.json`} />
      </header>
    </div>
  );
}

export default App;
