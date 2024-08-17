#!/bin/bash

# Get mnemonic phrase from user
read -p "Enter your mnemonic phrase: " mnemonic_phrase

mkdir custom-allora
cd custom-allora
mkdir worker-data
touch worker-data/env-file
chmod -R 777 worker-data

cat << EOF > docker-compose.yml
services:
  custom-inference:
    image: 0xsarox/inference-allora
    container_name: custom-inference
    ports:
      - "8001:8000"

  custom-worker:
    container_name: custom-worker
    image: alloranetwork/allora-offchain-node:latest
    volumes:
      - ./worker-data:/data
    depends_on:
      - custom-inference
    env_file:
      - ./worker-data/env_file
  
volumes:
  inference-data:
  worker-data:
EOF


cat <<EOF > config.json
{
  "wallet": [
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
        }
        
    ]
}
EOF

cat <<EOF > init.config
#!/bin/bash

set -e

if [ ! -f config.json ]; then
    echo "Error: config.json file not found, please provide one"
    exit 1
fi

nodeName=$(jq -r '.wallet.addressKeyName' config.json)
if [ -z "$nodeName" ]; then
    echo "No wallet name provided for the node, please provide your preferred wallet name. config.json >> wallet.addressKeyName"
    exit 1
fi

# Ensure the worker-data directory exists
mkdir -p ./worker-data

json_content=$(cat ./config.json)
stringified_json=$(echo "$json_content" | jq -c .)

mnemonic=$(jq -r '.wallet.addressRestoreMnemonic' config.json)
if [ -n "$mnemonic" ]; then
    echo "ALLORA_OFFCHAIN_NODE_CONFIG_JSON='$stringified_json'" > ./worker-data/env_file
    echo "NAME=$nodeName" >> ./worker-data/env_file
    echo "ENV_LOADED=true" >> ./worker-data/env_file
    
    echo "wallet mnemonic already provided by you, loading config.json . Please proceed to run docker compose"
    exit 1
fi

if [ ! -f ./worker-data/env_file ]; then
    echo "ENV_LOADED=false" > ./worker-data/env_file
fi

ENV_LOADED=$(grep '^ENV_LOADED=' ./worker-data/env_file | cut -d '=' -f 2)
if [ "$ENV_LOADED" = "false" ]; then
    json_content=$(cat ./config.json)
    stringified_json=$(echo "$json_content" | jq -c .)
    
    docker run -it --entrypoint=bash -v $(pwd)/worker-data:/data -v $(pwd)/scripts:/scripts -e NAME="${nodeName}" -e ALLORA_OFFCHAIN_NODE_CONFIG_JSON="${stringified_json}" alloranetwork/allora-chain:latest -c "bash /scripts/init.sh"
    echo "config.json saved to ./worker-data/env_file"
else
    echo "config.json is already loaded, skipping the operation. You can set ENV_LOADED variable to false in ./worker-data/env_file to reload the config.json"

EOF

chmod +x init.config
./init.config 

# Run docker containers
docker-compose up -d
