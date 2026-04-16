# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary Chef cookbooks to Ansible roles and playbooks, addressing security configurations, and ensuring proper handling of SSL certificates and authentication credentials.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The repository has well-structured Chef cookbooks with clear dependencies
- Security configurations are present and need careful migration
- Multiple services need to be coordinated (Nginx, Redis, Memcached, PostgreSQL, FastAPI)

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and fail2ban integration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup with self-signed certificates, security headers, firewall configuration with UFW, fail2ban integration

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

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Defines the run list and cookbook dependencies for Chef Policyfile workflow
- `solo.json`: Contains node attributes for Nginx sites, SSL configuration, and security settings
- `solo.rb`: Chef Solo configuration file defining cookbook paths and log settings
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Shell script to install Chef and run the cookbooks in the Vagrant environment

### Target Details

Based on the source configuration files:

- **Operating System**: The repository supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) as indicated in cookbook metadata files. The Vagrantfile uses Fedora 42 for development.
- **Virtual Machine Technology**: Vagrant with libvirt provider is used for development/testing.
- **Cloud Platform**: No specific cloud platform configurations were identified. The setup appears to be cloud-agnostic.

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible's `nginx` role or use the `ansible.builtin.package` module with templates
- **ssl_certificate (~> 2.1)**: Use Ansible's `openssl_*` modules for certificate generation and management
- **memcached (~> 6.0)**: Use Ansible Galaxy's `geerlingguy.memcached` role or create a custom role
- **redisio (~> 7.2.4)**: Use Ansible Galaxy's `geerlingguy.redis` role or create a custom role
- **PostgreSQL**: Use Ansible Galaxy's `geerlingguy.postgresql` role or the `community.postgresql` collection

### Security Considerations

- **Firewall Configuration**: Migrate UFW rules to Ansible's `community.general.ufw` module
- **fail2ban Integration**: Use Ansible's `community.general.fail2ban` module or create templates for fail2ban configuration
- **SSH Hardening**: Use Ansible's `ansible.posix.sshd_config` module to manage SSH configuration
- **SSL/TLS Configuration**: Ensure proper certificate generation and secure configuration using Ansible's `openssl_*` modules
- **Vault/secrets management**:
  - Redis password in `cookbooks/cache/recipes/default.rb` (hardcoded as 'redis_secure_password_123')
  - PostgreSQL credentials in `cookbooks/fastapi-tutorial/recipes/default.rb` (hardcoded as 'fastapi_password')
  - Consider using Ansible Vault for storing these credentials securely

### Technical Challenges

- **Multi-site Nginx Configuration**: Ensure the dynamic generation of virtual host configurations is properly migrated to Ansible templates
- **SSL Certificate Management**: Properly handle self-signed certificate generation and management in Ansible
- **Service Dependencies**: Maintain proper ordering of service installation and configuration, especially for the FastAPI application which depends on PostgreSQL
- **Idempotency**: Ensure all Ansible tasks are idempotent, particularly the database user and database creation tasks

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Create base Nginx role with SSL support
   - Implement security configurations (fail2ban, UFW)
   - Set up virtual host templates

2. **cache** (low complexity, independent service)
   - Set up Memcached configuration
   - Configure Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Set up PostgreSQL database and user
   - Deploy FastAPI application from Git
   - Configure Python environment and dependencies
   - Create systemd service

### Assumptions

1. The target environment will continue to support both Ubuntu and CentOS as indicated in the cookbook metadata.
2. Self-signed certificates are acceptable for development; production would likely require proper certificates.
3. The security configurations (fail2ban, UFW, SSH hardening) are required in the migrated solution.
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available.
5. The current hardcoded credentials will be replaced with more secure solutions using Ansible Vault.
6. The Vagrant development environment will be maintained but converted to use Ansible provisioning instead of Chef.
7. No custom Chef resources are being used that would require special handling in Ansible.
8. The current directory structure with separate modules will be maintained in the Ansible roles structure.