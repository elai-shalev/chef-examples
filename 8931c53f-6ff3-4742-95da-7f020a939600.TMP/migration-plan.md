# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for migration is 3-4 weeks, with complexity rated as moderate due to the security configurations and multi-site SSL setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and fail2ban integration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Self-signed SSL certificates, UFW firewall configuration, fail2ban integration, sysctl security settings, multi-site virtual hosts

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Chef policy file defining the run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Configuration data for Chef Solo - will be migrated to Ansible group_vars or host_vars
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Development environment definition - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script for Vagrant - will be replaced by Ansible provisioning

### Target Details

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ based on cookbook metadata
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified in the repository, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **fail2ban configuration**: Migrate fail2ban jail configuration to Ansible templates
- **UFW firewall rules**: Use Ansible's ufw module to configure firewall rules
- **SSH hardening**: Implement SSH configuration using Ansible's template module or community.general.ssh_config module
- **sysctl security settings**: Use Ansible's sysctl module to apply kernel parameter security settings
- **Redis password**: Store Redis authentication password in Ansible Vault
- **PostgreSQL credentials**: Store database credentials in Ansible Vault
- **SSL certificates**: Use Ansible's openssl_* modules for certificate generation and management

### Technical Challenges

- **Multi-site Nginx configuration**: The current implementation manages multiple virtual hosts with SSL. This will require careful template conversion and potentially using Ansible loops for site configuration.
- **Self-signed certificates**: The current implementation generates self-signed certificates for development. This logic needs to be replicated in Ansible using the openssl_* modules.
- **Redis configuration hacks**: The current implementation includes a Ruby block to modify Redis configuration files after installation. This will need special handling in Ansible, potentially using lineinfile or replace modules.
- **PostgreSQL user and database creation**: The current implementation uses direct psql commands. This should be replaced with Ansible's postgresql_* modules for better idempotency.

### Migration Order

1. **cache cookbook** (low complexity, foundational service)
   - Implement Memcached configuration
   - Implement Redis with authentication

2. **nginx-multisite cookbook** (moderate complexity, core infrastructure)
   - Implement base Nginx installation and configuration
   - Implement SSL certificate generation
   - Implement security hardening (fail2ban, UFW, sysctl)
   - Implement multi-site virtual host configuration

3. **fastapi-tutorial cookbook** (moderate complexity, application layer)
   - Implement PostgreSQL installation and configuration
   - Implement Python environment setup
   - Implement application deployment from Git
   - Implement systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions.
2. Self-signed certificates are acceptable for development purposes.
3. The same directory structure for web content (/var/www/[site]) will be maintained.
4. The same security policies (SSH hardening, firewall rules) will be applied.
5. Redis and Memcached configurations will remain similar.
6. The FastAPI application source will continue to be pulled from the same Git repository.
7. The PostgreSQL database structure and user permissions will remain the same.
8. The systemd service configuration for the FastAPI application will remain similar.