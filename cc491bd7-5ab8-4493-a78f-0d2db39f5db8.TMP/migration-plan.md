# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security settings. The estimated complexity is medium, with an estimated timeline of 3-4 weeks for a complete migration.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Multi-site Nginx configuration with SSL support, security hardening, and virtual host management
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: SSL certificate generation, security headers, fail2ban integration, UFW firewall configuration

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file listing cookbook dependencies (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Chef policy file defining the run list and cookbook versions
- `solo.json`: Configuration data for Chef solo with site configurations and security settings
- `solo.rb`: Chef solo configuration file
- `Vagrantfile`: Defines development VM using Fedora 42 with port forwarding and networking
- `vagrant-provision.sh`: Bash script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source configuration files:

- **Operating System**: Supports both Ubuntu (>=18.04) and CentOS (>=7.0), with Fedora 42 used in development
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct package installation and configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl_* modules for certificate management

### Security Considerations

- **SSL Configuration**: Migrate SSL certificate generation and configuration using Ansible's openssl_* modules
- **Firewall (UFW)**: Use Ansible's community.general.ufw module to configure firewall rules
- **fail2ban**: Configure using Ansible's template module for configuration files and service management
- **SSH Hardening**: Implement using Ansible's template module for sshd_config
- **Redis Authentication**: Ensure Redis password is stored securely using Ansible Vault
- **PostgreSQL Credentials**: Store database credentials securely using Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: Ensure the dynamic generation of Nginx site configurations is properly migrated
- **SSL Certificate Management**: Properly handle self-signed certificate generation and management
- **Service Dependencies**: Maintain proper ordering of service installation, configuration, and startup
- **Security Hardening**: Ensure all security measures are properly implemented in Ansible
- **Database Initialization**: Ensure PostgreSQL database creation and user setup is idempotent

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Start with basic Nginx installation
   - Add SSL configuration
   - Implement security hardening
   - Configure virtual hosts

2. **cache** (low complexity, standalone service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on database)
   - Set up PostgreSQL database
   - Deploy FastAPI application
   - Configure systemd service

### Assumptions

1. The target environment will continue to be either Ubuntu (>=18.04) or CentOS (>=7.0)
2. The same security requirements will apply in the Ansible implementation
3. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt or other CA)
4. The FastAPI application repository will remain available at the specified URL
5. The Redis password and PostgreSQL credentials will need to be stored securely
6. The Nginx configuration will maintain the same security headers and SSL settings
7. The directory structure for document roots will remain the same
8. The same port configurations will be maintained