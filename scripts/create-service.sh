#!/bin/bash
reverse() {
    declare -n arr="$1" rev="$2"
    for i in "${arr[@]}"
    do
        rev=("$i" "${rev[@]}")
    done
}

PATH_CREATION_MICROSERVICE=$1
WHICH_SERVICE_CREATE=$2
declare -a ACCEPTED_SERVICES=("authorizer" "layer" "microservice" "workflow")

if [[ -z "$PATH_CREATION_MICROSERVICE" ]] || [[ -z "$WHICH_SERVICE_CREATE" ]] #verificando se foi passado o parametro
then
  echo "============================================================================================================="
  echo "*************************************************************************************************************"
  echo "Ocorreu algum problema!!!!!!"
  echo "*************************************************************************************************************"
  echo "Favor informar um PATH valido e qual SERVICE deseja criar"
  echo ""
  echo "uso: npm run create-service <path do microservico> <authorizer | layer | microservice | workflow> "
  echo "============================================================================================================="
  exit 1
fi

CONTAINS="false"
for i in "${ACCEPTED_SERVICES[@]}"
do
  if [ "$i" == "$WHICH_SERVICE_CREATE" ] ; then
    CONTAINS="true"
  fi
done

# Validando o tipo de serviço
if [[ $CONTAINS == "false" ]]; then # contains
  echo "============================================================================================================="
  echo "*************************************************************************************************************"
  echo "Ocorreu algum problema!!!!!!"
  echo "*************************************************************************************************************"
  echo "Favor informar um SERVICE valido"
  echo ""
  echo "uso: npm run create-service <path do microservico> <authorizer | layer | microservice | workflow> "
  echo "============================================================================================================="
  exit 1
fi

#removendo a barra inicial quando houver
if [[ ${PATH_CREATION_MICROSERVICE} =~ ^/ ]]; then
  PATH_CREATION_MICROSERVICE=$(echo "${PATH_CREATION_MICROSERVICE}"|sed 's/\///')
fi

FILEPATH=${PATH_CREATION_MICROSERVICE}
declare -a arrayPathsCreate

while [ ${FILEPATH} != "." ] && [ ${FILEPATH} != "/" ]; do
  arrayPathsCreate+=(${FILEPATH})
  FILEPATH=$( dirname "${FILEPATH}" )
done

# mudando a ordem do array para criar os diretorios de tras para frente
reverse arrayPathsCreate reversedArrayPathsCreate

if [[ ${reversedArrayPathsCreate[0]} != "src" ]]; then
  for i in ${!reversedArrayPathsCreate[@]}; do
    reversedArrayPathsCreate[$i]="src/${reversedArrayPathsCreate[$i]}"
  done
  reversedArrayPathsCreate=("src" "${reversedArrayPathsCreate[@]}")
fi

#criando as pastas informadas
for i in ${reversedArrayPathsCreate[@]}; do
  if [ ! -d "$i" ] && [ "$i" != ${reversedArrayPathsCreate[-1]} ]; then
    mkdir $i
  fi
done

#clonando o projeto para o path designado
git clone git@gitlab.iesde.com.br:desenvolvimento/${WHICH_SERVICE_CREATE}-template-serverless.git ${reversedArrayPathsCreate[-1]}

cd ${reversedArrayPathsCreate[-1]}

#apagando os arquivos git
rm -rf .git
rm -rf .gitignore
