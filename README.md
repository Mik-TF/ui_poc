<h1> Dashboard UI </h1>

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Make Commands](#make-commands)
	- [Local](#local)
	- [Micro VM](#micro-vm)
- [Deploy Locally](#deploy-locally)
- [Deploy Online](#deploy-online)
	- [DNS Name](#dns-name)
- [Deploy on TFGrid with Full VM](#deploy-on-tfgrid-with-full-vm)
	- [Troubleshooting](#troubleshooting)
- [Deploy on TFGrid with Micro VM](#deploy-on-tfgrid-with-micro-vm)
	- [Prepare the VM](#prepare-the-vm)
	- [Prepare Repo](#prepare-repo)
	- [Zinit](#zinit)
		- [Manage Caddy with zinit](#manage-caddy-with-zinit)
		- [Manage Webserver with zinit](#manage-webserver-with-zinit)
- [Notes](#notes)

---

## Introduction

This is a proof-of-concept of a basic Dashboard UI in Python using FastApi and HTMX.

## Prerequisites

- python3

## Make Commands

You can simply clone the repo and run the make command:

### Local

- Download the repo
	```
	git clone https://git.ourworld.tf/tfgrid/ui_poc
	cd ui_poc
	```
- Run locally on your machine.
	```
	make run
	```

This runs the `./scripts/microvm.sh` script.

### Micro VM

Run on a TFGrid micro VM with IPv4 address. Make sure to point a DNS A record of your (sub)domain to the IPv4 address of the VM

- From a fresh micro VM. Make sure to put your own domain.
	```
	apt update && apt install -y git make
	git clone https://git.ourworld.tf/tfgrid/ui_poc
	cd ui_poc
	make microvm domain="example.com"
	```

This runs the `./scripts/microvm.sh` script.

## Deploy Locally

You can use the following script to deploy the UI locally.

```
# Clone the repository
git clone https://git.ourworld.tf/tfgrid/ui_poc
# Go to app directory
cd ui_poc/app
# Clean Up if necessary
rm -rf venv
rm -rf __pycache__
# Set Python environment
python3 -m venv venv
source venv/bin/activate
# Install requirements
python3 -m pip install -r requirements.txt
# Deploy the local website at port 8000
uvicorn app:app --reload
```

## Deploy Online

You can deploy the webserver online with an IPv4 address. In this case make sure to set the DNS properly.

We show how to deploy online on both a micro and a full VM running on the TFGrid.

### DNS Name

Set a DNS A record of your domain URL pointing to the IPv4 address.


## Deploy on TFGrid with Full VM

You can deploy the website on the TFGrid. Follow those steps before following the local steps.

- Deploy Full VM Ubuntu 24.04 with IPv4 address and connect into it via SSH
- Prepare the environment
	```
	apt update && apt install -y git nano curl python3 python-is-python3 python3-venv python3-pip
	```
- Install Caddy
	```
	apt install -y debian-keyring debian-archive-keyring
	apt install -y apt-transport-https
	echo "deb [trusted=yes] https://releases.caddyserver.com/deb/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/caddy.list
	apt update
	apt install caddy
	```
- Enable and start caddy
	```
	systemctl enable caddy
	systemctl start caddy
	```
- Create caddyfile at 
	```
	nano /etc/caddy/Caddyfile
	```
- Caddyfile content
	```
	example.com {
		reverse_proxy 127.0.0.1:8000
	}
	```

### Troubleshooting

- Check the status
	```
	systemctl status caddy
	```
- Check the caddy log
	```
	journalctl -u caddy
	```

## Deploy on TFGrid with Micro VM

You can deploy the website on the TFGrid with a micro VM.

### Prepare the VM

- Deploy Micro VM Ubuntu 24.04 with IPv4 address and connect into it via SSH
- Prepare the environment
	```
	apt update && apt install -y git nano curl python3 python-is-python3 python3-venv python3-pip
	```
- Install Caddy
	```
	apt install -y debian-keyring debian-archive-keyring
	apt install -y apt-transport-https
	echo "deb [trusted=yes] https://releases.caddyserver.com/deb/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/caddy.list
	apt update
	apt install caddy
	```

### Prepare Repo

We clone the repository.

```
# Clone the repository
cd /root
git clone https://git.ourworld.tf/tfgrid/ui_poc
```

### Zinit

We manage Caddy and Uvicorn with Zinit.

#### Manage Caddy with zinit

We manage Caddy with zinit.

- Open the file for editing
    ```bash
    nano /etc/zinit/caddy.yaml
    ```
- Insert the following line with your own domain and save the file
    ```
    exec: caddy reverse-proxy --from example.com --to :8000
    ```
- Add the new Caddy file to zinit
    ```bash
    zinit monitor caddy
    ```

Zinit will start up Caddy immediately, restart it if it ever crashes, and start it up automatically after any reboots. Assuming you tested the Caddy invocation above and used the same form here, that should be all there is to it. 

Here are some other Zinit commands that could be helpful to troubleshoot issues:

- See status of all services (same as "zinit list")
    ```
    zinit
    ```
- Get logs for a service
    ```
    zinit log caddy
    ```
- Restart a service (to test configuration changes, for example)
    ```
    zinit stop caddy
    zinit start caddy
    ```
- To forget a zinit service
	```
	zinit forget caddy
	```

#### Manage Webserver with zinit

We manage the webserver (uvicorn) with zinit.

- Create a script in `/root/ui_poc/app`
	```
	#!/bin/bash

	cd /root/ui_poc/app
	rm -r venv
	rm -r __pycache__
	python3 -m venv venv
	source venv/bin/activate
	python3 -m pip install -r requirements.txt
	uvicorn main:app --reload
	```
- Make the script executable
	```
	chmod +x webserver.sh
	```
- Open the file for editing
    ```bash
    nano /etc/zinit/webserver.yaml
    ```
- Insert the following line with your own domain and save the file
    ```
    exec: bash /root/ui_poc/app/webserver.sh
    ```
- Add the new Webserver file to zinit
    ```bash
    zinit monitor webserver
    ```

## Notes

The .gitignore file is set with `venv` as the Python virtual environment.

