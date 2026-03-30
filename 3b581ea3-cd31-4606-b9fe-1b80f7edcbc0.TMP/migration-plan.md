# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will require converting three primary cookbooks with their dependencies, configuration templates, and custom resources. The estimated timeline for migration is 3-4 weeks, with complexity rated as moderate due to the custom Nginx configuration and security hardening requirements.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled subdomains, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, fail2ban integration, UFW firewall rules, security hardening

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Node attributes and run list for Chef Solo
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for local development using Fedora 42
- `vagrant-provision.sh`: Provisioning script for Chef installation and execution in Vagrant

### Target Details

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ based on cookbook metadata
- **Virtual Machine Technology**: Libvirt (based on Vagrant configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or `ansible.builtin.package` module with templates
- **memcached (~> 6.0)**: Replace with Ansible `community.general.memcached` module or custom role
- **redisio (~> 7.2.4)**: Replace with Ansible `community.general.redis` module or custom role
- **ssl_certificate (~> 2.1)**: Replace with Ansible `community.crypto.openssl_*` modules for certificate management

### Security Considerations

- **SSL Certificate Management**: Migration must preserve the self-signed certificate generation for development environments using Ansible's `community.crypto.openssl_certificate` module
- **Firewall Configuration**: UFW rules need to be migrated to Ansible's `community.general.ufw` module
- **fail2ban Integration**: Configuration needs to be migrated using Ansible's `community.general.fail2ban` module
- **SSH Hardening**: SSH configuration hardening (disabling root login, password authentication) should be implemented using Ansible's `ansible.posix.sshd_config` module
- **System Hardening**: Sysctl security settings should be migrated using Ansible's `ansible.posix.sysctl` module

### Technical Challenges

- **Custom Resource Migration**: The custom `lineinfile` resource in the nginx-multisite cookbook needs to be replaced with Ansible's `ansible.builtin.lineinfile` module
- **Template Conversion**: Multiple ERB templates need to be converted to Jinja2 format for Ansible
- **Multi-site Configuration**: The dynamic site configuration based on node attributes needs to be reimplemented using Ansible variables and loops
- **Redis Configuration Hack**: The Ruby block that modifies Redis configuration needs a clean implementation in Ansible
- **PostgreSQL User/Database Creation**: The direct execution of PostgreSQL commands needs to be replaced with Ansible's `community.postgresql` modules

### Migration Order

1. **nginx-multisite** (Priority 1): Core infrastructure component that other services depend on
   - Start with basic Nginx installation and configuration
   - Implement SSL certificate generation
   - Add security hardening features (fail2ban, firewall)
   - Configure multi-site setup

2. **cache** (Priority 2): Supporting services with moderate complexity
   - Implement Memcached configuration
   - Set up Redis with authentication
   - Configure log directories and service management

3. **fastapi-tutorial** (Priority 3): Application deployment with database dependencies
   - Set up PostgreSQL database and user
   - Deploy Python application from Git
   - Configure virtual environment and dependencies
   - Create systemd service

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential deployment to Ubuntu and CentOS as indicated in the cookbook metadata
2. Self-signed certificates are acceptable for development environments
3. The current security hardening approach (fail2ban, UFW, SSH hardening) should be maintained in the Ansible implementation
4. The FastAPI application source code will remain available at the specified Git repository
5. The multi-site configuration pattern with three sites (test, ci, status) will be preserved
6. Redis password ("redis_secure_password_123") should be replaced with a more secure method like Ansible Vault
7. PostgreSQL credentials ("fastapi"/"fastapi_password") should be secured using Ansible Vault
8. The current Vagrant-based development workflow should be preserved but updated for Ansible