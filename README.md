# micro-PKC (Personal Knowledge Container)
Author: FantasticoFox / 23. August 2021

Installation for Linux (Tested in Ubuntu 20.04) of your Personal Knowledge Container
This should work for other environments like Windows and Mac if the dependancies are fullfilled.

## Pre-Installation:

Resolving dependencies:
1. install git: sudo apt-get install git
2. install docker. Follow: https://docs.docker.com/engine/install/ubuntu/
3. 'git clone https://github.com/FantasticoFox/micro-PKC' to your computer.

## Installation:
1) Run the './setup.sh' with in the micro-pkc folder (outsite the docker container).<br>
2) Do 'docker-compose up -d' (to suppress massages) of micro-pkc<br>
3) Run the ./aqua/install_pkc.sh with in the micro-pkc docker container.<br>

Test if deployment was successful:
Go to localhost:9352 and see if you can open your 'Personal Knowledge Container'
If the special pags work, congratulations! You successfully deployed PKC!

Error Handling:
==> ERROR 1: You see the website but it tells you to setup mediawiki, you failed on step 3. Do docker-compose down and start over.
==> ERROR 2: You see the Personal-Knowledge-Container, you can login but the special pages on the left side (MediaWiki:Sidebar) do not load (invalid special page). If this error appears you failed to run the setup.sh before the docker-compose up. Do docker-compose down and start over. 


## POST Installation (installation of remote verification tools):
* You have the choice to use the commandline verification tool or the online-chrome extension (recommanded) to verify your page.
* Visit https://github.com/FantasticoFox/data-accounting-external-verifier for hte command line tool.
* Visit https://github.com/FantasticoFox/VerifyPage for the chrome extension.

Keep in mind that this software is in alpha-release stage. Please report bugs and issues back to us.
