# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting the existing Chef-based infrastructure for the FastAPI tutorial application to Ansible. The repository contains three primary Chef cookbooks that manage a multi-site Nginx configuration, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL. The estimated timeline for this migration is 3-4 weeks, with moderate complexity due to the interdependencies between components and security configurations.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening with fail2ban and UFW

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

- `Berksfile`: Dependency management file for Chef cookbooks - will be replaced by Ansible Galaxy requirements file
- `Policyfile.rb`: Chef policy file defining run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Chef node attributes and run list configuration - will be replaced by Ansible inventory variables
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: VM configuration for development/testing - can be adapted for Ansible testing
- `vagrant-provision.sh`: Shell script for Chef provisioning in Vagrant - will be replaced by Ansible provisioning

### Target Details

Based on the source repository analysis:

- **Operating System**: The primary target is Ubuntu (>= 18.04) with support for CentOS (>= 7.0) as indicated in cookbook metadata files. The Vagrantfile uses Fedora 42 for development.
- **Virtual Machine Technology**: Vagrant with libvirt provider is used for development/testing.
- **Cloud Platform**: No specific cloud provider configurations were found. The setup appears to be designed for on-premises or generic cloud VMs.

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible OpenSSL modules for certificate generation

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migration should maintain this capability using Ansible's openssl_* modules.
- **Firewall Configuration**: UFW rules need to be migrated to Ansible UFW module or firewalld for CentOS/Fedora.
- **fail2ban Configuration**: Configuration needs to be migrated to Ansible tasks for fail2ban installation and configuration.
- **SSH Hardening**: SSH configuration hardening (disabling root login, password authentication) should be migrated to Ansible ssh_config module.
- **Redis Authentication**: Redis password authentication must be preserved in the Ansible configuration.
- **PostgreSQL Security**: Database user creation with password needs to be securely handled in Ansible.

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of site configurations based on node attributes will need to be reimplemented using Ansible templates and variables.
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be preserved using Ansible's openssl_* modules.
- **Service Orchestration**: The current Chef implementation manages service dependencies (e.g., FastAPI service depends on PostgreSQL). This orchestration needs to be maintained in Ansible.
- **Configuration File Templating**: Multiple configuration templates need to be converted from ERB to Jinja2 format for Ansible.
- **Idempotent Execution**: Some Chef resources use guard clauses (`not_if`, `only_if`) that need to be reimplemented using Ansible's conditional execution.

### Migration Order

1. **cache cookbook** (Low complexity, foundational service)
   - Implement Redis and Memcached configuration
   - Test caching services independently

2. **nginx-multisite cookbook** (Medium complexity, depends on nothing)
   - Implement base Nginx installation and configuration
   - Implement SSL certificate generation
   - Implement security hardening (fail2ban, UFW)
   - Implement site configuration templating
   - Test Nginx configuration independently

3. **fastapi-tutorial cookbook** (High complexity, depends on PostgreSQL)
   - Implement PostgreSQL installation and configuration
   - Implement Python environment setup
   - Implement application deployment from Git
   - Implement systemd service configuration
   - Test FastAPI application with PostgreSQL
   - Test integration with Nginx and caching services

### Assumptions

1. The target environment will continue to support Ubuntu 18.04+ or CentOS 7+.
2. Self-signed certificates are acceptable for development/testing purposes.
3. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available.
4. The current security configurations (fail2ban, UFW, SSH hardening) are appropriate for the target environment.
5. Redis authentication with password is required in the new implementation.
6. The PostgreSQL database configuration (user: fastapi, password: fastapi_password) is for development only and would be replaced with secure credentials in production.
7. The current Nginx site configuration (test.cluster.local, ci.cluster.local, status.cluster.local) will be maintained.
8. The Vagrant development environment will be preserved but updated to use Ansible provisioning.

## Ansible Structure Recommendation

```
fastapi-tutorial/
├── ansible.cfg
├── inventory/
│   ├── group_vars/
│   │   ├── all.yml
│   │   └── webservers.yml
│   └── hosts.ini
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
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── Vagrantfile
```

## Testing Strategy

1. Develop and test each role independently using Molecule
2. Create integration tests for the complete stack
3. Verify functionality matches the original Chef implementation
4. Test on both Ubuntu and CentOS/Fedora targets