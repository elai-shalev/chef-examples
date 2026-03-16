# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure for deploying and configuring a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting Chef cookbooks, recipes, templates, and attributes to equivalent Ansible roles, playbooks, templates, and variables.

**Scope**: 3 Chef cookbooks with multiple recipes, templates, and custom resources
**Complexity**: Medium
**Timeline Estimate**: 2-3 weeks for complete migration

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled subdomains, security hardening, and firewall configuration
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
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy configuration - will be replaced by Ansible playbook structure
- `solo.json`: Chef node configuration - will be replaced by Ansible inventory and group_vars
- `solo.rb`: Chef configuration file - will be replaced by ansible.cfg
- `Vagrantfile`: VM configuration for development - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script - will be replaced by Ansible playbook

### Target Details

Based on the source configuration files:

- **Operating System**: Supports Ubuntu 18.04+ and CentOS 7.0+, with Fedora 42 used in Vagrant development environment
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or direct package installation
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (openssl_*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or direct package installation
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct package installation

### Security Considerations

- **SSL Certificate Management**: Migration must maintain proper certificate generation and permissions
  - Use Ansible's `openssl_certificate`, `openssl_privatekey` modules
  - Maintain proper file permissions for private keys

- **Firewall Configuration (UFW)**: Preserve security rules
  - Use Ansible's `ufw` module to maintain identical firewall rules

- **fail2ban Configuration**: Maintain intrusion prevention
  - Use Ansible's `template` module to create fail2ban configuration

- **SSH Hardening**: Maintain secure SSH configuration
  - Use Ansible's `lineinfile` or `template` modules to configure sshd_config

- **Redis Authentication**: Maintain password protection
  - Use Ansible's `template` module to configure Redis with authentication

- **PostgreSQL Security**: Maintain database security
  - Use Ansible's `postgresql_*` modules to configure users, databases, and permissions

### Technical Challenges

- **Custom Resource Migration**: The `lineinfile` custom resource in Chef needs to be replaced with Ansible's native `lineinfile` module
  - Challenge: Ensuring identical behavior for complex pattern matching
  - Mitigation: Thorough testing of each use case

- **Multi-site Nginx Configuration**: Complex template-based configuration
  - Challenge: Preserving the dynamic site generation based on variables
  - Mitigation: Use Ansible's template system with proper Jinja2 syntax

- **SSL Certificate Generation**: Self-signed certificate generation logic
  - Challenge: Replicating the exact certificate parameters
  - Mitigation: Use Ansible's `openssl_*` modules with identical parameters

- **System Tuning**: sysctl security settings
  - Challenge: Ensuring identical system hardening
  - Mitigation: Use Ansible's `sysctl` module with identical parameters

### Migration Order

1. **cache cookbook** (Low complexity)
   - Simple configuration of Memcached and Redis services
   - Good starting point to establish patterns for service installation and configuration

2. **nginx-multisite cookbook** (Medium complexity)
   - Core infrastructure component with multiple templates and configurations
   - Builds on patterns established in cache cookbook

3. **fastapi-tutorial cookbook** (Medium complexity)
   - Application deployment with database dependencies
   - Relies on web server being properly configured

### Assumptions

1. The target environment will continue to use the same operating systems (Ubuntu 18.04+ or CentOS 7.0+)
2. The same security requirements will apply in the Ansible implementation
3. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt or other CA)
4. The directory structure for web content will remain the same
5. The PostgreSQL database configuration for FastAPI will remain unchanged
6. Redis will continue to require password authentication
7. The Vagrant development environment will be maintained
8. No changes to the application code or deployment architecture are required