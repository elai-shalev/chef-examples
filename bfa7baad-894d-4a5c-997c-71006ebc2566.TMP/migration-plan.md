# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible roles: 2-3 weeks
- Testing and Validation: 1 week
- Documentation and Knowledge Transfer: 1 week
- Total: 5-6 weeks

**Complexity Assessment:** Medium
- The repository has a clear structure with well-defined cookbooks
- External dependencies on community cookbooks need to be replaced with Ansible Galaxy roles
- Security configurations and SSL certificate management require careful migration
- Hardcoded secrets need to be moved to Ansible Vault

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured with multiple SSL-enabled virtual hosts, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall), sysctl security settings

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

- `Berksfile`: Defines cookbook dependencies (both local and external from Chef Supermarket)
  - Migration consideration: Replace with Ansible Galaxy requirements.yml

- `Policyfile.rb` and `Policyfile.lock.json`: Define the run list and cookbook versions
  - Migration consideration: Replace with Ansible playbook structure

- `solo.json`: Contains node attributes and run list for Chef Solo
  - Migration consideration: Convert to Ansible group_vars or host_vars

- `solo.rb`: Chef Solo configuration
  - Migration consideration: Replace with ansible.cfg

- `Vagrantfile`: Defines the development VM (Fedora 42)
  - Migration consideration: Update to use Ansible provisioner instead of Chef

- `vagrant-provision.sh`: Shell script to install Chef and run cookbooks
  - Migration consideration: Replace with Ansible provisioning in Vagrantfile

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible Galaxy role `geerlingguy.nginx` or create custom Nginx role
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `openssl_*` modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible Galaxy role `geerlingguy.memcached`
- **redisio (~> 7.2.4)**: Replace with Ansible Galaxy role `geerlingguy.redis` or DavidWittman.redis

### Security Considerations

- **fail2ban configuration**: Migrate to Ansible using the `geerlingguy.security` role or create custom tasks
- **ufw firewall rules**: Use Ansible's `ufw` module to configure firewall rules
- **sysctl security settings**: Use Ansible's `sysctl` module to apply kernel parameters
- **SSH hardening**: Use Ansible's `lineinfile` module or the `dev-sec.ssh-hardening` role
- **Redis password**: Store in Ansible Vault instead of hardcoded "redis_secure_password_123"
- **PostgreSQL credentials**: Store database credentials in Ansible Vault instead of hardcoded values
- **SSL certificates**: Use Ansible's `openssl_*` modules for certificate generation and management

### Technical Challenges

- **Multi-site Nginx configuration**: Create Ansible templates for Nginx site configurations with proper variable substitution
- **Redis configuration hacks**: The Chef cookbook includes a ruby_block to modify Redis configuration files; this needs to be replaced with proper Ansible template management
- **FastAPI deployment**: Ensure proper sequence of PostgreSQL setup, Python environment creation, and application deployment
- **Service dependencies**: Maintain proper ordering of service installations and configurations

### Migration Order

1. **nginx-multisite cookbook** (moderate complexity)
   - Create base Nginx role with security hardening
   - Implement SSL certificate generation
   - Configure virtual hosts based on variables

2. **cache cookbook** (low complexity)
   - Set up Memcached configuration
   - Configure Redis with proper authentication

3. **fastapi-tutorial cookbook** (high complexity)
   - Set up PostgreSQL database and user
   - Deploy FastAPI application from Git
   - Configure Python environment and dependencies
   - Create systemd service

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. Self-signed SSL certificates are acceptable for development (production would likely use Let's Encrypt or provided certificates)
3. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
4. The current security settings (fail2ban, ufw, SSH hardening) are appropriate for the target environment
5. Redis and PostgreSQL passwords in the Chef recipes are development passwords and will be replaced with secure values in production
6. The Nginx sites configuration in solo.json represents the desired state for all environments
7. No custom Chef resources or libraries are being used that would require special handling in Ansible
8. The current Chef implementation does not include complex data bags or encrypted secrets management

## Implementation Details

### Directory Structure

Proposed Ansible project structure:
```
ansible-nginx-fastapi/
├── ansible.cfg
├── inventory/
│   ├── group_vars/
│   │   └── all.yml
│   └── hosts
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── roles/
│   ├── nginx-multisite/
│   ├── cache/
│   └── fastapi-tutorial/
└── vagrant/
    └── Vagrantfile
```

### Key Ansible Features to Utilize

1. **Ansible Vault** for secret management (Redis and PostgreSQL passwords)
2. **Ansible Galaxy** for dependency management
3. **Ansible Templates** for configuration file management
4. **Ansible Handlers** for service restarts
5. **Ansible Tags** for selective execution of tasks

### Testing Strategy

1. Use Vagrant with Ansible provisioner to test the complete stack
2. Create separate playbooks for each component to allow isolated testing
3. Implement Molecule for role testing
4. Create a CI pipeline for automated testing

## Knowledge Transfer and Documentation

1. Document each Ansible role with README files explaining variables and usage
2. Create example playbooks showing how to use the roles
3. Document the migration process and decisions made
4. Provide comparison between Chef and Ansible implementations for team reference