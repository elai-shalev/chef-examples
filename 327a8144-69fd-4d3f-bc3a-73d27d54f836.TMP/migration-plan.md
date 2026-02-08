# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure to Ansible. The repository contains three Chef cookbooks that manage a multi-site Nginx web server, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL. The estimated complexity is moderate, with an estimated timeline of 3-4 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate management, fail2ban integration, UFW firewall rules, security hardening

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, service management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment setup, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `Policyfile.lock.json`: Locked versions of cookbook dependencies
- `Vagrantfile`: Defines development environment using Vagrant with Fedora 42
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **SSL Certificate Management**: Migration must preserve the self-signed certificate generation for development environments
- **Firewall Rules (UFW)**: Convert UFW rules to appropriate Ansible firewall module (ufw or firewalld depending on target OS)
- **fail2ban Configuration**: Ensure fail2ban settings are properly migrated using Ansible templates
- **SSH Hardening**: Preserve SSH security settings (disable root login, password authentication)
- **Redis Authentication**: Ensure Redis password is securely managed in Ansible Vault
- **PostgreSQL Credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: Ensure the dynamic generation of multiple virtual hosts is preserved in Ansible
- **Service Dependencies**: Maintain proper ordering of service installations and configurations
- **SSL Certificate Management**: Ensure proper permissions and ownership of SSL certificates and keys
- **Database Initialization**: Ensure PostgreSQL database creation and user setup is idempotent
- **Python Environment Management**: Properly handle Python virtual environment creation and dependency installation

### Migration Order

1. **cache cookbook** (Low complexity, foundational service)
   - Simple package installations and configurations
   - Fewer dependencies on other services

2. **nginx-multisite cookbook** (Medium complexity)
   - Core web server functionality
   - Security configurations
   - SSL certificate management

3. **fastapi-tutorial cookbook** (High complexity)
   - Depends on PostgreSQL database
   - Requires application deployment and configuration
   - Systemd service management

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential support for Ubuntu and CentOS
2. Self-signed certificates are acceptable for development environments
3. The same security hardening practices should be maintained in the Ansible implementation
4. The FastAPI application repository URL will remain accessible
5. The directory structure for web content and application files will remain the same
6. Redis and Memcached configurations will maintain the same port and authentication settings
7. PostgreSQL database name, user, and credentials will remain the same
8. The migration will not introduce new features but will maintain functional equivalence