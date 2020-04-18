# docker-pihole-sync
A Docker Container To Sync Two Piholes. Currently 

Bugs:
Issue with permissions working properly. May require same user/account used for both docker instances

# A Fork 
From ShiromMakkad's awesome project. Customized to fit current example docker configuration from pihole.

## Introduction
A Pihole runs your entire network. If it goes down, your whole network goes down. If you have a family at home, they're going to be pretty annoyed that the wifi goes out everytime you want to do some maintainence. The only solution to this problem is to have a redundant pihole on your network, but you don't want to change your settings in two different places.

This repo allows you to synchronize between two piholes where one is the master and one is the slave. I'll be adding support for more piholes in future. Just update one pihole and the rest automatically update.

## Why Docker PiHole Sync

There are other options out there such as [pihole-cloudsync](https://github.com/stevejenkins/pihole-cloudsync) and [pihole-sync](https://github.com/simonwhitaker/pihole-sync), but this repo offers 4 unique features:

### 1. Docker Support
If you have a project based on docker, it doesn't make sense to have a single sync script running outside of docker. Your whole project should be started with docker-compose up and ended on docker-compose down (or a different command on swarm), and you can do that with this repo. Additionally, installing things like python or git inside a container is difficult because the container will be destroyed on shutdown. You could create volumes for the changed folders, but that's a hacky, difficult to maintain solution.  
### 2. Continuous Synchronization
The code will monitor the selected the folder for changes and immediately update the other Pihole. Great for updating the whitelist and seeing the website work immediately.
### 3. All Settings Are Transferred
Not only are your lists transferred, but all your other settings are transferred as well including your password, upstream DNS settings, etc.
### 4. Keeps Your Github Clean
Unlike [pihole-cloudsync](https://github.com/stevejenkins/pihole-cloudsync), we don't require a repository to sync to. This means that your Piholes don't have to connect to the internet, and you don't have a large number of commits going into a dummy repository. This is especially nice if you show private contributions on your profile and don't want a huge number of changes being published to your Github profile

#### NOTE: 
The master Pihole must be able to SSH into the slave Pihole. If that's a restriction (maybe your Piholes are behind different VPNs), use [pihole-cloudsync](https://github.com/stevejenkins/pihole-cloudsync). 

## Setup
### docker-compose.yml
```
version: "3"

services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp"
      - "80:80/tcp"
      - "443:443/tcp"
    environment:
      TZ: 'America/Chicago'
    # WEBPASSWORD: 'Password'
    # Volumes store your data between container upgrades
    volumes:
       - './etc-pihole/:/etc/pihole/'
       - './etc-dnsmasq.d/:/etc/dnsmasq.d/'
    dns:
      - 127.0.0.1
      - 1.1.1.1
      - 1.0.0.1
      - 1.1.1.2
      - 1.0.0.2
    # Recommended but not required (DHCP needs NET_ADMIN)
    #   https://github.com/pi-hole/docker-pi-hole#note-on-capabilities
#    cap_add:
#      - NET_ADMIN
    restart: unless-stopped
  pihole-sync:
    image: sondercoder/docker-pihole-sync
    container_name: pihole-sync
    volumes:
      - ~/.ssh:/root/.ssh/:ro
      - './etc-pihole/:/mnt/pihole/'
      - './etc-dnsmasq.d/:/mnt/dnsmasq.d/'
    environment:
      - CLIENTDIR1="pi@192.168.1.3:/home/pi/pihole/etc-pihole"
      - CLIENTDIR2="pi@192.168.1.3:/home/pi/pihole/etc-dnsmsq.d"

```
### Volumes
Volume | Function 
--- | -------- 
`/root/.ssh/:ro` | If your client directory is on a remote computer, you need the ssh keys to access it without a password. This directory stores them. Your keys are in ~/.ssh by default. See [this](https://www.tecmint.com/ssh-passwordless-login-using-ssh-keygen-in-5-easy-steps/) for a tutorial on SSH without a password. The directory is set to read-only in the container.
`/mnt/pihole` | This is the folder that is monitored and sychronized with the client directory. It should be set to the same as the /etc/pihole/ in the Pihole Docker container. See the compose file for details. 

### Environment Variables
Variable | Function
--- | --------
`CLIENTDIR` | This is the directory on the client that should be synced to. Assuming that the directory is remote, make sure that the client can be SSHed into without a password. See [this](https://www.tecmint.com/ssh-passwordless-login-using-ssh-keygen-in-5-easy-steps/) for a tutorial on SSH without a password. 

## Support Information
- Shell access while the container is running: `docker exec -it pihole-sync /bin/bash`
- Logs: `docker logs pihole-sync`

## Building Locally
If you want to make local modifications to this image for development purposes or just to customize the logic:
```
git clone https://github.com/ShiromMakkad/docker-pihole-sync.git
cd docker-pihole-sync
docker build -t shirom/docker-pihole-sync .
```
