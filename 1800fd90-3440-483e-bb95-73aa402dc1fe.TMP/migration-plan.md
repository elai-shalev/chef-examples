# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Scope**: 3 primary cookbooks with external dependencies
**Complexity**: Medium
**Estimated Timeline**: 3-4 weeks

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall)

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

- `Berksfile`: Defines cookbook dependencies (nginx, memcached, redisio, ssl_certificate) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines the run list and cookbook dependencies - will be replaced by Ansible playbooks
- `solo.json`: Contains node attributes and configuration data - will be converted to Ansible variables
- `Vagrantfile`: Defines the development VM configuration - can be adapted for Ansible testing
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM - will be replaced by Ansible provisioning
- `solo.rb`: Chef Solo configuration - not needed in Ansible

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or direct configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible OpenSSL modules for certificate generation

### Security Considerations

- **Firewall (ufw)**: Migrate to Ansible's `ansible.posix.firewalld` or `community.general.ufw` modules
- **fail2ban**: Use Ansible to configure fail2ban with templates
- **SSH hardening**: Use Ansible to configure SSH security settings
- **SSL certificates**: Use Ansible's `community.crypto` modules for certificate management
- **Redis password**: Store in Ansible Vault instead of plaintext in recipes
- **PostgreSQL credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site configuration**: Ensure the Ansible role can handle multiple Nginx sites with proper templating
- **SSL certificate generation**: Implement proper certificate management with Ansible's crypto modules
- **Service dependencies**: Maintain proper ordering of service installation and configuration
- **Idempotency**: Ensure all operations are idempotent, especially database user creation and Git repository cloning

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Create base Nginx role with multi-site support
   - Implement SSL certificate management
   - Configure security hardening

2. **cache** (low complexity, standalone services)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, application deployment)
   - Configure PostgreSQL database
   - Deploy Python application
   - Set up systemd service

### Assumptions

- The target environment will continue to be Fedora/RHEL-based systems
- Self-signed certificates are acceptable for development (production would require proper CA-signed certificates)
- The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
- The current security configurations are sufficient and should be maintained in the Ansible implementation
- The current multi-site configuration pattern should be preserved
- Redis authentication will continue to be required
- PostgreSQL will be installed locally rather than using an external database service