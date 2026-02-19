# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure configuration to Ansible. The repository contains three primary Chef cookbooks managing a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI Python application with PostgreSQL. The estimated complexity is moderate, with an estimated timeline of 3-4 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, ufw, SSH hardening)

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

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines Chef policy and run list - will be replaced by Ansible playbook structure
- `solo.json`: Contains node configuration data - will be migrated to Ansible inventory variables
- `Vagrantfile`: Defines development VM configuration - can be adapted for Ansible testing
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM - will be replaced by Ansible provisioning
- `solo.rb`: Chef Solo configuration - not needed in Ansible

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (community.crypto.*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or direct configuration

### Security Considerations

- **SSL/TLS Configuration**: Migrate self-signed certificate generation to Ansible crypto modules
- **fail2ban**: Implement using Ansible fail2ban role or direct configuration
- **ufw Firewall**: Replace with Ansible UFW module or firewalld for Fedora
- **SSH Hardening**: Implement using Ansible openssh_* modules or dedicated SSH hardening role
- **Redis Authentication**: Ensure Redis password is stored securely in Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: Create Ansible templates for the multi-site setup with proper jinja2 templating
- **SSL Certificate Management**: Ensure proper handling of SSL certificates and private keys with appropriate permissions
- **Service Orchestration**: Ensure proper service restart handlers when configuration changes
- **PostgreSQL User/DB Creation**: Ensure idempotent database and user creation with Ansible PostgreSQL modules

### Migration Order

1. **Base Infrastructure** (low complexity)
   - System packages installation
   - Basic security configurations (firewall, SSH)

2. **Nginx Multi-site Setup** (moderate complexity)
   - Nginx installation and configuration
   - Virtual hosts setup
   - SSL certificate generation

3. **Caching Services** (moderate complexity)
   - Memcached installation and configuration
   - Redis installation with authentication

4. **FastAPI Application** (high complexity)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment
   - Systemd service configuration

### Assumptions

- The target environment will continue to be Fedora 42 or compatible Linux distributions
- Self-signed certificates are acceptable for the migrated environment (not production)
- The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain accessible
- The Redis password "redis_secure_password_123" will need to be stored securely in Ansible Vault
- The PostgreSQL credentials (fastapi/fastapi_password) will need to be stored securely in Ansible Vault

## Detailed Migration Tasks

### 1. Project Structure Setup

```
ansible-nginx-multisite/
├── ansible.cfg
├── inventory/
│   ├── group_vars/
│   │   ├── all.yml
│   │   └── webservers.yml
│   └── hosts
├── roles/
│   ├── nginx-multisite/
│   ├── cache/
│   └── fastapi-tutorial/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── Vagrantfile
```

### 2. Nginx Multi-site Migration

- Create Ansible templates for nginx.conf, site configurations, and security settings
- Implement SSL certificate generation using Ansible crypto modules
- Configure proper handlers for service restarts
- Implement security hardening (fail2ban, firewall)

### 3. Caching Services Migration

- Implement Memcached installation and configuration
- Implement Redis installation with secure authentication
- Ensure proper service management and configuration

### 4. FastAPI Application Migration

- Implement PostgreSQL installation and database setup
- Configure Python environment and dependencies
- Deploy application from Git repository
- Configure systemd service for application management

### 5. Testing and Validation

- Create Vagrant-based testing environment
- Implement integration tests for all components
- Validate security configurations
- Test multi-site functionality and SSL configuration

## Conclusion

This migration from Chef to Ansible will require careful planning and execution, particularly for the multi-site Nginx configuration and application deployment. The existing Chef cookbooks provide a clear structure that can be mapped to Ansible roles and playbooks. Special attention should be paid to security configurations and service dependencies to ensure a smooth transition.