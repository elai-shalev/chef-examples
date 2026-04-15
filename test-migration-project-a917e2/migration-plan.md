# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks. The estimated timeline for this migration is 3-4 weeks, with complexity rated as moderate due to the security configurations and multi-site SSL setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site SSL configuration, security hardening (fail2ban, ufw), self-signed certificate generation

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

- `Vagrantfile`: Development environment configuration using Fedora 42, with port forwarding and resource allocation
- `solo.json`: Node configuration with site definitions and security settings
- `solo.rb`: Chef Solo configuration with cookbook paths and logging settings
- `Berksfile`: External cookbook dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `vagrant-provision.sh`: Bash script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: The configuration supports both Ubuntu (>= 18.04) and CentOS (>= 7.0), with development environment using Fedora 42
- **Virtual Machine Technology**: Vagrant with libvirt provider (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified in the repository, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation and configuration tasks

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migration should maintain this capability while allowing for future integration with Let's Encrypt or other certificate authorities.
- **Firewall Configuration**: The Chef cookbook configures UFW with specific rules. Ansible migration should use the `ansible.posix.ufw` module to maintain equivalent security.
- **fail2ban Configuration**: Current implementation installs and configures fail2ban. Ansible migration should maintain this security feature.
- **SSH Hardening**: The Chef cookbook disables root login and password authentication. Ansible migration should maintain these security practices using the `ansible.posix.ssh_config` module.
- **Redis Authentication**: The cache cookbook configures Redis with password authentication. Ansible migration must maintain this security feature.

### Technical Challenges

- **Multi-site Nginx Configuration**: The current implementation dynamically creates site configurations based on node attributes. Ansible migration will need to implement similar templating logic using Jinja2 templates and variable structures.
- **SSL Certificate Generation**: The Chef cookbook generates self-signed certificates for each site. Ansible migration will need to implement equivalent functionality using the `community.crypto` collection.
- **System Hardening**: The Chef cookbook applies various security configurations. Ansible migration should maintain or enhance these security practices.
- **PostgreSQL User and Database Creation**: The FastAPI cookbook creates PostgreSQL users and databases. Ansible migration should use the `community.postgresql` collection for equivalent functionality.

### Migration Order

1. **cache cookbook** (low risk, foundational): This cookbook has clear dependencies and functionality, making it a good starting point.
2. **nginx-multisite cookbook** (moderate complexity): This cookbook forms the core of the infrastructure and should be migrated after the cache components.
3. **fastapi-tutorial cookbook** (high complexity, application-specific): This cookbook depends on the infrastructure components and should be migrated last.

### Assumptions

1. The current Chef implementation assumes Ubuntu or CentOS as the target operating system, with development using Fedora.
2. The implementation uses self-signed certificates for SSL, which may not be suitable for production environments.
3. The Redis password is hardcoded in the Chef recipe, which is a security concern that should be addressed in the Ansible migration.
4. The FastAPI application is deployed from a public GitHub repository, which may need to be updated or replaced with a private repository.
5. The PostgreSQL database credentials are hardcoded in the Chef recipe, which should be addressed in the Ansible migration using Ansible Vault.
6. The current implementation does not include backup or monitoring solutions, which may need to be added during the Ansible migration.
7. The Nginx configuration assumes specific domain names (test.cluster.local, ci.cluster.local, status.cluster.local) which may need to be parameterized in the Ansible migration.