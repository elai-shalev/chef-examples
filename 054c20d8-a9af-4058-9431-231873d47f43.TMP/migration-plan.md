# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security hardening settings. Based on the complexity and scope, this migration is estimated to require 3-4 weeks with 1-2 engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Multi-site Nginx configuration with SSL/TLS support, security hardening, and virtual host management
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multiple virtual hosts with SSL, security hardening (fail2ban, UFW firewall), self-signed certificate generation

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git-based deployment, Python virtual environment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Chef policy file defining run list and cookbook versions - will be replaced by Ansible playbooks
- `solo.json`: Chef node attributes and run list - will be replaced by Ansible inventory variables
- `solo.rb`: Chef configuration - will be replaced by Ansible configuration
- `Vagrantfile`: VM configuration for development/testing - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script for Vagrant - will be replaced by Ansible provisioning

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or direct package installation
- **ssl_certificate (~> 2.1)**: Replace with Ansible `openssl_*` modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible `memcached` role or direct package configuration
- **redisio (~> 7.2.4)**: Replace with Ansible `redis` role or direct package configuration

### Security Considerations

- **SSL/TLS Configuration**: Migrate certificate generation and configuration, ensuring proper file permissions
  - Migration approach: Use Ansible `openssl_*` modules for certificate generation and management
- **Firewall (UFW)**: Migrate firewall rules and default policies
  - Migration approach: Use Ansible `ufw` module to configure firewall rules
- **fail2ban**: Migrate jail configuration for brute force protection
  - Migration approach: Use Ansible `template` module to deploy fail2ban configuration
- **SSH Hardening**: Migrate SSH security settings (disable root login, password authentication)
  - Migration approach: Use Ansible `lineinfile` or dedicated SSH role
- **Sysctl Security**: Migrate kernel parameter hardening
  - Migration approach: Use Ansible `sysctl` module

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations based on node attributes will need careful translation to Ansible variables and templates
  - Mitigation: Create a structured variable hierarchy in Ansible inventory or group_vars
- **Redis Configuration Hack**: The Chef cookbook includes a hack to modify Redis configuration files after deployment
  - Mitigation: Create a proper Ansible template for Redis configuration instead of post-deployment modification
- **Service Dependencies**: Ensuring proper ordering of service deployments (e.g., PostgreSQL before FastAPI)
  - Mitigation: Use Ansible handlers and explicit dependencies between tasks

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Base Nginx installation and configuration
   - SSL/TLS certificate generation
   - Virtual host configuration
   - Security hardening (fail2ban, UFW, sysctl)

2. **cache** (low complexity, independent service)
   - Memcached installation and configuration
   - Redis installation and configuration with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - PostgreSQL installation and database setup
   - Python environment setup
   - Application deployment from Git
   - Systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. Self-signed certificates are acceptable for development/testing (production would likely use Let's Encrypt or other CA)
3. The security hardening requirements will remain the same in the Ansible implementation
4. The Redis password ("redis_secure_password_123") will be managed securely in Ansible Vault
5. The PostgreSQL credentials ("fastapi"/"fastapi_password") will be managed securely in Ansible Vault
6. The directory structure for web content (/var/www/[site]) will remain the same
7. The SSL certificate paths (/etc/ssl/certs and /etc/ssl/private) will remain the same
8. The FastAPI application will continue to be deployed from the same Git repository