# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and scope, this migration is estimated to require 3-4 weeks with 1-2 engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site SSL configuration, security hardening (fail2ban, UFW firewall), self-signed certificate generation

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

- `Berksfile`: Dependency management file listing cookbook dependencies (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo with site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines development VM using Fedora 42 with port forwarding and networking
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora (primary) with support for Ubuntu 18.04+ and CentOS 7+
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (community.crypto.openssl_*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or dedicated Redis tasks

### Security Considerations

- **SSL/TLS Configuration**: Migrate the SSL certificate generation and configuration, ensuring proper permissions and security settings
- **Firewall (UFW)**: Convert UFW firewall rules to Ansible UFW module or firewalld for Fedora
- **fail2ban**: Migrate fail2ban configuration using Ansible templates
- **SSH Hardening**: Preserve SSH security settings (disable root login, password authentication)
- **System Hardening**: Migrate sysctl security configurations
- **Redis Authentication**: Ensure Redis password is properly managed in Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations will require careful templating in Ansible
- **SSL Certificate Management**: Self-signed certificate generation needs to be handled properly in Ansible
- **Service Dependencies**: Ensuring proper ordering of service deployments (PostgreSQL before FastAPI, etc.)
- **Password Management**: Moving hardcoded passwords (Redis, PostgreSQL) to Ansible Vault

### Migration Order

1. **nginx-multisite cookbook** (moderate complexity, foundation for other services)
   - Base Nginx configuration
   - SSL certificate generation
   - Virtual host configuration
   - Security hardening

2. **cache cookbook** (low complexity)
   - Memcached configuration
   - Redis installation and configuration

3. **fastapi-tutorial cookbook** (high complexity)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment
   - Service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential for Ubuntu/CentOS deployment
2. Self-signed certificates are acceptable for the migrated environment (not using Let's Encrypt or commercial certificates)
3. The current security configurations are appropriate and should be maintained
4. The FastAPI application repository will remain available at the specified Git URL
5. Redis and PostgreSQL passwords in the current configuration are development passwords and will be replaced with proper secrets management
6. The Vagrant development environment should be preserved but converted to use Ansible provisioning

## Detailed Migration Tasks

### 1. Project Structure Setup

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all.yml  # Development environment variables
│   │   └── hosts        # Development inventory
│   └── production/
│       ├── group_vars/
│       │   └── all.yml  # Production environment variables
│       └── hosts        # Production inventory
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi-tutorial/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       └── templates/
├── playbooks/
│   ├── site.yml         # Main playbook
│   ├── nginx.yml        # Nginx-specific playbook
│   ├── cache.yml        # Cache services playbook
│   └── fastapi.yml      # FastAPI application playbook
├── Vagrantfile          # Updated for Ansible provisioning
└── ansible.cfg          # Ansible configuration
```

### 2. Security and Secrets Management

- Create Ansible Vault for sensitive information:
  - Redis authentication password
  - PostgreSQL database credentials
  - Any other secrets identified during migration

### 3. Testing Strategy

- Develop test playbooks for each role
- Use Vagrant for local testing
- Implement idempotence tests
- Create a CI pipeline for automated testing

### 4. Documentation

- Create README.md with setup and usage instructions
- Document variables and their default values
- Provide examples for common customizations
- Include migration notes for users of the original Chef cookbooks