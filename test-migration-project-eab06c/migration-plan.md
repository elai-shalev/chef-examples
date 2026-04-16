# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services and a FastAPI application. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for migration is 3-4 weeks, with moderate complexity due to the security configurations and multi-site SSL setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled subdomains, security hardening, and custom site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site virtual hosts, SSL certificate generation, security hardening (fail2ban, ufw), custom Nginx configurations

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment setup, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists both local and external dependencies
- `Policyfile.rb`: Chef policy file defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for local development using Fedora 42
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: The configuration supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) as indicated in cookbook metadata files. The Vagrantfile uses Fedora 42.
- **Virtual Machine Technology**: Vagrant with libvirt provider as indicated in the Vagrantfile.
- **Cloud Platform**: Not specified in the repository. The configuration appears to be designed for on-premises or generic VM deployment.

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate generation
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or manual configuration tasks

### Security Considerations

- **Firewall (ufw)**: Migrate to Ansible's `community.general.ufw` module for firewall management
- **fail2ban**: Use Ansible to install and configure fail2ban with appropriate jail settings
- **SSH hardening**: Implement using Ansible's `lineinfile` or `template` modules to configure sshd_config
- **SSL certificates**: Use Ansible's `openssl_*` modules to generate self-signed certificates
- **Redis password**: Store Redis authentication password in Ansible Vault
- **PostgreSQL credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site configuration**: The Nginx setup with multiple virtual hosts and SSL certificates will require careful templating in Ansible
- **Redis configuration**: The current Chef cookbook uses a custom Ruby block to modify Redis configuration which will need to be reimplemented in Ansible
- **PostgreSQL user/database setup**: The current implementation uses inline SQL commands that will need to be converted to Ansible's postgresql_* modules
- **Service dependencies**: Ensuring proper service ordering and dependencies in Ansible (e.g., FastAPI service depending on PostgreSQL)

### Migration Order

1. **cache cookbook** (low complexity, foundational service)
   - Implement Memcached configuration
   - Implement Redis with authentication

2. **nginx-multisite cookbook** (moderate complexity, core infrastructure)
   - Implement base Nginx installation and configuration
   - Implement SSL certificate generation
   - Implement security hardening (fail2ban, ufw)
   - Implement multi-site configuration

3. **fastapi-tutorial cookbook** (high complexity, application layer)
   - Implement PostgreSQL database setup
   - Implement Python environment and dependencies
   - Implement application deployment
   - Implement systemd service configuration

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS as indicated in the cookbook metadata.
2. Self-signed SSL certificates are acceptable for the migration (production environments would likely use Let's Encrypt or other CA-signed certificates).
3. The security requirements (fail2ban, ufw, SSH hardening) will remain the same in the Ansible implementation.
4. The Redis password and PostgreSQL credentials in the Chef recipes are development/example values and will be replaced with secure values stored in Ansible Vault.
5. The FastAPI application repository URL and structure will remain the same.
6. The Nginx site configurations (test.cluster.local, ci.cluster.local, status.cluster.local) will be maintained in the Ansible implementation.
7. The Vagrant development environment will be migrated to use Ansible provisioning instead of Chef.