# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary Chef cookbooks with their dependencies, templates, and attributes to equivalent Ansible roles and playbooks. The estimated timeline for this migration is 3-4 weeks, with complexity rated as moderate due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificate generation
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, fail2ban integration, UFW firewall configuration, system hardening

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `Policyfile.lock.json`: Locked versions of cookbook dependencies
- `solo.json`: Node attributes and run list for Chef Solo
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for testing the infrastructure on Fedora 42
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (based on cookbook metadata and Vagrantfile)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or the `ansible.builtin.package` module with appropriate templates
- **memcached (~> 6.0)**: Replace with Ansible `geerlingguy.memcached` role or custom tasks
- **redisio (~> 7.2.4)**: Replace with Ansible `geerlingguy.redis` role or custom tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible `community.crypto` collection for certificate management

### Security Considerations

- **SSL/TLS Configuration**: Migrate self-signed certificate generation using Ansible's `community.crypto.openssl_*` modules
- **fail2ban Integration**: Use Ansible's `community.general.fail2ban` module or custom tasks
- **UFW Firewall Rules**: Use Ansible's `community.general.ufw` module
- **System Hardening**: Convert sysctl security settings to Ansible's `ansible.posix.sysctl` module
- **SSH Hardening**: Use Ansible's `ansible.builtin.lineinfile` or templates to configure SSH security settings
- **Redis Authentication**: Ensure Redis password is stored securely using Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: Creating a flexible Ansible role that supports multiple Nginx virtual hosts with variable SSL settings
- **Self-signed Certificates**: Ensuring proper permissions and ownership for SSL certificates and private keys
- **Service Dependencies**: Managing the order of service deployment (PostgreSQL before FastAPI application)
- **Idempotency**: Ensuring database creation tasks are idempotent (current Chef recipe uses `|| true` to suppress errors)
- **Configuration File Modifications**: The Redis configuration file modification currently uses a Ruby block with regex replacements, which needs to be converted to Ansible's `lineinfile` or template approach

### Migration Order

1. **cache** cookbook (low complexity, foundational service)
   - Create Ansible roles for Memcached and Redis
   - Implement secure password management for Redis

2. **nginx-multisite** cookbook (moderate complexity)
   - Create Ansible role for Nginx with multi-site support
   - Implement SSL certificate generation
   - Configure security hardening (fail2ban, UFW, sysctl)

3. **fastapi-tutorial** cookbook (moderate complexity)
   - Create Ansible role for Python application deployment
   - Implement PostgreSQL database setup
   - Configure systemd service

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. Self-signed certificates are acceptable for development/testing (no Let's Encrypt integration required)
3. The same directory structure for web content will be maintained
4. The FastAPI application source will continue to be pulled from the same Git repository
5. Redis and Memcached configurations do not require clustering or advanced features
6. The current security hardening approach is sufficient and doesn't need enhancement
7. No additional monitoring or logging solutions need to be integrated
8. The PostgreSQL database doesn't require complex configuration beyond basic user/database creation
9. The current approach of storing passwords in plaintext will be replaced with Ansible Vault

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
└── vagrant.yml
```

## Testing Strategy

1. Create Vagrant environment similar to the current setup
2. Develop and test each role individually
3. Integrate roles and test the complete playbook
4. Verify functionality against the original Chef-managed environment
5. Document any differences or improvements

## Timeline Estimate

- **Planning and Setup**: 3 days
- **Role Development**:
  - cache role: 3 days
  - nginx_multisite role: 5 days
  - fastapi_app role: 4 days
- **Integration and Testing**: 5 days
- **Documentation and Knowledge Transfer**: 2 days

**Total Estimated Time**: 22 days (approximately 3-4 weeks)