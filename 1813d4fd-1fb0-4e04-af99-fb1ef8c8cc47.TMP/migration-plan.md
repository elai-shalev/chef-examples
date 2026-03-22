# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configurations, and security settings to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium to High
- Multiple interconnected services
- Security configurations that need careful migration
- SSL certificate management
- Database configuration and secrets management

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, fail2ban integration, UFW firewall rules, security headers

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database setup
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible requirements.yml
- `Policyfile.rb`: Chef policy definition - will be replaced by Ansible playbook structure
- `solo.json`: Chef node configuration - will be replaced by Ansible inventory and variable files
- `solo.rb`: Chef configuration - will be replaced by ansible.cfg
- `Vagrantfile`: Development environment definition - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script - will be replaced by Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (v12.0+)**: Replace with Ansible `nginx` role or `ansible.builtin.package` module
- **memcached (v6.0+)**: Replace with Ansible `geerlingguy.memcached` role or custom role
- **redisio (v7.2.4+)**: Replace with Ansible `geerlingguy.redis` role or custom role
- **ssl_certificate (v2.1+)**: Replace with Ansible `community.crypto` collection for certificate management

### Security Considerations

- **SSL/TLS Configuration**: Migrate the SSL certificate generation and configuration using Ansible's `community.crypto` collection
- **Firewall Rules (UFW)**: Use Ansible's `community.general.ufw` module to configure firewall rules
- **fail2ban**: Use Ansible's `community.general.fail2ban` module or a dedicated role
- **SSH Hardening**: Migrate SSH security settings using Ansible's `ansible.posix.sshd_config` module
- **System Hardening**: Migrate sysctl security settings using Ansible's `ansible.posix.sysctl` module
- **Redis Password**: Store Redis password in Ansible Vault instead of plaintext in recipes
- **PostgreSQL Credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Custom Resource Migration**: The `lineinfile` custom resource in nginx-multisite needs to be replaced with Ansible's `ansible.builtin.lineinfile` module
- **Template Conversion**: ERB templates need to be converted to Jinja2 format for Ansible
- **Multi-site Configuration**: The dynamic site configuration in nginx-multisite needs careful migration to maintain flexibility
- **Service Dependencies**: Ensure proper ordering of service deployments (PostgreSQL before FastAPI, etc.)
- **SSL Certificate Handling**: Ensure secure handling of SSL certificates and private keys
- **Redis Configuration Hacks**: The Redis configuration hack in the cache cookbook needs a cleaner implementation in Ansible

### Migration Order

1. **nginx-multisite** (Priority 1)
   - Core infrastructure component that other services depend on
   - Start with basic Nginx installation and configuration
   - Add SSL/TLS support
   - Add security configurations (fail2ban, firewall)
   - Add multi-site support

2. **cache** (Priority 2)
   - Implement Memcached configuration
   - Implement Redis with authentication
   - Address the Redis configuration workarounds

3. **fastapi-tutorial** (Priority 3)
   - Set up PostgreSQL database
   - Deploy Python application with virtual environment
   - Configure systemd service

### Assumptions

1. The target environment will continue to be Fedora 42 or similar Linux distributions
2. Self-signed certificates are acceptable for development/testing (production would likely use Let's Encrypt or other CA)
3. The current security configurations are appropriate and should be maintained
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git is accessible and will remain available
5. The current directory structure for web content (/opt/server/test, etc.) should be maintained
6. The current Redis password "redis_secure_password_123" is for development only and would be replaced in production
7. The PostgreSQL credentials (fastapi/fastapi_password) are for development only and would be replaced in production
8. The current firewall configuration allowing only SSH, HTTP, and HTTPS is appropriate
9. The SSH hardening configuration (no root login, no password authentication) should be maintained