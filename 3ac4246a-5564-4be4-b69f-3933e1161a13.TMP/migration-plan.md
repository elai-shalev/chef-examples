# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL backend. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for migration is 3-4 weeks, with complexity rated as moderate due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled subdomains, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate management, fail2ban integration, UFW firewall rules, security headers

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Node attributes configuration for Chef Solo, contains site configurations and security settings
- `Vagrantfile`: Vagrant configuration for local development using Fedora 42
- `vagrant-provision.sh`: Provisioning script for Vagrant that installs Chef and runs the cookbooks

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or `ansible.builtin.package` module for installation and `ansible.builtin.template` for configuration
- **memcached (~> 6.0)**: Replace with Ansible `memcached` role or direct package installation and configuration
- **redisio (~> 7.2.4)**: Replace with Ansible `redis` role or direct package installation and configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible `community.crypto.openssl_*` modules for certificate management

### Security Considerations

- **SSL Certificate Management**: Use Ansible's `community.crypto.openssl_certificate`, `community.crypto.openssl_privatekey`, and related modules
- **Firewall Configuration (UFW)**: Use Ansible's `community.general.ufw` module to manage firewall rules
- **fail2ban Configuration**: Use Ansible's `community.general.fail2ban` module or direct configuration file management
- **SSH Hardening**: Use Ansible's `ansible.posix.sshd_config` module to manage SSH configuration
- **System Security Settings**: Use Ansible's `ansible.posix.sysctl` module for kernel parameter configuration
- **Redis Password**: Store Redis password in Ansible Vault and reference it in playbooks

### Technical Challenges

- **Multi-site Nginx Configuration**: The current Chef cookbook dynamically generates site configurations based on node attributes. Ansible will need to use templates with loops to achieve similar functionality.
- **SSL Certificate Generation**: Self-signed certificates are currently generated with OpenSSL commands. This will need to be replicated using Ansible's crypto modules.
- **Security Headers**: Nginx security headers are configured in templates. These will need to be carefully migrated to maintain the same security posture.
- **PostgreSQL User and Database Creation**: The current implementation uses direct SQL commands. This should be replaced with Ansible's PostgreSQL modules for better idempotence.

### Migration Order

1. **cache cookbook** (Low complexity): Start with the simplest cookbook that installs and configures Memcached and Redis
2. **nginx-multisite cookbook** (Medium complexity): Migrate the Nginx configuration, including SSL and security settings
3. **fastapi-tutorial cookbook** (Medium complexity): Migrate the FastAPI application deployment with PostgreSQL

### Assumptions

1. The target environment will continue to be Fedora 42 or a compatible Linux distribution
2. Self-signed certificates are acceptable for development/testing (production would likely use Let's Encrypt or other CA)
3. The same security posture needs to be maintained in the Ansible implementation
4. The FastAPI application source will continue to be pulled from the same Git repository
5. The Redis password in the current implementation is hardcoded and will need to be moved to Ansible Vault
6. The PostgreSQL credentials are hardcoded and will need to be moved to Ansible Vault
7. The current implementation assumes a single-server deployment model, which will be maintained in the Ansible version

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       ├── all.yml
│   │       └── webservers.yml
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
│           ├── all.yml
│           └── webservers.yml
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   └── fastapi-tutorial/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       ├── templates/
│       └── vars/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── ansible.cfg
└── Vagrantfile
```

## Detailed Migration Tasks

### 1. Nginx Multisite Role

1. Create Ansible templates for:
   - nginx.conf
   - site.conf (with SSL support)
   - security.conf
   - fail2ban configuration
   - sysctl security settings

2. Create tasks for:
   - Installing Nginx and security packages
   - Configuring firewall rules with UFW
   - Generating self-signed SSL certificates
   - Creating site configurations
   - Setting up security headers and hardening

### 2. Cache Role

1. Create tasks for:
   - Installing Memcached and Redis
   - Configuring Redis with password authentication
   - Setting up log directories
   - Enabling services

2. Create templates for:
   - Redis configuration

### 3. FastAPI Tutorial Role

1. Create tasks for:
   - Installing Python and system dependencies
   - Cloning the Git repository
   - Setting up Python virtual environment
   - Installing Python dependencies
   - Configuring PostgreSQL database and user
   - Creating environment configuration
   - Setting up systemd service

2. Create templates for:
   - Environment configuration file
   - Systemd service file

### 4. Ansible Vault Integration

1. Create vault files for storing:
   - Redis password
   - PostgreSQL credentials
   - Any other sensitive information

### 5. Testing and Validation

1. Create a Vagrant setup for testing the Ansible playbooks
2. Validate that all functionality matches the original Chef implementation
3. Verify security configurations are properly applied