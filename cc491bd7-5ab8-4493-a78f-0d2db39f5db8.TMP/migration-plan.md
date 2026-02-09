# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL database. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, templates, and configuration files to equivalent Ansible roles and playbooks.

**Estimated Timeline:** 3-4 weeks
**Complexity:** Medium
**Team Size Recommendation:** 2-3 DevOps engineers

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, fail2ban integration, UFW firewall configuration, security hardening

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment setup, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Chef policy definition - will be replaced by Ansible playbook structure
- `Vagrantfile`: Development environment definition - can be adapted for Ansible testing
- `solo.json`: Chef node configuration - will be converted to Ansible inventory variables
- `vagrant-provision.sh`: Provisioning script - will be replaced by Ansible playbook calls

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.general.nginx or builtin nginx modules
- **memcached (~> 6.0)**: Replace with Ansible community.general.memcached module
- **redisio (~> 7.2.4)**: Replace with Ansible community.redis collection
- **ssl_certificate (~> 2.1)**: Replace with Ansible community.crypto collection for certificate management

### Security Considerations

- **Self-signed certificates**: Migration should maintain the self-signed certificate generation for development environments
- **fail2ban configuration**: Ensure fail2ban rules are properly migrated to Ansible
- **UFW firewall rules**: Convert UFW rules to appropriate Ansible firewall module configurations
- **SSH hardening**: Maintain SSH security configurations (root login disabled, password authentication disabled)
- **sysctl security settings**: Ensure system security parameters are properly configured
- **Redis password**: Secure handling of Redis authentication password (should use Ansible Vault)
- **PostgreSQL credentials**: Secure handling of database credentials (should use Ansible Vault)

### Technical Challenges

- **Template conversion**: Chef ERB templates need to be converted to Jinja2 format for Ansible
- **Resource ordering**: Ensure proper dependency handling between services (e.g., PostgreSQL before FastAPI app)
- **Idempotency**: Ensure all operations remain idempotent, especially custom commands and database operations
- **Multi-site configuration**: Maintain the flexibility of the multi-site Nginx setup
- **Service management**: Ensure proper service restart/reload handling when configurations change

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Start with basic Nginx installation and configuration
   - Add SSL certificate generation
   - Implement security hardening (fail2ban, UFW)
   - Configure virtual hosts

2. **cache** (low complexity, standalone service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Set up PostgreSQL database
   - Deploy FastAPI application
   - Configure systemd service

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. Self-signed certificates are acceptable for the migrated solution (production would likely use Let's Encrypt)
3. The same network configuration (ports, IPs) will be maintained
4. No changes to the application code or functionality are required during migration
5. The current Chef-based setup is working correctly and can be used as a reference

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
│   │   ├── templates/
│   │   └── files/
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
├── Vagrantfile
└── requirements.yml
```

## Testing Strategy

1. Develop and test each role individually using Molecule
2. Create integration tests to verify interactions between components
3. Use the existing Vagrantfile (adapted for Ansible) to test the complete deployment
4. Compare the results with the original Chef deployment to ensure identical functionality

## Knowledge Transfer Plan

1. Document each Ansible role with detailed README files
2. Create a migration report comparing Chef and Ansible implementations
3. Conduct a hands-on workshop for team members to understand the new Ansible structure
4. Develop runbooks for common operations and troubleshooting