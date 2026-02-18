# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their recipes, templates, and attributes to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The codebase is well-structured with clear separation of concerns
- No custom resources or complex Chef-specific patterns are used
- Standard package installation and configuration patterns are used throughout

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled virtual hosts with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall), sysctl security settings

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git-based deployment, Python virtual environment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (nginx, memcached, redisio, ssl_certificate) - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Defines the run list and cookbook dependencies - will be replaced by Ansible playbook structure
- `solo.json`: Contains node attributes and configuration data - will be migrated to Ansible inventory variables
- `solo.rb`: Chef Solo configuration - not needed in Ansible
- `Vagrantfile`: Defines the development VM - can be adapted for Ansible by changing the provisioner
- `vagrant-provision.sh`: Shell script for provisioning - will be replaced by Ansible playbook calls

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.nginx collection
- **memcached (~> 6.0)**: Replace with Ansible community.general.memcached module
- **redisio (~> 7.2.4)**: Replace with Ansible community.redis collection
- **ssl_certificate (~> 2.1)**: Replace with Ansible community.crypto collection for certificate management

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migrate to Ansible's crypto modules and consider integrating with Let's Encrypt for production.
- **Firewall Configuration**: UFW firewall rules need to be migrated to Ansible's community.general.ufw module.
- **fail2ban Configuration**: Migrate fail2ban configuration to Ansible's community.general.fail2ban module.
- **SSH Hardening**: SSH security settings (disable root login, password authentication) should be migrated to Ansible's openssh_config module.
- **Redis Authentication**: Redis password is hardcoded in the recipe. Move to Ansible Vault for secure storage.
- **PostgreSQL Credentials**: Database credentials are hardcoded. Move to Ansible Vault for secure storage.

### Technical Challenges

- **Template Conversion**: Chef templates (.erb) need to be converted to Jinja2 format for Ansible.
- **Attribute to Variable Mapping**: Chef node attributes need to be mapped to Ansible variables with appropriate precedence.
- **Idempotency**: Ensure all custom commands remain idempotent when converted to Ansible tasks.
- **Service Management**: Chef service resources need to be converted to Ansible service modules with appropriate handlers.
- **Redis Configuration**: The Chef recipe includes a hack to fix Redis configuration. This needs a cleaner implementation in Ansible.

### Migration Order

1. **nginx-multisite** (Priority 1)
   - Core infrastructure component that other services depend on
   - Start with basic Nginx installation and configuration
   - Then add SSL and security features
   - Finally, implement multi-site configuration

2. **cache** (Priority 2)
   - Implement Memcached configuration
   - Implement Redis with authentication
   - Ensure proper integration with Nginx

3. **fastapi-tutorial** (Priority 3)
   - Set up PostgreSQL database
   - Deploy FastAPI application
   - Configure systemd service
   - Integrate with Nginx for serving

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems, with potential for Ubuntu/Debian support.
2. Self-signed certificates are acceptable for development, but production deployment may require proper CA-signed certificates.
3. The current security configurations (fail2ban, ufw, SSH hardening) are appropriate for the target environment.
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available.
5. The Redis configuration "hack" in the cache cookbook is a workaround for compatibility issues that may need to be addressed differently in Ansible.
6. The current Vagrant-based development workflow will be maintained, just switching from Chef to Ansible provisioning.

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
│   │   ├── defaults/
│   │   ├── files/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   ├── cache/
│   │   └── ...
│   └── fastapi-tutorial/
│       └── ...
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── requirements.yml  # Ansible Galaxy requirements
└── Vagrantfile  # Updated for Ansible provisioning
```

## Testing Strategy

1. Develop and test each role individually using Molecule
2. Create integration tests to verify interactions between roles
3. Use the existing Vagrant setup with Ansible provisioner for full-stack testing
4. Implement CI/CD pipeline for automated testing

## Documentation Requirements

1. README with setup and usage instructions
2. Role-specific documentation for each Ansible role
3. Variable documentation with examples
4. Migration notes for users transitioning from Chef