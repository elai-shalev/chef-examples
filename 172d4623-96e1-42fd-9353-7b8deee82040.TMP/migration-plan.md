# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks, their dependencies, and configuration files to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The repository has a clear structure with well-defined cookbooks
- External dependencies are explicitly defined
- Security configurations need careful attention during migration
- Multiple services with interdependencies require coordinated testing

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall)

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

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines Chef policy with run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Contains node attributes and run list - will be converted to Ansible inventory variables
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Defines development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Installs Chef and runs cookbooks - will be replaced by Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role from Galaxy or custom role
- **memcached (~> 6.0)**: Replace with Ansible memcached role from Galaxy or custom role
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role from Galaxy or custom role
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management tasks or community role

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migration should maintain this capability while allowing for future integration with Let's Encrypt or other certificate authorities.
- **Firewall Configuration**: UFW firewall rules need to be migrated to equivalent Ansible firewall module tasks.
- **fail2ban Configuration**: Current fail2ban setup should be migrated to Ansible tasks.
- **SSH Hardening**: SSH configuration (disabling root login, password authentication) should be preserved in Ansible.
- **Redis Authentication**: Redis password (`redis_secure_password_123`) should be stored securely using Ansible Vault.
- **PostgreSQL Credentials**: Database credentials for FastAPI (`fastapi:fastapi_password`) should be stored securely using Ansible Vault.
- **System Hardening**: The sysctl security configurations should be migrated to equivalent Ansible tasks.

### Technical Challenges

- **Multi-site Nginx Configuration**: The dynamic generation of site configurations based on node attributes will need to be converted to Ansible templates with variable substitution.
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be preserved in Ansible tasks.
- **Service Coordination**: Dependencies between services (e.g., FastAPI depending on PostgreSQL) need to be maintained in Ansible.
- **Python Environment Management**: The Python virtual environment setup for FastAPI needs to be implemented using Ansible's Python modules.
- **Redis Configuration Hack**: The current cookbook includes a Ruby block to fix Redis configuration files. This will need a custom Ansible solution using lineinfile or template modules.

### Migration Order

1. **nginx-multisite** (Priority 1)
   - Core infrastructure component that other services depend on
   - Contains security configurations that should be established first

2. **cache** (Priority 2)
   - Provides caching services that may be used by web applications
   - Moderate complexity with Redis authentication requirements

3. **fastapi-tutorial** (Priority 3)
   - Application deployment that depends on properly configured infrastructure
   - Involves database setup, Python environment, and application deployment

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems, with potential for Ubuntu/Debian support.
2. Self-signed certificates are acceptable for development; production would require proper certificate management.
3. The current security configurations are appropriate and should be maintained in the Ansible implementation.
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available.
5. The current Redis password and PostgreSQL credentials are development values that will be replaced in production.
6. The Vagrant development environment should be preserved for testing the Ansible implementation.

## Implementation Strategy

### Ansible Structure

```
ansible/
├── inventories/
│   ├── development/
│   │   ├── hosts
│   │   └── group_vars/
│   └── production/
│       ├── hosts
│       └── group_vars/
├── roles/
│   ├── nginx-multisite/
│   ├── cache/
│   └── fastapi-tutorial/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── requirements.yml
```

### Testing Strategy

1. Develop and test each role individually using Molecule
2. Create a Vagrant-based test environment similar to the current setup
3. Implement integration tests to verify interactions between components
4. Compare outputs and configurations with the original Chef implementation

### Knowledge Transfer

1. Document each Ansible role with README files explaining usage and variables
2. Create example playbooks demonstrating common usage patterns
3. Provide mapping documentation showing Chef to Ansible equivalents
4. Schedule knowledge transfer sessions with the team

## Conclusion

This migration from Chef to Ansible will preserve all functionality while modernizing the infrastructure code. The clear structure of the existing Chef cookbooks provides a good foundation for creating equivalent Ansible roles. Special attention will be given to security configurations and service dependencies to ensure a smooth transition.