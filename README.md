# Docker Procedures

These are the procedures for running the Quorum website using docker. This file 
describes the steps necessary to get the system running from first principles. 


## Necessary Installs

The following software is needed to compile the whole stack:

1. Docker Desktop: https://www.docker.com/products/docker-desktop

## Clone Repositories

Three repositories need to be cloned. One is public, quorum-language, while the other two are private: quorum-support and quorum-server. All 3 must go in the same parent folder.



1. Quorum Server: https://github.com/qorf/quorum-server.git
    1. This contains all the docker related files and scripts
    2. docker-compose.yml is the main file, with one additional for PHP dependencies
    3. The env-dev file contains environment variables and must be renamed to .env for deployment or local servers.
2. Quorum Website: https://github.com/qorf/quorum-website.git

The website clone must be done within quorum-server, as the setup scripts in the compose file will attempt to build the website from this location.

## Quorum Website

1. Clone the quorum-server repository

2. Clone the quorum-website repository inside the quorum-server repository

3. Either change the .yml file to use the non-production version of the conf file or generate self-signed certificates and place them in the folder named "secret." One command for doing this is listed in Common Issues.

4. Use the terminal and go to the quorum-server location, then type docker-compose up. The -d may be used to run the server in daemon mode.


## Common Issues

### Unable to locate image?
Sometimes Docker was unable to find or load a specific image from docker hub. I'm not sure if this has anything to do with firewalls or dns issues, but I found removing the version tags to help.

For Example: Change `image: IMAGE:VERSION-TAG` to `image: IMAGE`

### Docker is no longer available in WSL 2
If you're on windows, and the script fails, it may not be able to connect to the background docker process. (Perhaps hanging or frozen in the background)

Try either rebooting or restarting the Docker Desktop app, hopefully that resolves the issue. 

Also, sometimes WSL 2 loses access to the windows file system, resulting in a broken terminal environment where almost nothing can be found suddenly. 
I could only resolve this by rebooting my machine. It's very frustrating and occurs randomly, not sure why it occurs though. 

### IDE Broken on the local webserver
The server requires your host machine ports to line up with the internal docker ports. Ideally in the future all networking would be handled within the docker image and containers. For now, make sure to have a nginx map ports `80:80` and `443:443`

### Docker build error: Unable to load metadata 
This issue seems to come and go for me and random machines, and am not totally sure how to prevent it yet. 
If you end up facing this as well, I suggest to try deleting Docker's Cached images.
`docker builder prune -a`

### docker-compose hangs on Droplet

If docker compose is hanging on a droplet, it might indicate there is not enough entropy. We can check this by running:

cat /proc/sys/kernel/random/entropy_avail

To fix this, we can install haveged. We can do this with this command:

apt-get install haveged

### How do I install my backup database for the Quorum server on my local machine

Get a copy of the schema or database, then run the following:

docker exec -i database mysql -uroot -psecret stefika_sodbeans_users < backup.sql

### How do I make self-signed certificates on my local machine for testing?

You can use the following command:

openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -nodes -days 365

This generates two files, key.pem and cert.pem, which are sufficiently for a self-signed certificate on a local machine. They go in the folder /secret.
