#!/bin/bash

# Get mnemonic phrase from user
read -p "Enter your mnemonic phrase: " mnemonic_phrase

mkdir custom-allora
cd custom-allora
git clone https://github.com/allora-network/allora-huggingface-walkthrough.git
cd allora-huggingface-walkthrough
mkdir worker-data 
touch worker-data/env_file
chmod -R 777 worker-data
rm docker-compose.yaml

cat << EOF > docker-compose.yaml
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
    "wallet": {
        "addressKeyName": "test",
        "addressRestoreMnemonic": "$mnemonic_phrase",
        "alloraHomeDir": "",
        "gas": "1000000",
        "gasAdjustment": 1.0,
        "nodeRpc": "https://allora-rpc.testnet-1.testnet.allora.network/",
        "maxRetries": 1,
        "delay": 1,
        "submitTx": false
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
        }
        
    ]
}
EOF

chmod +x init.config
./init.config 

# Run docker containers
docker-compose up -d
