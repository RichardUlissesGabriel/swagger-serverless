#!/bin/bash
# function to get creation time from folder/file
get_crtime() {
    for target in "${@}"; do
        if [[ -d "${target}" ]]
        then
            inode=$(stat -c '%i' "${target}")
            fs=$(df  --output=source "${target}"  | tail -1)
            crtime=$(sudo debugfs -R 'stat <'"${inode}"'>' "${fs}" 2>/dev/null |
            grep -oP 'crtime.*--\s*\K.*')
            printf "%s" "${crtime}"
        else
            printf "not_created"
        fi
    done
}

# lets initiate this project
# npm i

# some variables to help us!
FUNCTION_NAME=$1
PATH_PARAMETERS=$2
PATH_SERVERLESS_PARAMETER=""
PATH_THIS_PROJECT=$(pwd)
# check if function name was informed
if [[ -z "$FUNCTION_NAME" ]]
then
    echo "==========================================================================================="
    echo "*******************************************************************************************"
    echo "  Something went wrong!!!!!!"
    echo "*******************************************************************************************"
    echo "  You need to inform a valid function name to execution"
    echo "-------------------------------------------------------------------------------------------"
    echo "  to execute use: npm run invoke-local {FUNCTION_NAME} {PATH_PARAMETERS} "
    echo "-------------------------------------------------------------------------------------------"
    echo "  FUNCTION_NAME: Is the name of you function defined inside the file ./serverless.yml"
    echo "  PATH_PARAMETERS: IS the path of your tests file used inside you function"
    echo "==========================================================================================="
    exit 0
fi

# check if parameter was informed
if [[ ! -z "$PATH_PARAMETERS" ]]
then
    # check if path parameter is valid
    if [[ -f $PATH_PARAMETERS ]]
    then
        # variable used to append the --path parameter to 'serverless invoke local' function
        PATH_SERVERLESS_PARAMETER="--path $PATH_PARAMETERS"
    else
        echo "==========================================================================================="
        echo "*******************************************************************************************"
        echo "  Something went wrong!!!!!!"
        echo "*******************************************************************************************"
        echo "  You need to inform the a valid path to you parameters file"
        echo "-------------------------------------------------------------------------------------------"
        echo "  to execute use: npm run invoke-local {FUNCTION_NAME} {PATH_PARAMETERS} "
        echo "-------------------------------------------------------------------------------------------"
        echo "  FUNCTION_NAME: Is the name of you function defined inside the file ./serverless.yml"
        echo "  PATH_PARAMETERS: IS the path of your tests file used inside you function"
        echo "==========================================================================================="
        exit 0
    fi
fi

# now we going to prepare use for yours layers
echo "==========================================================================================="
echo "-------------------------------------------------------------------------------------------"
echo "  Let's go install yours layers "
echo "-------------------------------------------------------------------------------------------"
echo "==========================================================================================="
# let's check if your serverless.yml uses layer
# now let me use node for a little help
layersNodeReturn=$(node ./scripts/usable-layers.js)
IFS=', ' read -r -a LIST_LAYERS <<< $layersNodeReturn

# we need to locate the folder of the layers
ROOT_FOLDER_LAYERS="/opt/layer-serverless"
PATH_LAYER_EXISTS=false

if [ -d ${ROOT_FOLDER_LAYERS} ]
then
    cd ${ROOT_FOLDER_LAYERS}
    git pull origin master
else
    cd /opt
    git clone git@gitlab.iesde.com.br:desenvolvimento/layer-serverless.git
fi

ROOT_FOLDER_LAYERS="$ROOT_FOLDER_LAYERS/src/layers/"

# now we have all layers, then let's move all to /opt
for layer in ${LIST_LAYERS[@]}
do
    echo "*******************************************************************************************"
    echo "-------------------------------------------------------------------------------------------"
    echo "  We going to install $layer "
    echo "-------------------------------------------------------------------------------------------"

    # let's go inside the layer
    cd $ROOT_FOLDER_LAYERS/$layer/

    # let's get the middle o layer
    FOLDER_TO_MOVE=$(ls -d */)
    FOLDER_TO_MOVE="${FOLDER_TO_MOVE%?}"
    cd "$FOLDER_TO_MOVE"

    # the name of folder from layer is the name of handler .js
    # from the middy folder "$FOLDER_TO_MOVE"
    # only node_module works different
    if [ "$layer" == "MiddyDependenciesNodeModule" ]
    then
        FOLDER_NAME="node_modules"
    else
        FOLDER_NAME=$(ls -f *.js | head -1)
        FOLDER_NAME="${FOLDER_NAME%.*}"
    fi

    # we don't need to make a copy if we have already done this before
    DATE_CREATION_LAYER=$(get_crtime "/opt/$FOLDER_NAME")
    if [ "$DATE_CREATION_LAYER" != "not_created" ]
    then
        DATE_CREATION_LAYER=$(date -d "$DATE_CREATION_LAYER" +"%Y-%m-%d")
    fi
    CURRENT_DATE=$(date +"%Y-%m-%d")

    # let's do only the fist time in the day
    if [[ "$CURRENT_DATE" > "$DATE_CREATION_LAYER" ]] || [ $DATE_CREATION_LAYER = "not_created" ]
    then

        if [ "$layer" == "MiddyDependenciesNodeModule" ]
        then
            npm i
            cd node_modules
        fi

        # now we have the folder to copy and the name from folder
        # let's erase folder if exists in /opt
        if [[ -d "/opt/$FOLDER_NAME" ]]
        then
            echo "erasing old layer in /opt/$FOLDER_NAME"
            rm -rf "/opt/$FOLDER_NAME/"
        fi

        # remove dependencies installed here, less things to move
        # rm -rf node_modules
        # copy folder to opt
        cp -R . "/opt/$FOLDER_NAME/"

        # let's install dependencies in your layer
        cd "/opt/$FOLDER_NAME/"

        if [ "$layer" != "MiddyDependenciesNodeModule" ]
        then
            npm i
        fi

        echo "-------------------------------------------------------------------------------------------"
        echo "  $layer installed  with success!!!!"
        echo "-------------------------------------------------------------------------------------------"
    else
        echo "-------------------------------------------------------------------------------------------"
        echo "  $layer don't need installation yet :) "
        echo "-------------------------------------------------------------------------------------------"
    fi

    # now go back to layers folder
    cd $ROOT_FOLDER_LAYERS/
done

# return to the project
cd $PATH_THIS_PROJECT

# now let's go run your test
# run serverless command
echo "run serverless"
serverless invoke local --f ${FUNCTION_NAME} ${PATH_SERVERLESS_PARAMETER}
