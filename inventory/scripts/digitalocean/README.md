# Installing on Digitalocean

## Purpose
To make deploying a matrix server a little more automated on Digitalocean.

## Prerequisites
1. [Configure your DNS server](configuring-dns.md).
2. Create a floating IP.
3. Edit the `.env.do.example` file to contain your environment variables and remove the '.example' extension.

## Usage
Run `make install` from the parent/project directory to do the following:

- Create a droplet from either an Ubuntu image or a snapshot.
- Assign the floating IP to the created droplet.
- Using the Ansible playbook; setup, start and check the matrix instance on the droplet.
