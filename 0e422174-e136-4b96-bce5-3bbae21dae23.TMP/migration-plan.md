# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting 3 Chef cookbooks with their dependencies, templates, and attributes to equivalent Ansible roles and playbooks. The estimated timeline for this migration is 2-3 weeks, with moderate complexity due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificate generation
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall), sysctl security settings

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

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Defines the run list and cookbook dependencies
- `solo.json`: Contains node attributes including Nginx site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Bash script to provision the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora (based on Vagrantfile specifying "generic/fedora42"), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (specified in Vagrantfile)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible Galaxy role `geerlingguy.nginx` or create custom Nginx role
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `openssl_*` modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible Galaxy role `geerlingguy.memcached`
- **redisio (~> 7.2.4)**: Replace with Ansible Galaxy role `geerlingguy.redis` or DavidWittman.redis

### Security Considerations

- **SSL/TLS Configuration**: Migrate the SSL certificate generation and configuration, ensuring proper file permissions and security settings
- **Firewall (UFW)**: Use Ansible's `ufw` module to configure firewall rules
- **fail2ban**: Use Ansible Galaxy role `geerlingguy.security` or create custom tasks for fail2ban configuration
- **SSH Hardening**: Migrate SSH security settings using Ansible's `lineinfile` or template modules
- **sysctl Security Settings**: Use Ansible's `sysctl` module to apply kernel parameter security settings
- **Redis Authentication**: Ensure Redis password is stored securely using Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of multiple virtual hosts with SSL will require careful template design in Ansible
- **Self-signed Certificate Generation**: The OpenSSL certificate generation will need to be converted to use Ansible's `openssl_*` modules
- **Redis Configuration Patching**: The Chef cookbook uses a Ruby block to modify Redis configuration files; this will need a different approach in Ansible
- **PostgreSQL User/Database Creation**: The current implementation uses direct SQL commands; this should be replaced with Ansible's PostgreSQL modules

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Start with basic Nginx installation and configuration
   - Add SSL certificate generation
   - Implement virtual hosts configuration
   - Add security hardening features

2. **cache** (low complexity, independent service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Set up PostgreSQL database and user
   - Implement Python environment and application deployment
   - Configure systemd service

### Assumptions

1. The target environment will continue to use the same operating systems (Fedora/Ubuntu/CentOS)
2. Self-signed certificates are acceptable for development/testing (production would likely use Let's Encrypt or other CA)
3. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
4. The security requirements (fail2ban, UFW, SSH hardening) will remain the same
5. Redis password "redis_secure_password_123" is a placeholder and will be replaced with a secure password stored in Ansible Vault
6. PostgreSQL credentials for the FastAPI application are placeholders and will be secured using Ansible Vault

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi-tutorial/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       └── templates/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── requirements.yml  # For Ansible Galaxy dependencies
└── vagrant/
    └── Vagrantfile
```

## Testing Strategy

1. Develop and test each role individually using Molecule
2. Create integration tests to verify interactions between components
3. Use the existing Vagrantfile as a reference to create an Ansible-compatible Vagrant environment for local testing
4. Implement CI/CD pipeline for automated testing

## Timeline Estimate

- **Planning and Setup**: 2-3 days
- **Role Development**:
  - nginx-multisite: 3-4 days
  - cache: 2-3 days
  - fastapi-tutorial: 3-4 days
- **Integration and Testing**: 3-4 days
- **Documentation and Knowledge Transfer**: 1-2 days

**Total Estimated Time**: 2-3 weeks