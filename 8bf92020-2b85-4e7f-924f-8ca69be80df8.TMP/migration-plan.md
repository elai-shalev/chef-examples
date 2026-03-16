# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for migration is 2-3 weeks, with moderate complexity due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, fail2ban integration, UFW firewall rules, security hardening

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

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Chef policy definition - will be replaced by Ansible playbook structure
- `solo.json`: Chef node configuration - will be replaced by Ansible inventory and variables
- `solo.rb`: Chef configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Development environment definition - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script - will be replaced by Ansible provisioning

### Target Details

Based on the source repository analysis:

- **Operating System**: The configuration supports both Ubuntu (>= 18.04) and CentOS (>= 7.0), with the Vagrantfile using Fedora 42 for testing.
- **Virtual Machine Technology**: Vagrant with libvirt provider is used for development/testing.
- **Cloud Platform**: No specific cloud provider configurations were found. The setup appears to be designed for on-premises or generic cloud environments.

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **SSL Certificate Management**: The current setup generates self-signed certificates. Migrate to Ansible's `openssl_certificate` module and consider integration with Let's Encrypt using `community.crypto.acme_certificate`.
- **Firewall Configuration**: UFW rules need to be migrated to Ansible's `ufw` module or `firewalld` module depending on the target OS.
- **fail2ban Integration**: Migrate fail2ban configuration to Ansible tasks using the `template` module for configuration files.
- **SSH Hardening**: The current setup disables root login and password authentication. Migrate these settings using Ansible's `lineinfile` or `template` modules.
- **System Hardening**: The sysctl security settings need to be migrated using Ansible's `sysctl` module.
- **Redis Authentication**: The Redis password is hardcoded in the recipe. This should be moved to Ansible Vault for secure storage.

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations based on node attributes will need to be replicated using Ansible's templating system and variable structures.
- **SSL Certificate Generation**: The self-signed certificate generation logic needs to be carefully migrated to ensure proper permissions and ownership.
- **Service Dependencies**: The current setup has implicit dependencies between services (e.g., FastAPI depends on PostgreSQL). These dependencies need to be explicitly managed in Ansible using handlers and conditionals.
- **PostgreSQL User/Database Creation**: The current implementation uses direct SQL commands. This should be migrated to Ansible's PostgreSQL modules for better idempotence.
- **Redis Configuration Patching**: The current setup includes a hack to fix Redis configuration. This should be properly addressed in the Ansible migration using templates or the `lineinfile` module.

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Start with basic Nginx installation and configuration
   - Implement security hardening (fail2ban, UFW, sysctl)
   - Add SSL certificate generation
   - Implement multi-site configuration

2. **cache** (low complexity, independent service)
   - Implement Memcached configuration
   - Implement Redis with authentication
   - Ensure proper log directory management

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Implement PostgreSQL installation and configuration
   - Set up Python environment and dependencies
   - Deploy application from Git
   - Configure systemd service

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS/RHEL-based systems.
2. Self-signed certificates are acceptable for development, but production may require proper CA-signed certificates.
3. The current security configurations are appropriate for the target environment and don't need significant changes.
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git is accessible and contains the expected code.
5. The current Redis configuration hack is necessary due to version incompatibilities that may still exist in the target environment.
6. The current directory structure in `/opt/server/` and `/var/www/` will be maintained in the migrated setup.
7. The Vagrant development environment will continue to be used for testing the Ansible playbooks.
8. No external monitoring or logging systems are integrated with the current setup that would require special consideration.