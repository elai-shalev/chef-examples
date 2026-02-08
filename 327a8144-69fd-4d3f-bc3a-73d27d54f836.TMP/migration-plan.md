# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure to Ansible. The repository contains three Chef cookbooks that manage a multi-site Nginx web server, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL database. The estimated complexity is moderate, with an estimated timeline of 3-4 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and fail2ban integration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Self-signed SSL certificates, multiple virtual hosts, UFW firewall configuration, fail2ban integration, security hardening

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible requirements.yml
- `Policyfile.rb`: Chef policy definition - will be replaced by Ansible playbook structure
- `Vagrantfile`: Development environment definition - can be adapted for Ansible testing
- `solo.json`: Chef node configuration - will be replaced by Ansible inventory and group_vars
- `vagrant-provision.sh`: Provisioning script for Vagrant - will need adaptation for Ansible

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **SSL Certificate Management**: Self-signed certificates are generated in the Chef cookbook. Migrate to Ansible's crypto modules (openssl_certificate, openssl_privatekey)
- **Firewall Configuration**: UFW configuration needs to be migrated to Ansible's ufw module
- **fail2ban Integration**: Configuration needs to be migrated to Ansible tasks
- **SSH Hardening**: SSH security settings need to be migrated to Ansible's template module or lineinfile
- **Redis Authentication**: Password is hardcoded in the recipe. Should be moved to Ansible Vault
- **PostgreSQL Authentication**: Database credentials are hardcoded. Should be moved to Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of multiple Nginx sites will need careful translation to Ansible templates and loops
- **Service Dependencies**: Ensuring proper ordering of service installation, configuration, and startup in Ansible
- **SSL Certificate Generation**: Ensuring proper permissions and security for SSL certificate generation
- **Database Initialization**: PostgreSQL database creation and user setup will need idempotent implementation in Ansible

### Migration Order

1. **cache cookbook** (Low complexity, foundational service)
   - Implement Memcached configuration
   - Implement Redis with authentication

2. **nginx-multisite cookbook** (Medium complexity, depends on no other services)
   - Implement base Nginx installation
   - Implement security configurations (fail2ban, UFW)
   - Implement SSL certificate generation
   - Implement virtual host configuration

3. **fastapi-tutorial cookbook** (High complexity, depends on PostgreSQL)
   - Implement PostgreSQL installation and configuration
   - Implement Python environment setup
   - Implement application deployment
   - Implement systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. Self-signed certificates are acceptable for the migrated solution (production would likely use Let's Encrypt or other CA)
3. The current hardcoded secrets (Redis password, PostgreSQL credentials) will be replaced with Ansible Vault variables
4. The directory structure in the target system will remain the same
5. The FastAPI application source will continue to be available at the specified Git repository
6. The Vagrant development workflow will be maintained but adapted for Ansible

## Implementation Plan

### 1. Project Structure Setup

Create the following Ansible project structure:
```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts
│   │   ├── group_vars/
│   │   │   └── all.yml
│   │   └── host_vars/
│   └── production/
├── roles/
│   ├── nginx_multisite/
│   ├── cache_services/
│   └── fastapi_app/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── requirements.yml
└── vagrant-test.yml
```

### 2. Role Development

For each Chef cookbook, develop a corresponding Ansible role:

#### cache_services role:
- Tasks for installing and configuring Memcached
- Tasks for installing and configuring Redis with secure password from Ansible Vault
- Templates for configuration files

#### nginx_multisite role:
- Tasks for Nginx installation and configuration
- Tasks for security hardening (fail2ban, UFW)
- Tasks for SSL certificate generation
- Templates for virtual host configuration
- Handler for service restart/reload

#### fastapi_app role:
- Tasks for PostgreSQL installation and database setup
- Tasks for Python environment setup
- Tasks for application deployment from Git
- Tasks for systemd service configuration
- Templates for environment configuration

### 3. Testing Strategy

1. Develop and test each role individually using Vagrant
2. Integrate roles and test complete deployment
3. Verify functionality matches original Chef implementation
4. Performance and security testing

### 4. Documentation

1. Create README files for each role explaining variables and usage
2. Document the overall architecture and deployment process
3. Create a migration guide for teams transitioning from Chef to Ansible

### 5. Knowledge Transfer

1. Conduct training sessions on the new Ansible structure
2. Provide hands-on workshops for team members
3. Establish support channels for questions during transition

## Timeline Estimate

- **Week 1**: Project setup, role scaffolding, and cache_services role development
- **Week 2**: nginx_multisite role development and testing
- **Week 3**: fastapi_app role development and testing
- **Week 4**: Integration testing, documentation, and knowledge transfer

## Success Criteria

1. All functionality from Chef cookbooks is successfully implemented in Ansible roles
2. Deployment using Ansible produces identical results to Chef deployment
3. Security considerations are properly addressed, with secrets stored in Ansible Vault
4. Documentation is complete and team members are comfortable with the new implementation