# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, security configurations, and service orchestration.

**Scope**: 3 Chef cookbooks with external dependencies
**Complexity**: Medium
**Estimated Timeline**: 3-4 weeks

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw)

- **cache**:
    - Description: Configures Redis and Memcached caching services with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment, Git repository deployment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file listing cookbook dependencies (nginx, memcached, redisio, ssl_certificate)
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo with site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding
- `vagrant-provision.sh`: Bash script for provisioning the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile configuration)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified (appears to be designed for on-premises or generic cloud deployment)

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role (e.g., geerlingguy.nginx)
- **memcached (~> 6.0)**: Replace with Ansible memcached role (e.g., geerlingguy.memcached)
- **redisio (~> 7.2.4)**: Replace with Ansible redis role (e.g., geerlingguy.redis)
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl_* modules for certificate management

### Security Considerations

- **fail2ban configuration**: Migrate using Ansible's package and template modules
- **ufw firewall rules**: Replace with Ansible's ufw module
- **SSH hardening**: Use Ansible's lineinfile or template module for sshd_config
- **Redis password**: Use Ansible Vault for storing the Redis password securely
- **PostgreSQL credentials**: Use Ansible Vault for database credentials

### Technical Challenges

- **Multi-site Nginx configuration**: Ensure proper templating of virtual host configurations with SSL support
- **Self-signed certificate generation**: Implement using Ansible's openssl_* modules
- **Redis configuration hacks**: The Chef recipe contains a hack to modify Redis config files; ensure proper configuration in Ansible
- **FastAPI deployment**: Ensure proper Python virtual environment setup and systemd service configuration

### Migration Order

1. **nginx-multisite** (foundation for web services)
   - Base Nginx installation
   - SSL certificate generation
   - Virtual host configuration
   - Security hardening

2. **cache** (supporting services)
   - Memcached configuration
   - Redis installation and configuration

3. **fastapi-tutorial** (application layer)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment
   - Service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems (specifically Fedora 42 as indicated in the Vagrantfile)
2. Self-signed certificates are acceptable for development/testing (production would likely use Let's Encrypt or other CA)
3. The security requirements (fail2ban, ufw, SSH hardening) will remain the same
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The Redis password "redis_secure_password_123" is a development password and should be replaced with a secure password in production
6. PostgreSQL credentials ("fastapi"/"fastapi_password") are development credentials and should be replaced with secure credentials in production
7. The current Chef implementation doesn't include backup or monitoring solutions, which might be needed in the Ansible implementation
8. The current implementation assumes a single-server deployment model