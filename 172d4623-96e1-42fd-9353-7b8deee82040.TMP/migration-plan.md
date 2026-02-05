# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies to Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- Multiple interconnected services
- Security configurations that need careful migration
- External dependencies on community cookbooks that need Ansible equivalents

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured with multiple SSL-enabled virtual hosts, security hardening, and custom site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall)

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Defines Chef policy with run list and cookbook versions - will be replaced by Ansible playbooks
- `solo.json`: Node configuration with site-specific settings - will be converted to Ansible inventory variables
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Development environment configuration - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script for Vagrant - will be replaced by Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic cloud VMs

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role from Galaxy or custom role
- **memcached (~> 6.0)**: Replace with Ansible memcached role from Galaxy or custom role
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role from Galaxy or custom role
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management modules (openssl_*)

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migration should maintain this capability while allowing for integration with Let's Encrypt or other certificate providers.
- **Firewall Configuration**: UFW firewall rules need to be migrated to Ansible's ufw module.
- **Fail2ban Configuration**: Fail2ban setup needs to be migrated to an Ansible role.
- **System Hardening**: System security configurations in sysctl need to be migrated.
- **SSH Hardening**: SSH security configurations need to be migrated.
- **Redis Authentication**: Redis password needs to be securely managed, potentially using Ansible Vault.

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations based on node attributes needs to be replicated using Ansible templates and variables.
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be migrated to Ansible's openssl modules.
- **Service Dependencies**: Ensuring proper ordering of service deployments (e.g., PostgreSQL before FastAPI application).
- **Python Environment Management**: Virtualenv setup and dependency management needs to be handled by Ansible's Python modules.
- **Database Initialization**: PostgreSQL database and user creation needs to be migrated to Ansible's PostgreSQL modules.

### Migration Order

1. **nginx-multisite** (Priority 1)
   - Core infrastructure component that other services depend on
   - Start with basic Nginx installation and configuration
   - Add SSL certificate management
   - Add virtual host configuration
   - Add security hardening features

2. **cache** (Priority 2)
   - Memcached configuration
   - Redis installation and configuration
   - Redis security settings

3. **fastapi-tutorial** (Priority 3)
   - PostgreSQL installation and configuration
   - Python environment setup
   - Application deployment
   - Service configuration

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems, with potential support for Ubuntu/Debian.
2. Self-signed certificates are acceptable for development; production may require integration with proper certificate authorities.
3. The current security configurations are appropriate and should be maintained in the Ansible implementation.
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available.
5. The Redis password "redis_secure_password_123" and PostgreSQL password "fastapi_password" are development credentials that should be replaced with Ansible Vault secured variables.
6. The current Vagrant development workflow should be preserved but adapted for Ansible.

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all.yml  # Variables from solo.json
│   │   └── hosts        # Development hosts
│   └── production/
│       ├── group_vars/
│       └── hosts
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
│   ├── site.yml         # Main playbook
│   ├── nginx.yml        # Nginx-specific playbook
│   ├── cache.yml        # Cache-specific playbook
│   └── fastapi.yml      # FastAPI-specific playbook
├── requirements.yml     # Ansible Galaxy requirements
└── Vagrantfile          # For development testing
```

## Testing Strategy

1. Develop individual Ansible roles with molecule testing
2. Create a Vagrant-based test environment similar to the current setup
3. Test each component individually
4. Test the complete stack integration
5. Validate security configurations
6. Performance testing to ensure comparable results to the Chef implementation

## Knowledge Transfer Plan

1. Document each Ansible role with detailed README files
2. Create a comprehensive migration report comparing Chef and Ansible implementations
3. Develop quick-start guides for developers
4. Conduct knowledge sharing sessions with the team