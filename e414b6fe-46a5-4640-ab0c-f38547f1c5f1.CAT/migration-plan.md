# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security hardening practices. Based on the complexity and scope, this migration is estimated to require 3-4 weeks with a team of 2 engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall), sysctl security settings

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket (nginx, memcached, redisio, ssl_certificate)
- `Policyfile.rb`: Defines the Chef policy with run list and cookbook dependencies
- `solo.json`: Contains node attributes including Nginx site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Shell script to provision the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora/RHEL-based (Fedora 42 specified in Vagrantfile)
- **Virtual Machine Technology**: Libvirt (specified in Vagrantfile)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or nginx_core module
- **memcached (~> 6.0)**: Replace with Ansible memcached role
- **redisio (~> 7.2.4)**: Replace with Ansible redis role
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **Firewall (ufw)**: Migrate to Ansible firewalld module for RHEL/Fedora systems
- **fail2ban**: Use Ansible fail2ban module to configure intrusion prevention
- **SSH hardening**: Use Ansible ssh module to configure secure SSH settings
- **sysctl security settings**: Use Ansible sysctl module to apply kernel security parameters
- **Redis authentication**: Ensure Redis password is stored securely in Ansible Vault
- **PostgreSQL credentials**: Store database credentials in Ansible Vault
- **SSL certificates**: Manage private keys securely with Ansible Vault or external certificate management

### Technical Challenges

- **Multi-site Nginx configuration**: Ensure the Ansible role supports multiple virtual hosts with distinct SSL certificates
- **Template conversion**: Convert ERB templates to Jinja2 format for Ansible compatibility
- **Service dependencies**: Maintain proper ordering of service deployments (database before application, etc.)
- **Idempotency**: Ensure all operations remain idempotent, especially database user/schema creation
- **Self-signed certificates**: Maintain the ability to generate self-signed certificates for development environments

### Migration Order

1. **cache cookbook** (low complexity, foundational service)
   - Implement Redis configuration with authentication
   - Implement Memcached configuration

2. **nginx-multisite cookbook** (moderate complexity, core infrastructure)
   - Implement base Nginx configuration
   - Implement SSL certificate management
   - Implement virtual host configuration
   - Implement security hardening

3. **fastapi-tutorial cookbook** (high complexity, application layer)
   - Implement PostgreSQL database setup
   - Implement Python application deployment
   - Implement systemd service configuration

### Assumptions

- The target environment will continue to be Fedora/RHEL-based systems
- Self-signed certificates are acceptable for development environments
- The same security hardening practices should be maintained
- The multi-site configuration pattern will be preserved
- Redis will continue to require password authentication
- The FastAPI application will be deployed from the same Git repository