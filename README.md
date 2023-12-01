# 5G Docker Emulation System with isolated NRF
This repository contains docker files to deploy a RF simulated 5G network using following projects:
- Core Network (5G) - open5gs - https://github.com/open5gs/open5gs
- UERANSIM (5G) - https://github.com/aligungr/UERANSIM

Work based on:
https://github.com/herlesupreeth/docker_open5gs

Everything was tested using VM with Linux Ubuntu 22.04 LTS.

## Requirements
To build and run this containerized enviroment, you will need:
	* docker engine
	* docker-compose

Moreover, too observe network traffic i highly recommend using:
  * Wireshark
  * [EdgeShark] (https://github.com/siemens/edgeshark)

Before you start building images, I highly recommand install some packages, to avoid any problems:

```
sudo apt install npm git docker.io docker-compose wireshark -y
```

and to avoid errors with permissions, use:
```
sudo chmod +x 5G_docker_open5gs/* & sudo chmod +x 5G_docker_open5gs/*/*
```
after cloning repository

#### Clone repository and build a docker image of open5gs and ueransim

```
git clone https://github.com/jpasierbb/5G_docker_open5gs.git
sudo chmod +x 5G_docker_open5gs/* & sudo chmod +x 5G_docker_open5gs/*/*
cd 5G_docker_open5gs/base
docker build --no-cache --force-rm -t docker_open5gs .

cd ../ueransim
docker build --no-cache --force-rm -t docker_ueransim .
```

#### Build and Run using docker-compose

```
cd ..
set -a
source .env
docker-compose -f sa-deploy.yaml build
sudo sysctl -w net.ipv4.ip_forward=1
```

## 5G SA deployment

```
# 5G Core Network
docker-compose -f 5g_isolation.yaml up

# UERANSIM gNB (RF simulated)
docker-compose -f nr-gnb.yaml up -d && docker container attach nr_gnb

# UERANSIM NR-UE (RF simulated)
docker-compose -f nr-ue.yaml up -d && docker container attach nr_ue
```

## Configuration

After running your 5G core network, you need to modify iptables rules for DOCKER-USER chain.
To do that, use commands below:

```
sudo iptables -I DOCKER-USER -i br-########1 -o br-########2 -j ACCEPT
sudo iptables -I DOCKER-USER -i br-########2 -o br-########1 -j ACCEPT
```

where br-########1 and br-########2 are bridges created by docker and, you can check their names, for instance using ```ip a```.

# Provisioning of SIM information

## Provisioning of SIM information in open5gs HSS as follows:

Open (http://<DOCKER_HOST_IP>:3000) in a web browser, where <DOCKER_HOST_IP> is the IP of the machine/VM running the open5gs containers. Login with following credentials
```
Username : admin
Password : 1423
```
Then, add a subscriber using following information:
```
IMSI=001011234567895
KI=8baf473f2f8fd09487cccbd7097c6862
OP=11111111111111111111111111111111
AMF=8000
```

## Not supported
- IPv6 usage in Docker
