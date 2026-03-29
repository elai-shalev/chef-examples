# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-component web application environment. The migration to Ansible will involve converting three primary Chef cookbooks that manage Nginx with multiple SSL-enabled sites, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL. The estimated timeline for migration is 3-4 weeks, with moderate complexity due to SSL certificate handling, security configurations, and database integration.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and fail2ban integration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Self-signed SSL certificate generation, virtual host configuration, security headers, firewall (ufw) configuration, fail2ban integration

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies (nginx, memcached, redisio)
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding
- `vagrant-provision.sh`: Provisioning script for Vagrant that installs Chef and runs the cookbooks

### Target Details

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ based on cookbook metadata
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or `ansible.builtin.package` module with templates
- **memcached (~> 6.0)**: Replace with Ansible `memcached` role or direct package installation and configuration
- **redisio (~> 7.2.4)**: Replace with Ansible `redis` role or direct package installation and configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible `openssl_*` modules for certificate generation

### Security Considerations

- **SSL Certificate Management**: Migration must handle self-signed certificate generation for development environments
- **Security Headers**: Ensure Nginx security headers are preserved in the Ansible templates
- **Firewall Configuration**: Convert ufw rules to appropriate firewall module (firewalld for Fedora)
- **fail2ban Integration**: Ensure fail2ban configuration is properly migrated
- **SSH Hardening**: Preserve SSH security settings (root login disabled, password authentication disabled)
- **Redis Authentication**: Ensure Redis password is securely managed in Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: The Nginx setup manages multiple virtual hosts with different document roots and SSL configurations
- **Self-signed Certificates**: Certificate generation logic needs to be converted to Ansible's openssl modules
- **PostgreSQL User/DB Creation**: Database initialization and user creation needs proper idempotency checks
- **Service Dependencies**: Maintain proper ordering of service dependencies (e.g., PostgreSQL before FastAPI application)
- **Template Conversion**: Several complex templates need to be converted from ERB to Jinja2 format

### Migration Order

1. **cache** cookbook (low complexity, foundational service)
   - Install and configure Memcached
   - Install and configure Redis with authentication

2. **nginx-multisite** cookbook (medium complexity, core infrastructure)
   - Basic Nginx installation and configuration
   - Security hardening (fail2ban, firewall, headers)
   - SSL certificate generation
   - Virtual host configuration

3. **fastapi-tutorial** cookbook (high complexity, application layer)
   - PostgreSQL installation and database setup
   - Python environment configuration
   - Application deployment from Git
   - Systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems (with support for Ubuntu and CentOS)
2. Self-signed certificates are acceptable for development environments
3. The same security posture should be maintained in the Ansible implementation
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. Redis and Memcached will continue to be the caching solutions
6. The current directory structure in the target environment (/var/www/*, /etc/ssl/*) should be preserved
7. No changes to the application configuration or behavior are required during migration