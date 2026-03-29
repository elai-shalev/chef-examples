# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Memcached and Redis) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, security configurations, and service deployments. Based on the complexity and scope, this migration is estimated to be of medium complexity and should take approximately 3-4 weeks to complete with 1-2 dedicated engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled subdomains, security hardening, and site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw, sysctl), site-specific document roots

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Memcached configuration, Redis with password authentication, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy definition - will be replaced by Ansible playbook structure
- `solo.json`: Node configuration for Chef Solo - will be replaced by Ansible inventory and group_vars
- `solo.rb`: Chef Solo configuration - will be replaced by ansible.cfg
- `Vagrantfile`: Development environment definition - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script for Vagrant - will be replaced by Ansible provisioning

### Target Details

Based on the source repository analysis:

- **Operating System**: The configuration supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) as indicated in cookbook metadata files. The Vagrantfile uses Fedora 42 for development.
- **Virtual Machine Technology**: Vagrant with libvirt provider is used for development environments.
- **Cloud Platform**: No specific cloud platform configurations were identified. The setup appears to be designed for on-premises or generic cloud VMs.

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role from Galaxy or create custom role using nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible memcached role from Galaxy or create custom role
- **redisio (~> 7.2.4)**: Replace with Ansible redis role from Galaxy or create custom role

### Security Considerations

- **fail2ban configuration**: Migrate using Ansible fail2ban module or templates
- **ufw firewall rules**: Replace with Ansible ufw module
- **SSH hardening**: Implement using Ansible ssh_config module or templates
- **sysctl security settings**: Migrate using Ansible sysctl module
- **SSL certificate management**: Replace with Ansible openssl_* modules
- **Redis password**: Store in Ansible Vault for secure management
- **PostgreSQL credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site Nginx configuration**: Create a flexible template system in Ansible to handle multiple sites with variable configurations
- **SSL certificate generation**: Implement proper certificate management with Ansible's openssl_* modules
- **Service dependencies**: Ensure proper ordering of service deployments (e.g., PostgreSQL before FastAPI application)
- **Python virtual environment management**: Create idempotent Ansible tasks for Python environment setup
- **Redis configuration compatibility**: Ensure Redis configuration is properly migrated, addressing the configuration hacks in the original cookbook

### Migration Order

1. **nginx-multisite cookbook** (moderate complexity, foundation for web services)
   - Start with basic Nginx installation and configuration
   - Implement security hardening (fail2ban, ufw, sysctl)
   - Add SSL certificate generation
   - Configure multi-site setup

2. **cache cookbook** (low complexity, independent service)
   - Implement Memcached configuration
   - Set up Redis with authentication

3. **fastapi-tutorial cookbook** (high complexity, depends on PostgreSQL)
   - Set up PostgreSQL database
   - Deploy FastAPI application from Git
   - Configure Python environment and dependencies
   - Create systemd service

### Assumptions

1. The migration will maintain the same functionality and security posture as the original Chef implementation
2. The target environment will continue to be Ubuntu/CentOS based systems
3. Self-signed certificates are acceptable for development, but production would use proper certificates
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The Redis password and PostgreSQL credentials in the Chef recipes are development values and will be replaced with secure values in Ansible Vault
6. The Vagrant development environment will be maintained but converted to use Ansible provisioning
7. No specific monitoring or logging solutions were identified in the Chef code, so these will need to be addressed separately if required