# aqua-PKC (Personal Knowledge Container)
Author: inblockio / 23. August 2021

Installation for Linux (Tested in Ubuntu 20.04) of your Personal Knowledge Container (PKC)\
This should work for other environments like Windows and Mac if the requirements are met.

_Please read the this entire page before installing._

## Requirements

Hardware requirements: 
* x86_64 architecture with 
* 1 CPU 2.2 GHZ 
* 1 GB RAM 
* 8 GB SSD Harddrive (or more to store large media files)

Environment requirements:
1. Git [Git install](https://github.com/git-guides/install-git)
2. Docker [Docker Getting Started](https://docs.docker.com/get-started/)
    * for [Docker install for macOS](https://docs.docker.com/desktop/mac/install/)
    * for [Docker install for Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
    * for [Docker install for Windows](https://docs.docker.com/desktop/windows/install/), note: be sure you have [WSL 2 installed](https://docs.microsoft.com/en-us/windows/wsl/install) first.
3. Available ports at `8089` for Eauth and `9352` for MediaWiki. (`MEDIAWIKI_PORT` and `EAUTH_PORT` may be customized in the `.env` file)
4. Browser based Ethereum key manager (e.g.[MetaMask](https://metamask.io/))

## Installation

1. `git clone https://github.com/inblockio/aqua-PKC`
2. `cd aqua-PKC`
3. `./pkc setup --wallet-address <your ETH wallet address>`

If you want to install the PKC so that it is publicly accessible from the web:
1. Modify the A record for your domain to register the subdomains, e.g. `pkc.yourdomain.com` and `eauth.yourdomain.com`, to the public IP address of your server
2. Run `./pkc setup --web-public --wallet-address <your wallet address> --server <mediawiki.domain> --eauth-server <eauth.domain> --le-email <your@email.com>`

Other flags:
1. `./pkc setup --private` is setting the wiki into private mode by default. Except the main page all pages will not be visible to non-registered users.
2. `./pkc setup --empty-wiki` will not pre-populate the wiki from https://github.com/inblockio/PKC-Content which includes default pages for how to use the PKC and other helpful resources.
3. `./pkc nuke` is a command which deletes the mountpoint (the persistent data) and deletes the current instances of the docker containers.

**Test if deployment was successful:**\
Go to localhost:9352 and see if you can open your 'Personal Knowledge Container'\
If the special pages work, congratulations! You successfully deployed PKC!

## POST Installation (installation of remote verification tools)

* You have the choice to use the command line verification tool or the online-chrome extension (recommended) to verify your page.
* Visit https://github.com/inblockio/data-accounting-external-verifier for the command line tool.
* Visit https://github.com/inblockio/VerifyPage for the chrome extension.

Keep in mind that this software is in alpha-release stage. Please report bugs and issues back to us.

## Repository Dependencies Github

The following repositories are automatically installed by the `pkc` CLI during setup. 
- MediaWiki extension https://github.com/inblockio/DataAccounting
  This contains all scripts and information for the 'Verified Page History' implementation.
  languages: PHP, JavaScript, Shell
- Dockerized PKC https://github.com/inblockio/aqua-PKC
  For running the PKC MediaWiki including the DataAccounting extension via [Docker Compose](https://docs.docker.com/compose/).
  languages: Shell, PHP, JavaScript (and Docker of course)
- Content for population of a fresh installed pkc https://github.com/inblockio/PKC-Content
  This contains all the content which is pulled into the PKC through the create of an initial set of pages.
- Smart Contract for Witnessing / Timestamping https://github.com/inblockio/DataSymmetry
  This Smart Contract is part of the infrastructure required to interact with the Ethereum network for time-stamping 
  and 'proof of existence' of a set of verified page fields.  
- Backup-Script for PKC https://github.com/rht/MediaWiki_Backup.git 
  This repository includes all backup and restore logic for the dockerized-mediawiki
- To install the OAuth2 Client in MW https://github.com/rht/MW-OAuth2Client
  This is a modified fork which does no allow new user creation.

##  Repository Dependencies Github: Verification

These repositories need to be manually set up and installed. For more details visit each repository.
- CLI page verifier https://github.com/inblockio/data-accounting-external-verifier
  A CLI JavaScript client for verifying DataAccounting pages.
  languages: JavaScript
- Chrome extension https://github.com/inblockio/VerifyPage which wraps the CLI page verifier.
  This is used to remotely interface and verify with servers which integrate the verification protocol.
  languages: TypeScript, HTML

## Image Dependencies DockerHub

- Authentication server for Ethereum wallets via OAUTH2 pelith/node-eauth-server
- Custom build MediaWiki image based on the standard MediaWiki docker image fantasticofox/docker-aqua-mediawiki 
- A MariaDB database container as a database endpoint for the above services xlp0/mariadb

## Some Caveats
- If using "Crypto Wallets" feature of the Brave browser, MetaMask login will not function properly. To fix, disable "Crypto Wallets" extension in the Brave browser.
