# allora-worker

## Install requirements
```
sudo apt update && sudo apt upgrade -y
sudo apt install jq

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
docker version

# install docker-compose
VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

curl -L "https://github.com/docker/compose/releases/download/"$VER"/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
docker-compose --version
```


request some faucet from the [Allora Testnet Faucet](https://faucet.testnet-1.testnet.allora.network/) 


run the script and pass your mnemonic phrase to it
```
curl -LOs https://raw.githubusercontent.com/sarox0987/allora-worker/main/run.sh && bash ./run.sh
```
<img width="937" alt="Screenshot 2024-08-13 at 10 35 47 PM" src="https://github.com/user-attachments/assets/92ea736b-3323-480e-a1f2-560bc96e7ea8">

make sure all 3 containers are running with `docker ps`

<img width="1429" alt="Screenshot 2024-08-13 at 10 38 29 PM" src="https://github.com/user-attachments/assets/fe41f51b-95ac-40cf-a66d-5eca703ee184">


check the worker container with `docker logs -f worker` command, and make sure it registered for topics 1 and 2

<img width="1429" alt="Screenshot 2024-08-13 at 10 39 12 PM" src="https://github.com/user-attachments/assets/937029bf-3a47-4131-b493-6a7ef77eb72f">


