# Docker Procedures

These are the procedures for running the Quorum website, using docker, in the new system for Quorum-10. This file describes the steps necessary to get the system running from first principles. 


## Necessary Installs

The following software is needed to compile the whole stack:



1. Docker Desktop: https://www.docker.com/products/docker-desktop
2. Download Quorum Studio 3.0.1: https://quorumlanguage.com/download.html


## Clone Repositories

Three repositories need to be cloned. One is public, quorum-language, while the other two are private: quorum-support and quorum-server. All 3 must go in the same parent folder.



1. Quorum Server: https://bitbucket.org/stefika/quorum-server/src/master/
    1. This contains all the docker related files and scripts
    2. docker-compose.yml is the main file, with one additional for PHP dependencies
    3. The scripts folder contains helper scripts
2. Quorum Language: https://bitbucket.org/stefika/quorum-language/src/master/
3. Quorum-Support: https://bitbucket.org/stefika/quorum-support/src/master/


## Compile Projects

Now that we have the repositories, they need to be compiled.


## Compile Quorum-10

The main programming language requires the latest version, which is kind of like replacing the JDK in Java and bootstrapping itself. This is only partially automated so far. Instructions Follow

First get the Quorum 10 branch:


    git checkout Quorum-10

When Quorum is first downloaded, it uses the current version of the programming language, which is Quorum 9. To use the full system with Docker, we need Quorum 10. But, to build the Quorum 10 branch, we also need Quorum 10, which doesn't yet exist on our newly cloned system. We thus need to "bootstrap" the process with Quorum 9 with Quorum 10's features temporarily excluded. To do this, we:



1. Open the Quorum project under Quorum/Project/Project.qp from Quorum Studio. 
2. Open Quorum/Source Code/CompilerTestSuite.quorum
3. Comment out several lines of code so the system will compile in Quorum 9:
    1. lines 18 - 20, 
    2. The end of line 23,  is ProcessListener
    3. Lines 457 - 482
    4. Lines 488 - 506
4. Set "RunLibrary.quorum" as the main file from the context menu and run the project (CTRL + R). It is normal for it to take 30 seconds to a few minutes to generate the standard library, depending on the machine.

This bootstraps the compiler and the standard library and prepares it for use as the back-end. We now need to close Quorum Studio and tell it we want it to use the newly created Quorum 10 standard library. Because Quorum 10 is not public yet, this is a bit complicated:



5. Close Quorum Studio
6. Open the Quorum Studio Configuration file, which on windows is under %appdata%/QuorumStudio/Options.json.  
7. Change the "**Override Standard Library**": false to true
8. change "**Library**" to where you regenerated Quorum 10. On my system this is: "/Users/stefika/Repositories/quorum-language/Quorum/Library",
9. Start Quorum Studio again. If done correctly, it will open normally. If it never opens, the path is probably incorrect, so either fix that or make sure the library really did generate.
10. Uncomment the same lines or leave them. It doesn't actually matter for Docker. 
11. Set "Main.quorum" as the main file and **importantly** do a **Clean** and **Build**. This tells Quorum Studio to force inject the new platform behind the scenes and only needs to be done once after any update to the standard library. 
12. Close the Quorum project if you want. The Quorum 10 compiler is ready for use in Docker.


## Quorum Website

Compiling the Quorum website is much easier and only needs Quorum 9, but under Quorum 10 is ok too, so there is no need to revert. Essentially, we open the project and run it. The project is large and a bit slow, so it can take a few seconds to generate the website. Steps follow:



1. Switch to the Docker branch

git checkout Docker



2. Compile the Quorum Website project
    1. Open the quorum-support/QuorumWebsite project folder like before. 
    2. Run the project
    3. Close the project


## Run Docker

Now that we have the main Quorum projects compiled, we need to run a setup script and then use docker-compose:



1. Copy the default dev environment file from env-dev to .env and change it appropriately for any custom passwords or settings on the local or deployment machine.
2. Run scripts/FirstRun.sh. This script runs let's encrypt, then copies the compiler, which then auto-generates a bunch of content related to the website. It also moves any information from the standard library to the correct location in the dockerized website.
3. Docker compose up is run automatically by FirstRun.sh, but past this only docker-compose up is necessary.

If the website needs to be regenerated, we can run scripts/setup.sh and this will re-gather all dependencies and place them in the right spot. Docker needs to be shut down during this process because it regenerates API documentation on the fly and other automated stuff. Also note that this approach does **not** generate the database, so the login system will not work. We cannot share these files, other than the schema, without a mountain of paperwork.


## Known Issues

Known Automation Issues:



1. Ideally, we would automate compiler bootstrapping, but because Quorum-10 is not out and we are actively developing different versions of it on different branches, this is a bit complicated
2. The website generation could be automated pretty easily, but we haven't bothered
3. Hypothetically, we could have the docker scripts download everything from git or update if it has the repos already, but we haven't done that either.

Known bugs:



1. PHP's mail function is not working. Further, we aren't sure what we "should" do with them on docker, as the old system ran through the university.
2. Quorum's embed scripts are intentionally tied to localhost, not quorumlanguage.com because they don't exist on live. The reason is because the compiler on live is Quorum 6 and it uses a completely different compiler stack compared to Quorum-10.
3. We have not tried Let's encrypt on the last mile, so we aren't sure if it is all setup correctly
4. We don't know how to manage the last mile with cloud-flare, digital ocean, or whatever else
5. We have done our best to remove potential security issues, but are not experts in this, so we may have security vulnerabilities of which we are unaware.
6. Sina Bahram is secretly a monkey. This isn't so much a bug, but a feature.

----

## Common Issues

### Missing Certificates?
If nginx is unable to launch, the certificates may not have been created properly. 
Check to see if there is a directory for `quorumlanguage.com` in `./data/certbot/conf/live/`
There should be two files: 
- fullchain.pem
- privkey.pem

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
