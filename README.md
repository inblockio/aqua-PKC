# micro-PKC (Personal Knowledge Container)
Author: FantasticoFox / 23. August 2021

Installation for Linux (Tested in Ubuntu 20.04) of your Personal Knowledge Container\
This should work for other environments like Windows and Mac if the dependancies are fullfilled.

## Pre-Installation:

Resolving dependencies:
1. install git: sudo apt-get install git
2. install docker. Follow: https://docs.docker.com/engine/install/ubuntu/
3. `git clone https://github.com/FantasticoFox/micro-PKC`

## Installation:
1. `cd micro-PKC`
2. Run `./pkc setup --wallet-address <your wallet address>`

**Test if deployment was successful:**\
Go to localhost:9352 and see if you can open your 'Personal Knowledge Container'\
If the special pages work, congratulations! You successfully deployed PKC!

## POST Installation (installation of remote verification tools):
* You have the choice to use the commandline verification tool or the online-chrome extension (recommanded) to verify your page.
* Visit https://github.com/FantasticoFox/data-accounting-external-verifier for hte command line tool.
* Visit https://github.com/FantasticoFox/VerifyPage for the chrome extension.

Keep in mind that this software is in alpha-release stage. Please report bugs and issues back to us.
