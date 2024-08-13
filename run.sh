#!/bin/bash

# Get mnemonic phrase from user
read -p "Enter your mnemonic phrase: " mnemonic_phrase

# Clone the repository
git clone https://github.com/allora-network/basic-coin-prediction-node

# Change directory
cd basic-coin-prediction-node

# Write the JSON content to config.json
cat <<EOF > config.json
{
  "wallet": {
    "addressKeyName": "test",
    "addressRestoreMnemonic": "$mnemonic_phrase",
    "alloraHomeDir": "",
    "gas": "1000000",
    "gasAdjustment": 1.0,
    "nodeRpc": "https://sentries-rpc.testnet-1.testnet.allora.network/",
    "maxRetries": 1,
    "delay": 1,
    "submitTx": false
  },
  "worker": [
    {
      "topicId": 1,
      "inferenceEntrypointName": "api-worker-reputer",
      "loopSeconds": 5,
      "parameters": {
        "InferenceEndpoint": "http://inference:8000/inference/{Token}",
        "Token": "ETH"
      }
    },
    {
      "topicId": 2,
      "inferenceEntrypointName": "api-worker-reputer",
      "loopSeconds": 5,
      "parameters": {
        "InferenceEndpoint": "http://inference:8000/inference/{Token}",
        "Token": "ETH"
      }
    }
  ]
}
EOF

echo "Config file created with specified content."

mkdir worker-data
chmod +x init.config
./init.config 

# Run docker containers
docker-compose up -d
