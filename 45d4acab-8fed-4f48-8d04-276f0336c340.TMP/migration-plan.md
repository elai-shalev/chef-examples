# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup focused on deploying and configuring a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI Python application with PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security hardening features. The estimated timeline for this migration is 2-3 weeks, with moderate complexity due to the security configurations and multi-site SSL setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, UFW firewall rules, fail2ban integration, SSH hardening

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies including nginx (~> 12.0), memcached (~> 6.0), redisio (~> 7.2.4), and ssl_certificate (~> 2.1)
- `Policyfile.rb`: Defines the run list and cookbook dependencies for Chef Policyfile workflow
- `solo.json`: Contains node attributes including Nginx site configurations, SSL paths, and security settings
- `solo.rb`: Chef Solo configuration file defining cookbook paths and log settings
- `Vagrantfile`: Defines a Fedora 42 VM for local development with port forwarding and networking
- `vagrant-provision.sh`: Shell script to install Chef and run the cookbooks in the Vagrant environment

### Target Details

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ based on cookbook metadata
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or nginx_core module
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks with custom configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate generation

### Security Considerations

- **Firewall configuration**: Migrate UFW rules to Ansible ufw module or firewalld for Fedora
- **fail2ban integration**: Create Ansible tasks to install and configure fail2ban with appropriate jails
- **SSH hardening**: Use Ansible to configure SSH daemon with secure settings (disable root login, password authentication)
- **SSL certificate management**: Ensure proper handling of SSL certificates and private keys with appropriate permissions
- **Redis password**: Store Redis authentication password in Ansible Vault
- **PostgreSQL credentials**: Store database credentials in Ansible Vault
- **sysctl security settings**: Migrate kernel parameter hardening to Ansible sysctl module

### Technical Challenges

- **Multi-site SSL configuration**: The current setup generates self-signed certificates for multiple domains. This will need careful migration to Ansible's openssl_* modules or certbot integration for Let's Encrypt certificates.
- **Service dependencies**: Ensuring proper ordering of service deployments, especially for the FastAPI application which depends on PostgreSQL.
- **Template conversion**: Converting ERB templates to Jinja2 format for Ansible, particularly for complex configurations like Nginx virtual hosts.
- **Idempotency**: Ensuring all operations remain idempotent, especially for database user creation and Git repository deployment.

### Migration Order

1. **cache cookbook** (low risk, foundational service)
   - Simple package installations and configurations
   - Foundation for application performance

2. **nginx-multisite cookbook** (moderate complexity)
   - Core web server functionality
   - Security hardening components
   - SSL certificate generation

3. **fastapi-tutorial cookbook** (highest complexity)
   - Application deployment
   - Database integration
   - Service management

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions.
2. Self-signed certificates are acceptable for development; production would likely require proper CA-signed certificates.
3. The security hardening requirements will remain the same in the Ansible implementation.
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available.
5. The current Redis password and PostgreSQL credentials are for development only and will be replaced with secure values in production.
6. The current implementation does not use centralized secrets management beyond configuration files.
7. No external monitoring or logging solutions are integrated that would require special handling.