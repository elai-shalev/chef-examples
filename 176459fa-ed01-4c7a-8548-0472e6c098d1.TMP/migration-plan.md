# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup that needs to be migrated to Ansible. The repository primarily consists of three Chef cookbooks that manage a multi-site Nginx web server setup with caching services (Redis and Memcached) and a FastAPI Python application with PostgreSQL. The migration complexity is moderate, with an estimated timeline of 3-4 weeks for complete migration, including testing and documentation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, UFW), sysctl security settings

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Manages cookbook dependencies - will be replaced by Ansible Galaxy requirements file
- `Policyfile.rb`: Defines the Chef policy with run list - will be replaced by Ansible playbook structure
- `solo.json`: Contains node configuration data - will be migrated to Ansible inventory variables
- `Vagrantfile`: Defines the development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisions the Vagrant VM with Chef - will be replaced with Ansible provisioning
- `solo.rb`: Chef Solo configuration - not needed in Ansible

### Target Details

Based on the source configuration files:

- **Operating System**: Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata support declarations)
- **Virtual Machine Technology**: VirtualBox (inferred from Vagrant usage)
- **Cloud Platform**: Not specified in the repository, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or nginx_core module
- **memcached (~> 6.0)**: Replace with Ansible memcached role or memcached module
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or redis module
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **SSL Certificate Management**: Migrate self-signed certificate generation to Ansible's openssl_certificate module
- **Firewall Configuration (UFW)**: Use Ansible's ufw module to manage firewall rules
- **fail2ban Configuration**: Create Ansible tasks to install and configure fail2ban
- **SSH Hardening**: Use Ansible to manage SSH configuration (disable root login, password authentication)
- **sysctl Security Settings**: Use Ansible's sysctl module to apply kernel parameter security settings
- **Redis Password**: Store Redis password in Ansible Vault instead of plaintext in recipes

### Technical Challenges

- **Multi-site Nginx Configuration**: Create a flexible Ansible role that can handle multiple virtual hosts with SSL
- **Template Migration**: Convert ERB templates to Jinja2 format for Ansible
- **Service Dependencies**: Ensure proper ordering of service installations and configurations
- **PostgreSQL User/DB Creation**: Use Ansible's postgresql_* modules instead of direct SQL commands
- **Python Environment Management**: Use Ansible's pip module for managing Python virtual environments

### Migration Order

1. **Base Infrastructure** (low complexity)
   - Convert Vagrant setup to use Ansible provisioner
   - Create basic inventory structure

2. **nginx-multisite Cookbook** (moderate complexity)
   - Create Ansible role for Nginx installation and configuration
   - Implement SSL certificate generation
   - Configure virtual hosts
   - Implement security hardening

3. **cache Cookbook** (moderate complexity)
   - Create Ansible roles for Memcached and Redis
   - Implement Redis authentication with Ansible Vault for password storage

4. **fastapi-tutorial Cookbook** (high complexity)
   - Create Ansible role for PostgreSQL installation and configuration
   - Implement Python application deployment
   - Configure systemd service

### Assumptions

1. The current Chef setup is functional and represents the desired end state
2. No major architectural changes are required during migration
3. The target environment will remain similar (Ubuntu/CentOS)
4. Self-signed certificates are acceptable for development/testing
5. No CI/CD pipeline integration is required as part of the migration
6. The FastAPI application source will continue to be pulled from the same Git repository
7. Redis and Memcached configurations will remain similar
8. Security requirements will remain the same (fail2ban, UFW, SSH hardening)