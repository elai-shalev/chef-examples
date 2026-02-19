# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure configuration to Ansible. The repository contains three primary Chef cookbooks (nginx-multisite, cache, and fastapi-tutorial) that manage a multi-site Nginx web server, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL. The estimated complexity is moderate, with an expected timeline of 3-4 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall), sysctl security settings

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines the run list and cookbook dependencies - will be replaced by Ansible playbook structure
- `solo.json`: Contains node attributes for Nginx sites and security settings - will be migrated to Ansible variables
- `solo.rb`: Chef configuration file - not needed in Ansible
- `Vagrantfile`: Defines development VM using Fedora 42 - can be adapted for Ansible testing
- `vagrant-provision.sh`: Installs Chef and dependencies - will be replaced by Ansible provisioning

### Target Details

- **Operating System**: Fedora (based on Vagrantfile specifying "generic/fedora42"), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role from Galaxy or direct package installation with templates
- **ssl_certificate (~> 2.1)**: Replace with Ansible `openssl_*` modules for certificate generation
- **memcached (~> 6.0)**: Replace with Ansible `memcached` role from Galaxy or direct package configuration
- **redisio (~> 7.2.4)**: Replace with Ansible `redis` role from Galaxy or direct package configuration

### Security Considerations

- **SSL/TLS Configuration**: Migrate self-signed certificate generation to Ansible's `openssl_*` modules
- **Firewall (UFW)**: Use Ansible's `ufw` module to configure firewall rules
- **fail2ban**: Use Ansible's `lineinfile` or templates to configure fail2ban
- **SSH Hardening**: Use Ansible's `lineinfile` or templates to configure SSH security settings
- **sysctl Security**: Use Ansible's `sysctl` module for kernel parameter configuration
- **Redis Authentication**: Ensure Redis password is stored securely using Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of multiple virtual hosts with SSL will require careful template design in Ansible
- **Redis Configuration Hacks**: The Chef recipe contains a hack to modify Redis configuration files after installation, which will need a clean implementation in Ansible
- **Service Dependencies**: Ensuring proper ordering of service installation and configuration, particularly for the FastAPI application that depends on PostgreSQL
- **SSL Certificate Management**: Ensuring proper permissions and ownership of SSL certificates and private keys

### Migration Order

1. **cache cookbook** (Low complexity, foundational service)
   - Implement Memcached configuration
   - Implement Redis configuration with authentication

2. **nginx-multisite cookbook** (Medium complexity, core infrastructure)
   - Implement base Nginx installation and configuration
   - Implement SSL certificate generation
   - Implement security hardening (fail2ban, UFW, sysctl)
   - Implement virtual host configuration

3. **fastapi-tutorial cookbook** (High complexity, application layer)
   - Implement PostgreSQL installation and database setup
   - Implement Python environment and application deployment
   - Implement systemd service configuration

### Assumptions

- The current Chef implementation is functional and complete
- No additional external dependencies beyond what's specified in the Berksfile
- Self-signed certificates are acceptable (no integration with Let's Encrypt or other CA)
- The target environment will continue to be Fedora-based systems
- No changes to the application architecture are required during migration
- The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git is accessible and stable

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       └── all.yml
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
│           └── all.yml
├── roles/
│   ├── nginx_multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   ├── cache_services/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi_app/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       └── templates/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── requirements.yml
└── Vagrantfile
```

## Testing Strategy

1. Create individual role tests using Molecule
2. Develop a Vagrant-based test environment similar to the existing one
3. Implement integration tests to verify the complete stack functionality
4. Compare outputs and configurations between Chef and Ansible implementations

## Timeline Estimate

- **Week 1**: Analysis and role scaffolding
- **Week 2**: Implementation of individual roles
- **Week 3**: Integration and testing
- **Week 4**: Documentation and knowledge transfer

Total estimated effort: 3-4 weeks