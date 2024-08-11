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

and to avoid errors with permissions, after cloning repository use:
```
sudo chmod +x 5G_docker_open5gs/* & sudo chmod +x 5G_docker_open5gs/*/*
```

You can skip "sudo" in commands if you add your user to the Docker group:
```
sudo usermod -aG docker $USER
```
After adding the user, reboot your system.

#### Clone repository and build a docker image of open5gs and ueransim

```
git clone https://github.com/jpasierbb/5G_docker_open5gs.git
sudo chmod +x 5G_docker_open5gs/* & sudo chmod +x 5G_docker_open5gs/*/*
cd 5G_docker_open5gs/base
sudo docker build --no-cache --force-rm -t docker_open5gs .

cd ../ueransim
sudo docker build --no-cache --force-rm -t docker_ueransim .
```

#### Build and Run using docker-compose

```
cd ..
set -a
source .env
sudo docker-compose -f 5g_isolation.yaml build
sudo sysctl -w net.ipv4.ip_forward=1
```

## 5G SA deployment

```
# 5G Core Network
sudo docker-compose -f 5g_isolation.yaml up

# UERANSIM gNB
sudo docker-compose -f nr-gnb.yaml up -d && docker container attach nr_gnb

# UERANSIM NR-UE
sudo docker-compose -f nr-ue.yaml up -d && docker container attach nr_ue
```

## Configuration

After running your 5G core network, you need to modify iptables rules for DOCKER-USER chain.
To do that, use commands below:

```
sudo iptables -I DOCKER-USER -i br-########1 -o br-########2 -j ACCEPT
sudo iptables -I DOCKER-USER -i br-########2 -o br-########1 -j ACCEPT
```

where br-########1 and br-########2 are bridges created by docker and, you can check their names, for instance using ```ip a```.

To simplify this process, there are 2 bash scripts: 5g_iptables_config.sh and 5g_iptables_clear.sh.
The first one finds two newest created bridges in the system and modifies iptables.
The second one clears added rules to the iptables Docker Chain.

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

# Monitoring metrics:

The project implements Prometheus and Grafana. Prometheus is used to monitor metrics (the current Open5GS version supports monitoring of AMF, SMF, PCF and UPF)
and Grafana is used to create visualizations.

## Prometheus:

Prometheus is available at http://localhost:9090. You can specify the component you are interested in and monitor it there.
Alternatively, you can go to http://localhost:9090/metrics to find metrics from every single component.

## Grafana:

Grafana is available at http://localhost:3030 with standard credentials:
```
login: admin
password: admin
```
After logging in, you can create visualizations based on Prometheus metrics.

## Not supported
- IPv6 usage in Docker
