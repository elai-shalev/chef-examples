# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for migration is 3-4 weeks, with complexity rated as moderate due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, fail2ban integration, UFW firewall rules, security headers

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Node configuration file with attributes for nginx sites, SSL paths, and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for local development using Fedora 42
- `vagrant-provision.sh`: Provisioning script for Vagrant to install Chef and dependencies

### Target Details

Based on the source configuration files:

- **Operating System**: Supports both Ubuntu (>= 18.04) and CentOS (>= 7.0), with Fedora 42 used in Vagrant for development
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (v12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (v6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (v7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (v2.1)**: Replace with Ansible OpenSSL modules for certificate generation

### Security Considerations

- **SSL/TLS Configuration**: Migrate strong cipher configurations and TLS version restrictions
- **fail2ban**: Implement fail2ban configuration using Ansible templates
- **UFW Firewall**: Configure UFW using Ansible's ufw module
- **SSH Hardening**: Implement SSH security settings (disable root login, password authentication)
- **Security Headers**: Ensure Nginx security headers are preserved in templates
- **Redis Authentication**: Securely manage Redis password (currently hardcoded as 'redis_secure_password_123')
- **PostgreSQL Authentication**: Securely manage database credentials (currently hardcoded as 'fastapi_password')

### Technical Challenges

- **SSL Certificate Management**: Self-signed certificates are generated in the Chef cookbook; need to implement equivalent functionality in Ansible using the openssl_* modules
- **Multi-site Configuration**: The dynamic generation of multiple Nginx sites will need careful implementation in Ansible templates
- **Security Hardening**: Comprehensive security measures need to be preserved across the migration
- **Service Dependencies**: Ensure proper ordering of service deployments (PostgreSQL before FastAPI, Nginx after sites are configured)

### Migration Order

1. **cache cookbook** (Low complexity, foundational service)
   - Implement Memcached configuration
   - Implement Redis with authentication

2. **fastapi-tutorial cookbook** (Medium complexity, application deployment)
   - PostgreSQL database setup
   - Python environment and application deployment
   - Systemd service configuration

3. **nginx-multisite cookbook** (High complexity, security-critical)
   - Basic Nginx installation and configuration
   - SSL certificate generation
   - Virtual host configuration
   - Security hardening (fail2ban, UFW, headers)

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS/RHEL systems
2. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt or other CA)
3. The current hardcoded credentials will be replaced with Ansible Vault or another secrets management solution
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The current security configurations are appropriate for the target environment
6. The Nginx sites configuration (test.cluster.local, ci.cluster.local, status.cluster.local) will remain the same
7. The current VM resources (2GB RAM, 2 CPUs) are sufficient for the application stack