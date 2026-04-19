# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure to Ansible. The repository contains three Chef cookbooks that manage a multi-site Nginx web server with SSL, caching services (Memcached and Redis), and a FastAPI Python application with PostgreSQL database. The estimated timeline for migration is 3-4 weeks, with moderate complexity due to the SSL certificate management, security configurations, and database setup requirements.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup with self-signed certificates, fail2ban integration, UFW firewall rules, security headers

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment setup, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file specifying cookbook paths and log settings
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Shell script to provision the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: The repository supports both Ubuntu (18.04+) and CentOS (7.0+) as indicated in cookbook metadata files. The Vagrantfile uses Fedora 42.
- **Virtual Machine Technology**: Vagrant with libvirt provider as indicated in the Vagrantfile
- **Cloud Platform**: No specific cloud platform dependencies identified; appears to be designed for on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role (e.g., geerlingguy.nginx)
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management tasks using openssl module
- **memcached (~> 6.0)**: Replace with Ansible memcached role (e.g., geerlingguy.memcached)
- **redisio (~> 7.2.4)**: Replace with Ansible redis role (e.g., geerlingguy.redis)

### Security Considerations

- **SSL/TLS Configuration**: The nginx-multisite cookbook generates self-signed certificates for each site. Migration should maintain or improve the SSL security settings (TLS 1.2/1.3 only, strong ciphers).
- **Firewall Rules**: UFW firewall configuration needs to be migrated to equivalent Ansible firewall module tasks.
- **fail2ban Integration**: Current setup includes fail2ban for brute force protection, which needs to be maintained.
- **SSH Hardening**: SSH configuration disables root login and password authentication when specified.
- **Security Headers**: Nginx is configured with security headers (HSTS, X-Frame-Options, CSP) that must be preserved.
- **Vault/secrets management**:
  - Redis password is hardcoded in the cache cookbook (`redis_secure_password_123`)
  - PostgreSQL credentials are hardcoded in the fastapi-tutorial cookbook (`fastapi`/`fastapi_password`)
  - No Chef Vault or encrypted data bags are used, but credentials should be moved to Ansible Vault

### Technical Challenges

- **Multi-site SSL Configuration**: The current setup dynamically generates SSL certificates for each site defined in attributes. Ansible implementation will need to maintain this flexibility.
- **Dynamic Site Configuration**: The nginx-multisite cookbook creates site configurations based on attribute data. Ansible templates will need to replicate this dynamic behavior.
- **Security Hardening**: Comprehensive security measures (sysctl settings, SSH hardening, firewall, fail2ban) need careful migration to maintain security posture.
- **Database Integration**: The FastAPI application relies on PostgreSQL database setup with specific user/permissions that must be correctly migrated.

### Migration Order

1. **cache** (Low complexity): Migrate Memcached and Redis configurations first as they have minimal dependencies
2. **nginx-multisite** (Medium complexity): Migrate the Nginx configuration, SSL certificate generation, and security settings
3. **fastapi-tutorial** (Medium complexity): Migrate the Python application deployment, database setup, and service configuration

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS/RHEL systems
2. Self-signed certificates are acceptable for the migrated solution (no integration with Let's Encrypt or other CA)
3. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
4. The current security settings (firewall rules, fail2ban, SSH hardening) are appropriate and should be maintained
5. No CI/CD pipeline integration is required for the initial migration
6. The current Redis and PostgreSQL passwords are for development only and will be replaced with secure passwords in production
7. The Vagrant development environment is not critical to migrate but could be updated to use Ansible provisioner instead of Chef