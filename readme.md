Below is a detailed guide on how to run Docker Compose using Docker Swarm followed by instructions on using the provided Makefile:

### 1. Running Docker Compose with Docker Swarm

#### Step 1: Initialize Docker Swarm (if not already done)
If you have not initialized Docker Swarm, you need to do this first by running the following command on your Docker manager node:
```bash
docker swarm init
```

#### Step 2: Create an Overlay Network
To allow services within the swarm to communicate with each other, you need to create an overlay network:
```bash
docker network create --driver overlay --attachable proxy-network
```

#### Step 3: Deploy the Stack
Save your `docker-compose.yml` file and use the following command to deploy the stack:
```bash
docker stack deploy -c docker-compose.yml my-stack
```
Replace `my-stack` with the name you wish to give to your stack.

### 2. Using the Makefile

#### Setup
The Makefile is designed to manage configurations and certificates for Nginx and Certbot. Ensure that you have `make` installed on your system.

#### Usage Instructions

**Add Domain and Configure SSL**
```bash
make add-domain DOMAIN=example.com
```
Replace `example.com` with the domain name you want to configure. This command will execute the `add-domain.sh` script to add the domain and configure SSL for it.

**Reload Nginx**
```bash
make reload-nginx
```
Use this command to apply configuration changes without needing to restart the entire service.

**Test Nginx Configuration**
```bash
make test-config
```
Before reloading Nginx, ensure your configuration is error-free by using this command.

### 3. View Help

To see available commands:
```bash
make help
```

### Notes
- Ensure all paths and configurations in `docker-compose.yml` and `Makefile` are accurate and meet the requirements of your system setup.
- Before executing any `make` commands, check the paths and access permissions to avoid any unwanted errors.

With this guide, you should be able to efficiently manage configurations and SSL certificates for Nginx and Certbot in an automated manner.