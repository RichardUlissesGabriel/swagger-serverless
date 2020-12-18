#!/bin/bash

PATH_MICROSERVICE=$1

if [ ! -d "$PATH_MICROSERVICE" ]; then
    echo "Favor informar um PATH valido do microServico"
    echo "uso: npm run update-microservice <path do microservico>"
else
    cd ${PATH_MICROSERVICE}
    ls -la

    #adicionando novamente a refetencia do microserviço
    git init
    git add -A .
    git commit -m 'Atualizando microservice'
    git pull git@gitlab.iesde.com.br:desenvolvimento/microservice-template-serverless.git master

    #Apagando a referencia novamente
    rm -rf .git
    rm -rf .gitignore
fi
