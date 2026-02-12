# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and interdependencies, this migration is estimated to be of medium complexity and should take approximately 2-3 weeks for a skilled Ansible developer.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate management, security hardening (fail2ban, UFW firewall)

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

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines the run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Contains node configuration data - will be migrated to Ansible inventory variables
- `Vagrantfile`: Defines the development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script for Vagrant - will be replaced by Ansible provisioning
- `solo.rb`: Chef configuration file - not needed in Ansible

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or nginx_core module
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package module + templates
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package module + templates

### Security Considerations

- **SSL Certificate Management**: The Chef cookbook generates self-signed certificates. Migrate to Ansible's openssl_certificate module.
- **Firewall Configuration (UFW)**: Migrate to Ansible's ufw module.
- **Fail2ban Configuration**: Migrate to Ansible's template module for fail2ban configuration.
- **SSH Hardening**: Migrate SSH security configurations using Ansible's lineinfile or template modules.
- **Redis Authentication**: Ensure Redis password is stored securely using Ansible Vault.
- **PostgreSQL Authentication**: Secure database credentials using Ansible Vault.

### Technical Challenges

- **Multi-site Configuration**: The nginx-multisite cookbook dynamically creates site configurations based on node attributes. This will need to be replicated using Ansible's template module with proper looping over host variables.
- **SSL Certificate Generation**: Self-signed certificate generation will need to be handled with Ansible's openssl_* modules.
- **Service Dependencies**: Ensuring proper ordering of service deployments (PostgreSQL before FastAPI, Nginx after sites are configured).
- **Redis Configuration**: The Chef cookbook includes a hack to fix Redis configuration. This will need special attention in Ansible.

### Migration Order

1. **cache cookbook** (Low complexity, foundational services)
   - Implement Memcached configuration
   - Implement Redis configuration with authentication

2. **fastapi-tutorial cookbook** (Medium complexity, application deployment)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment
   - Systemd service configuration

3. **nginx-multisite cookbook** (High complexity, depends on applications being available)
   - Base Nginx configuration
   - SSL certificate generation
   - Virtual host configuration
   - Security hardening (fail2ban, firewall)

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems, with potential for Ubuntu/Debian support.
2. Self-signed certificates are acceptable for the migrated solution (production would likely use Let's Encrypt or other CA).
3. The security requirements (fail2ban, UFW, SSH hardening) will remain the same.
4. The Redis password and PostgreSQL credentials will need to be stored securely in Ansible Vault.
5. The FastAPI application source will continue to be pulled from the same Git repository.
6. The multi-site configuration pattern will be maintained with the same domain structure.
7. The current Vagrant development workflow will be preserved but adapted for Ansible.

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all.yml  # Variables from solo.json
│   │   └── hosts
│   └── production/
├── roles/
│   ├── nginx-multisite/
│   ├── cache/
│   │   ├── memcached/
│   │   └── redis/
│   └── fastapi-tutorial/
├── playbooks/
│   ├── site.yml         # Main playbook
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── Vagrantfile          # Updated for Ansible provisioning
└── requirements.yml     # Ansible Galaxy requirements
```

## Testing Strategy

1. Develop and test each role independently using Molecule
2. Create integration tests to verify interactions between components
3. Use the existing Vagrant setup to validate the full stack deployment
4. Implement idempotence tests to ensure configurations can be safely reapplied

## Timeline Estimate

- **Analysis and Planning**: 2-3 days
- **Role Development**:
  - cache role: 2-3 days
  - fastapi-tutorial role: 3-4 days
  - nginx-multisite role: 4-5 days
- **Integration and Testing**: 3-4 days
- **Documentation and Knowledge Transfer**: 1-2 days

**Total Estimated Time**: 15-21 days (3-4 weeks)