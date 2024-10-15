#!/bin/bash

#rpc="https://allora-rpc.testnet.allora.network"
rpc="https://rpc.ankr.com/allora_testnet"

read -p "Enter your worker index: " index
read -p "Enter your mnemonic phrase: " mnemonic_phrase
read -p "Enter your upshot apikey: " upshot_apikey

mkdir worker-data-$index 
chmod -R 777 worker-data-$index

cat << EOF > .env
RPC=$rpc
UPSHOT_APIKEY="$upshot_apikey"
EOF


cat << EOF > docker-compose.yaml
services:
  custom-inference:
    build: .
    image: custom-inference
    container_name: custom-inference
    env_file: .env
    ports:
      - "8001:8000"

  custom-worker-$index:
    container_name: custom-worker-$index
    image: alloranetwork/allora-offchain-node:latest
    volumes:
      - ./worker-data-$index:/data
    depends_on:
      - custom-inference
    env_file:
      - ./worker-data-$index/env_file
EOF


cat << EOF > init.config
#!/bin/bash

set -e

if [ ! -f config.json ]; then
    echo "Error: config.json file not found, please provide one"
    exit 1
fi

nodeName=\$(jq -r '.wallet.addressKeyName' config.json)
if [ -z "\$nodeName" ]; then
    echo "No wallet name provided for the node, please provide your preferred wallet name. config.json >> wallet.addressKeyName"
    exit 1
fi

# Ensure the worker-data-$index directory exists
mkdir -p ./worker-data-$index

json_content=\$(cat ./config.json)
stringified_json=\$(echo "\$json_content" | jq -c .)

mnemonic=\$(jq -r '.wallet.addressRestoreMnemonic' config.json)
if [ -n "\$mnemonic" ]; then
    echo "ALLORA_OFFCHAIN_NODE_CONFIG_JSON='\$stringified_json'" > ./worker-data-$index/env_file
    echo "NAME=\$nodeName" >> ./worker-data-$index/env_file
    echo "ENV_LOADED=true" >> ./worker-data-$index/env_file
    
    echo "wallet mnemonic already provided by you, loading config.json . Please proceed to run docker compose"
    exit 1
fi

if [ ! -f ./worker-data-$index/env_file ]; then
    echo "ENV_LOADED=false" > ./worker-data-$index/env_file
fi

ENV_LOADED=\$(grep '^ENV_LOADED=' ./worker-data-$index/env_file | cut -d '=' -f 2)
if [ "\$ENV_LOADED" = "false" ]; then
    json_content=\$(cat ./config.json)
    stringified_json=\$(echo "\$json_content" | jq -c .)
    
    docker run -it --entrypoint=bash -v \$(pwd)/worker-data-$index:/data -v \$(pwd)/scripts:/scripts -e NAME=\${nodeName}" -e ALLORA_OFFCHAIN_NODE_CONFIG_JSON="\${stringified_json}" alloranetwork/allora-chain:latest -c "bash /scripts/init.sh"
    echo "config.json saved to ./worker-data-$index/env_file"
else
    echo "config.json is already loaded, skipping the operation. You can set ENV_LOADED variable to false in ./worker-data-$index/env_file to reload the config.json"
fi
EOF


cat <<EOF > config.json
{
    "wallet": {
        "addressKeyName": "test",
        "addressRestoreMnemonic": "$mnemonic_phrase",
        "alloraHomeDir": "",
        "gas": "1000000",
        "gasAdjustment": 1.0,
        "nodeRpc": "$rpc",
        "maxRetries": 1,
        "delay": 1,
        "submitTx": true
    },
    "worker": [
        {
            "topicId": 1,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 1,
            "parameters": {
                "InferenceEndpoint": "http://custom-inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 2,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 3,
            "parameters": {
                "InferenceEndpoint": "http://custom-inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 3,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://custom-inference:8000/inference/{Token}",
                "Token": "BTC"
            }
        },
        {
            "topicId": 4,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 2,
            "parameters": {
                "InferenceEndpoint": "http://custom-inference:8000/inference/{Token}",
                "Token": "BTC"
            }
        },
        {
            "topicId": 5,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 4,
            "parameters": {
                "InferenceEndpoint": "http://custom-inference:8000/inference/{Token}",
                "Token": "SOL"
            }
        },
        {
            "topicId": 6,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://custom-inference:8000/inference/{Token}",
                "Token": "SOL"
            }
        },
        {
            "topicId": 7,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 2,
            "parameters": {
                "InferenceEndpoint": "http://custom-inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 8,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 3,
            "parameters": {
                "InferenceEndpoint": "http://custom-inference:8000/inference/{Token}",
                "Token": "BNB"
            }
        },
        {
            "topicId": 9,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://custom-inference:8000/inference/{Token}",
                "Token": "ARB"
            }
        },
        {
            "topicId": 10,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://custom-inference:8000/inference/{Token}",
                "Token": "MEME"
            }
        },
        {
            "topicId": 11,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://custom-inference:8000/inference/{Token}",
                "Token": "ELECTION"
            }
        }
        
    ]
}
EOF

chmod +x init.config
./init.config 

# Run docker containers
docker-compose up -d
