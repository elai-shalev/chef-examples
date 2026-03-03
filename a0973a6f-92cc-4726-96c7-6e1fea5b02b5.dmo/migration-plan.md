# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, security configurations, and service orchestration. Based on the complexity and interdependencies, this migration is estimated to require 3-4 weeks with a team of 2 engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall), system security settings

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Manages cookbook dependencies, including external cookbooks from Chef Supermarket (nginx, memcached, redisio)
- `Policyfile.rb`: Defines the Chef policy with run list and cookbook dependencies
- `solo.json`: Contains node configuration data including Nginx site definitions and security settings
- `solo.rb`: Chef Solo configuration file defining cookbook paths and log settings
- `Vagrantfile`: Defines a Fedora 42 VM for local development with port forwarding and resource allocation
- `vagrant-provision.sh`: Bash script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata and Vagrantfile)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate generation

### Security Considerations

- **Firewall (UFW)**: Migrate to Ansible's `ufw` module or `firewalld` module depending on target OS
- **fail2ban**: Use Ansible's `template` module to configure fail2ban similar to Chef implementation
- **SSH hardening**: Use Ansible's `lineinfile` or `template` module to configure SSH security settings
- **SSL/TLS configuration**: Ensure proper certificate generation and secure TLS settings in Nginx templates
- **System security settings**: Migrate sysctl security settings using Ansible's `sysctl` module
- **Redis password**: Store Redis authentication password in Ansible Vault instead of plaintext

### Technical Challenges

- **Multi-site Nginx configuration**: Create Ansible templates for the site configuration that maintain the same security headers and SSL settings
- **Self-signed certificates**: Implement certificate generation logic using Ansible's `openssl_*` modules
- **PostgreSQL user/database creation**: Replace Chef execute blocks with Ansible's `postgresql_*` modules
- **Python application deployment**: Convert the FastAPI deployment process to use Ansible's Git, pip, and template modules
- **Service orchestration**: Ensure proper service dependencies and restart handlers are maintained in Ansible

### Migration Order

1. **cache cookbook** (low risk, standalone functionality)
   - Implement Memcached configuration
   - Implement Redis with authentication

2. **nginx-multisite cookbook** (moderate complexity)
   - Implement base Nginx configuration
   - Implement SSL certificate generation
   - Implement virtual host configuration
   - Implement security settings (fail2ban, UFW)

3. **fastapi-tutorial cookbook** (high complexity, dependencies)
   - Implement PostgreSQL database setup
   - Implement Python application deployment
   - Implement systemd service configuration

### Assumptions

- The target environment will continue to use Fedora or a compatible Linux distribution
- Self-signed certificates are acceptable for development (production would likely use Let's Encrypt or other CA)
- The security requirements (fail2ban, UFW, SSH hardening) will remain the same
- The FastAPI application repository will remain available at the specified URL
- Redis password will need to be secured in Ansible Vault rather than plaintext
- The current directory structure in the target environment (/opt/server/*, /etc/ssl/*) should be maintained