# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup with three primary cookbooks: nginx-multisite, cache, and fastapi-tutorial. The migration to Ansible will involve converting Chef cookbooks, recipes, templates, and attributes to equivalent Ansible roles, playbooks, templates, and variables. The estimated timeline for this migration is 3-4 weeks, with moderate complexity due to the security configurations and multi-site setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured with multiple SSL-enabled subdomains, security hardening, and custom site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site virtual hosts, SSL certificate generation, fail2ban integration, UFW firewall configuration, security hardening

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment setup, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks, lists both local and external dependencies
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `Vagrantfile`: Defines development VM using Fedora 42, with port forwarding and network configuration
- `solo.json`: Chef Solo configuration with node attributes for nginx sites and security settings
- `solo.rb`: Chef Solo configuration file
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct package installation and configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl_* modules for certificate generation

### Security Considerations

- **fail2ban configuration**: Migrate fail2ban jail configuration to Ansible templates
- **UFW firewall rules**: Use Ansible's community.general.ufw module to configure firewall rules
- **SSH hardening**: Implement using Ansible's lineinfile or template module for sshd_config
- **SSL certificate management**: Use Ansible's openssl_* modules to generate and manage certificates
- **Redis authentication**: Ensure Redis password is stored securely using Ansible Vault
- **PostgreSQL credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site configuration**: Ensure the Ansible role can handle multiple site configurations with proper templating
- **Self-signed certificates**: Implement certificate generation logic in Ansible
- **Service dependencies**: Maintain proper ordering of service installations and configurations
- **PostgreSQL user/database creation**: Ensure idempotent database operations using Ansible's postgresql_* modules

### Migration Order

1. **cache cookbook** (low complexity, foundational service)
   - Simple package installations and configurations
   - Fewer dependencies on other services

2. **nginx-multisite cookbook** (moderate complexity)
   - Core web server functionality
   - Security configurations
   - Multi-site setup

3. **fastapi-tutorial cookbook** (higher complexity)
   - Application deployment
   - Database configuration
   - Depends on web server for access

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential support for Ubuntu and CentOS
2. Self-signed certificates are acceptable for development/testing (production would likely use Let's Encrypt or other CA)
3. The current security configurations (fail2ban, UFW, SSH hardening) are required in the Ansible version
4. The multi-site configuration with three subdomains (test, ci, status) will be maintained
5. Redis authentication is required with the same security model
6. The FastAPI application will continue to be deployed from the same Git repository
7. PostgreSQL will remain the database backend for the FastAPI application

## Implementation Plan

### 1. Setup Ansible Structure

```
ansible/
├── inventory/
│   └── hosts.yml
├── group_vars/
│   └── all.yml
├── host_vars/
├── roles/
│   ├── nginx_multisite/
│   ├── cache/
│   └── fastapi_tutorial/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── ansible.cfg
```

### 2. Role Development

For each Chef cookbook, create an equivalent Ansible role:

#### cache role
- Tasks for installing and configuring Memcached
- Tasks for installing and configuring Redis with authentication
- Templates for configuration files

#### nginx_multisite role
- Tasks for installing Nginx
- Tasks for configuring security (fail2ban, UFW)
- Tasks for generating SSL certificates
- Templates for site configurations
- Handler for service reloads

#### fastapi_tutorial role
- Tasks for installing Python and dependencies
- Tasks for cloning Git repository
- Tasks for setting up virtual environment
- Tasks for configuring PostgreSQL
- Templates for systemd service and environment files

### 3. Variable Management

- Move Chef attributes to Ansible variables
- Use Ansible Vault for sensitive information (passwords, keys)
- Maintain the same structure for site configurations

### 4. Testing Strategy

- Use Vagrant for local testing
- Create molecule tests for each role
- Implement idempotence tests
- Test on multiple distributions (Fedora, Ubuntu, CentOS)

### 5. Documentation

- Create README files for each role
- Document variables and their defaults
- Provide example playbooks
- Include migration notes for Chef users

## Timeline Estimate

- **Week 1**: Setup Ansible structure, develop cache role
- **Week 2**: Develop nginx_multisite role
- **Week 3**: Develop fastapi_tutorial role
- **Week 4**: Testing, documentation, and refinement

Total estimated time: 3-4 weeks depending on complexity encountered during implementation.