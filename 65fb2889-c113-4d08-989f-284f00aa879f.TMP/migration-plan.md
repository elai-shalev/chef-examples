# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting 3 Chef cookbooks with their dependencies, templates, and attributes to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The codebase is well-structured with clear separation of concerns
- Security configurations are comprehensive and will require careful migration
- External dependencies on community cookbooks will need Ansible Galaxy equivalents

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and SSL certificate management
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup with self-signed certificates, security hardening (fail2ban, UFW firewall), sysctl security configurations

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

- `Berksfile`: Dependency management file listing both local cookbooks and external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo with site configurations and security settings
- `Vagrantfile`: Defines a Fedora 42 VM for local development and testing
- `vagrant-provision.sh`: Shell script to install Chef and run the cookbooks in the Vagrant environment
- `solo.rb`: Chef Solo configuration file

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ based on cookbook metadata
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role from Galaxy or custom role
- **memcached (~> 6.0)**: Replace with Ansible memcached role from Galaxy or custom role
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role from Galaxy or custom role
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management tasks or community role

### Security Considerations

- **SSL/TLS Configuration**: Migrate the SSL certificate generation and configuration, ensuring proper file permissions and security settings
- **Firewall (UFW)**: Convert UFW firewall rules to Ansible UFW module tasks
- **fail2ban**: Migrate fail2ban configuration to Ansible tasks
- **SSH Hardening**: Preserve SSH security settings (disable root login, password authentication)
- **Sysctl Security**: Migrate kernel parameter hardening
- **Redis Authentication**: Ensure Redis password is properly managed in Ansible Vault
- **PostgreSQL Authentication**: Secure database credentials using Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations will need careful translation to Ansible templates
- **SSL Certificate Management**: Self-signed certificate generation logic needs to be preserved
- **Security Hardening**: Comprehensive security measures need to be maintained across the migration
- **Service Dependencies**: Ensure proper ordering of service installations and configurations
- **Redis Configuration Hack**: The Redis configuration file manipulation in the cache cookbook will need a clean implementation in Ansible

### Migration Order

1. **nginx-multisite** (Priority 1)
   - Core infrastructure component that other services depend on
   - Start with basic Nginx installation and configuration
   - Add SSL/TLS support
   - Implement multi-site configuration
   - Add security hardening features

2. **cache** (Priority 2)
   - Implement Memcached configuration
   - Implement Redis with authentication
   - Ensure proper service management

3. **fastapi-tutorial** (Priority 3)
   - Set up PostgreSQL database
   - Deploy FastAPI application
   - Configure systemd service
   - Integrate with Nginx virtual hosts

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. Self-signed certificates are acceptable for the migrated solution (production would likely use Let's Encrypt or other CA)
3. The security requirements will remain the same (fail2ban, UFW, SSH hardening)
4. The FastAPI application repository will remain available at the specified URL
5. Redis and Memcached configurations can be directly translated to Ansible equivalents
6. The Nginx site structure and naming conventions will be preserved
7. No CI/CD pipeline integration is required as part of the migration

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
├── group_vars/
│   └── all/
│       ├── vars.yml
│       └── vault.yml
└── vagrant/
    └── Vagrantfile
```

## Testing Strategy

1. Develop Ansible roles incrementally, testing each component
2. Use Vagrant for local testing with the same VM configuration
3. Create molecule tests for individual roles
4. Perform integration testing of the complete stack
5. Validate security configurations with appropriate scanning tools
6. Compare performance metrics before and after migration

## Documentation Requirements

1. README with setup instructions
2. Role-specific documentation
3. Variable reference guide
4. Security considerations
5. Troubleshooting guide