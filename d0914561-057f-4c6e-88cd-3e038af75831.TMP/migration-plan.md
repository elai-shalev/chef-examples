# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for managing multiple web services with Nginx, caching services (Redis and Memcached), and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three primary Chef cookbooks to equivalent Ansible roles and playbooks. The estimated timeline for this migration is 3-4 weeks, with moderate complexity due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Self-signed SSL certificates, fail2ban integration, UFW firewall, multiple virtual hosts

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy file defining the run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Chef node attributes configuration - will be replaced by Ansible inventory variables
- `solo.rb`: Chef configuration file - will be replaced by ansible.cfg
- `Vagrantfile`: VM configuration for testing - can be adapted for Ansible testing with minimal changes
- `vagrant-provision.sh`: Shell script for provisioning Chef in Vagrant - will be replaced by Ansible provisioner in Vagrant

### Target Details

Based on the source configuration files:

- **Operating System**: The repository supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) as indicated in cookbook metadata files. The Vagrantfile uses Fedora 42.
- **Virtual Machine Technology**: Vagrant with libvirt provider as specified in the Vagrantfile.
- **Cloud Platform**: No specific cloud platform is targeted; the setup appears to be for on-premises or generic VM deployment.

## Migration Approach

### Key Dependencies to Address

- **nginx (Chef cookbook ~> 12.0)**: Replace with Ansible's `nginx` role or the `geerlingguy.nginx` community role
- **memcached (Chef cookbook ~> 6.0)**: Replace with Ansible's `memcached` module or the `geerlingguy.memcached` community role
- **redisio (Chef cookbook ~> 7.2.4)**: Replace with Ansible's `redis` module or the `geerlingguy.redis` community role
- **ssl_certificate (Chef cookbook ~> 2.1)**: Replace with Ansible's `openssl_*` modules for certificate management

### Security Considerations

- **Firewall Configuration**: The Chef cookbook uses UFW for firewall management. Ansible provides the `ufw` module for direct replacement.
- **fail2ban Integration**: The Chef cookbook configures fail2ban for intrusion prevention. Ansible has modules to manage fail2ban configuration.
- **SSH Hardening**: The Chef cookbook disables root login and password authentication. These can be managed with Ansible's `lineinfile` module or dedicated SSH hardening roles.
- **SSL Certificate Management**: Self-signed certificates are generated for each virtual host. Ansible's `openssl_*` modules can handle this functionality.
- **Vault/secrets management**: 
  - **cache cookbook**: Contains hardcoded Redis password (`redis_secure_password_123`) in attributes
  - **fastapi-tutorial cookbook**: Contains hardcoded PostgreSQL password (`fastapi_password`) in recipe
  - **Total credentials detected**: 2 hardcoded passwords that should be moved to Ansible Vault

### Technical Challenges

- **Custom Resource Migration**: The `lineinfile` custom resource in the nginx-multisite cookbook needs to be replaced with Ansible's native `lineinfile` module.
- **Template Conversion**: Multiple ERB templates need to be converted to Jinja2 format for Ansible.
- **Idempotent Execution**: Some Chef recipes use `execute` resources with custom guards. These need careful conversion to ensure Ansible tasks remain idempotent.
- **Multi-OS Support**: The Chef cookbooks support both Ubuntu and CentOS. Ansible playbooks will need conditional logic for different package names and service configurations.
- **SSL Certificate Handling**: The self-signed certificate generation process needs to be carefully migrated to maintain security.

### Migration Order

1. **cache cookbook** (Priority 1 - Low complexity)
   - Simple dependencies on external cookbooks
   - Minimal custom logic
   - Foundation for other services

2. **nginx-multisite cookbook** (Priority 2 - Medium complexity)
   - Core infrastructure component
   - Multiple templates and configurations
   - Security configurations that other components depend on

3. **fastapi-tutorial cookbook** (Priority 3 - Medium complexity)
   - Application-specific deployment
   - Depends on PostgreSQL configuration
   - Requires environment file with sensitive information

### Assumptions

1. The current Chef setup is functional and represents the desired end state.
2. The target environment will continue to be Vagrant VMs with similar specifications.
3. Self-signed certificates are acceptable for the migrated solution (not using Let's Encrypt or other CA).
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git is accessible and will remain available.
5. The same operating system support (Ubuntu 18.04+ and CentOS 7+) is required for the Ansible solution.
6. No additional monitoring or logging solutions need to be integrated beyond what's in the current Chef setup.
7. The current security configurations (fail2ban, UFW, SSH hardening) are sufficient and should be maintained.
8. The nginx virtual hosts configuration (test.cluster.local, ci.cluster.local, status.cluster.local) should remain the same.
9. Redis and Memcached configurations don't require clustering or advanced features not present in the current setup.