# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting 3 Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks. Based on the complexity and scope, this migration is estimated to require 3-4 weeks with 1-2 dedicated DevOps engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup with self-signed certificates, security headers, fail2ban integration, UFW firewall rules

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git-based deployment, Python virtual environment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy configuration - will be replaced by Ansible playbook structure
- `solo.json`: Node configuration for Chef Solo - will be replaced by Ansible inventory and group_vars
- `solo.rb`: Chef Solo configuration - will be replaced by ansible.cfg
- `Vagrantfile`: Development environment configuration - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script for Vagrant - will be replaced by Ansible provisioning in Vagrantfile

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.nginx collection or direct package installation
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (openssl_certificate, openssl_privatekey)
- **memcached (~> 6.0)**: Replace with Ansible community.general.memcached module
- **redisio (~> 7.2.4)**: Replace with Ansible community.redis collection

### Security Considerations

- **SSL/TLS Configuration**: 
  - Self-signed certificates generation needs to be migrated using Ansible's openssl modules
  - Certificate and key paths need to be maintained (/etc/ssl/certs and /etc/ssl/private)
  - TLS protocols and ciphers configuration should be preserved

- **Firewall Configuration**: 
  - UFW rules need to be migrated to Ansible's community.general.ufw module
  - Current rules allow SSH, HTTP, and HTTPS

- **Fail2ban Integration**:
  - Fail2ban configuration needs to be migrated using Ansible's community.general.fail2ban module

- **SSH Hardening**:
  - SSH configuration disables root login and password authentication
  - Migration should use Ansible's openssh_config module

- **Vault/secrets management**:
  - Redis password ("redis_secure_password_123") in cache cookbook
  - PostgreSQL database credentials ("fastapi"/"fastapi_password") in fastapi-tutorial cookbook
  - These should be migrated to Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: 
  - The dynamic generation of multiple virtual hosts based on node attributes needs careful translation to Ansible templates and variables
  - SSL certificate generation for each site needs to be properly sequenced

- **Redis Configuration Hack**: 
  - The Chef cookbook includes a ruby_block to modify Redis configuration files after they're created
  - This will need a custom approach in Ansible, possibly using lineinfile or template modules

- **PostgreSQL User and Database Creation**:
  - The current implementation uses direct shell commands via execute resources
  - Should be migrated to Ansible's postgresql_user and postgresql_db modules for idempotency

- **Python Application Deployment**:
  - The virtual environment and dependency installation process needs to be carefully migrated
  - Environment file creation and systemd service setup need to maintain the same configuration

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Start with basic Nginx installation and configuration
   - Add SSL certificate generation
   - Implement virtual hosts configuration
   - Add security hardening (fail2ban, firewall, headers)

2. **cache** (low complexity, independent service)
   - Implement Memcached configuration
   - Add Redis installation and configuration with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Set up PostgreSQL installation and configuration
   - Implement Python environment setup
   - Configure application deployment from Git
   - Set up systemd service

### Assumptions

1. The target environment will continue to use Fedora 42 or a compatible Linux distribution
2. The same directory structure will be maintained for document roots (/opt/server/test, /opt/server/ci, /opt/server/status)
3. Self-signed certificates are acceptable for the migrated solution (not using Let's Encrypt or other CA)
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The current security configurations (fail2ban, UFW, SSH hardening) are appropriate for the target environment
6. The Redis and PostgreSQL passwords in the code are development credentials and will be replaced with proper secrets management
7. The Vagrant development environment will be maintained but converted to use Ansible provisioning