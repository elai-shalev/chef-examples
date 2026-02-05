# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies to equivalent Ansible roles and playbooks. The estimated timeline for this migration is 2-3 weeks, with moderate complexity due to the security configurations and multi-site SSL setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled websites with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall), sysctl security settings

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies (nginx, memcached, redisio)
- `Policyfile.rb`: Chef policy file defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef solo, contains site configurations and security settings
- `solo.rb`: Chef solo configuration file
- `Vagrantfile`: Defines the development VM environment (Fedora 42) with port forwarding and network settings
- `vagrant-provision.sh`: Shell script to provision the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora (based on Vagrantfile specifying "generic/fedora42"), with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (specified in Vagrantfile)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role from Galaxy or custom role
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl_* modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible memcached role from Galaxy or custom role
- **redisio (~> 7.2.4)**: Replace with Ansible redis role from Galaxy or custom role

### Security Considerations

- **Firewall (ufw)**: Migrate to Ansible's `ufw` module for firewall management
- **fail2ban**: Use Ansible's template module to configure fail2ban similar to Chef implementation
- **SSL Certificates**: Use Ansible's `openssl_*` modules to generate self-signed certificates
- **SSH Hardening**: Use Ansible's `lineinfile` module to configure SSH security settings
- **Redis Authentication**: Ensure Redis password is stored securely in Ansible Vault
- **PostgreSQL Credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: Create a flexible Ansible role that can handle multiple site configurations from variables
- **SSL Certificate Management**: Ensure proper handling of SSL certificates with appropriate permissions
- **Security Hardening**: Comprehensive security configuration across multiple services
- **Service Dependencies**: Ensure proper ordering of service deployments (PostgreSQL before FastAPI, etc.)

### Migration Order

1. **cache cookbook** (moderate complexity)
   - Start with this as it has well-defined external dependencies (memcached, redis)
   - Lower risk as it doesn't depend on the other modules

2. **nginx-multisite cookbook** (high complexity)
   - Complex due to multi-site configuration and SSL management
   - Security hardening components need careful migration

3. **fastapi-tutorial cookbook** (moderate complexity)
   - Depends on PostgreSQL setup
   - Involves application deployment and service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential support for Ubuntu and CentOS
2. The same network configuration and port mappings will be maintained
3. Self-signed SSL certificates are acceptable for the migrated solution
4. The FastAPI application source will continue to be pulled from the same Git repository
5. Redis and PostgreSQL passwords in the Chef recipes are placeholders and will need to be replaced with secure values in Ansible Vault
6. The current multi-site configuration (test.cluster.local, ci.cluster.local, status.cluster.local) will be maintained

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
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi_tutorial/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       └── templates/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── vagrant/
    └── Vagrantfile
```

## Security Migration Notes

The current Chef implementation includes several security measures that must be carefully migrated:

1. **Firewall Rules**: The Chef recipes configure UFW to allow only SSH, HTTP, and HTTPS
2. **fail2ban**: Configured to protect against brute force attacks
3. **SSH Hardening**: Disables root login and password authentication
4. **SSL Configuration**: Self-signed certificates with proper permissions
5. **Redis Authentication**: Password protection for Redis
6. **PostgreSQL Security**: Custom user and database with password authentication

Each of these must be implemented in Ansible with equivalent or improved security measures.

## Testing Strategy

1. Create a Vagrant environment similar to the current one for testing
2. Implement each role individually and test in isolation
3. Test the complete playbook to ensure all components work together
4. Verify security configurations match or exceed the current implementation
5. Test with the same site configurations to ensure compatibility

## Timeline Estimate

- **Planning and Setup**: 2-3 days
- **Role Development**:
  - cache role: 2-3 days
  - nginx_multisite role: 4-5 days
  - fastapi_tutorial role: 2-3 days
- **Integration and Testing**: 3-4 days
- **Documentation and Knowledge Transfer**: 1-2 days

**Total Estimated Time**: 2-3 weeks