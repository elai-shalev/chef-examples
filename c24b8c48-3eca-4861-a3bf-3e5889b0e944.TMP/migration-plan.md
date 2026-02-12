# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and interdependencies, this migration is estimated to be of medium complexity and should take approximately 2-3 weeks with 1-2 dedicated engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
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

- `Berksfile`: Dependency management file for Chef cookbooks, lists both local and external dependencies
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `Policyfile.lock.json`: Locked versions of cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for local development and testing
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Supports both Ubuntu (>= 18.04) and CentOS (>= 7.0), with Fedora 42 used for development. The migration should target RHEL/CentOS 9 as the primary platform.
- **Virtual Machine Technology**: Vagrant with libvirt provider is used for development, suggesting KVM/libvirt as the primary virtualization platform.
- **Cloud Platform**: No specific cloud platform is identified in the configuration. The setup appears to be designed for on-premises or generic cloud deployment.

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible's `nginx` role or the `ansible.posix.nginx` collection
- **memcached (~> 6.0)**: Replace with Ansible's `memcached` role or custom tasks
- **redisio (~> 7.2.4)**: Replace with Ansible's `redis` role or the `community.general.redis` module
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `community.crypto` collection for certificate management

### Security Considerations

- **Firewall (ufw)**: Migrate to Ansible's `ansible.posix.firewalld` module for RHEL/CentOS or maintain `ufw` for Ubuntu
- **fail2ban**: Use Ansible's `community.general.fail2ban` module
- **SSH hardening**: Use Ansible's `ansible.posix.sshd` module to configure SSH security settings
- **SSL/TLS**: Use Ansible's `community.crypto` collection for certificate generation and management
- **Redis authentication**: Ensure Redis password is stored securely in Ansible Vault

### Technical Challenges

- **Multi-site Nginx configuration**: Create Ansible templates for the multi-site setup with proper Jinja2 templating
- **Self-signed certificates**: Implement certificate generation with Ansible's `community.crypto.openssl_*` modules
- **PostgreSQL setup**: Ensure proper database initialization and user creation with Ansible's `community.postgresql` collection
- **Python application deployment**: Create proper handlers for service restarts and application updates

### Migration Order

1. **nginx-multisite cookbook** (medium complexity, foundation for other services)
   - Create base Nginx role
   - Implement SSL certificate generation
   - Configure virtual hosts
   - Implement security hardening

2. **cache cookbook** (low complexity, independent service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial cookbook** (high complexity, depends on database)
   - Implement PostgreSQL database setup
   - Configure Python environment and application deployment
   - Set up systemd service

### Assumptions

1. The current Chef setup assumes manual intervention for some tasks, such as SSL certificate renewal
2. The repository doesn't specify how secrets are managed (Redis password is hardcoded)
3. The FastAPI application repository URL may change or require authentication in production
4. The Chef setup doesn't include backup strategies for PostgreSQL or Redis data
5. The current setup uses self-signed certificates which may need to be replaced with proper certificates in production
6. The Chef setup doesn't include monitoring or logging configurations beyond basic service setup

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   ├── all.yml
│   │   │   └── web_servers.yml
│   │   └── hosts.yml
│   └── production/
│       ├── group_vars/
│       │   ├── all.yml
│       │   └── web_servers.yml
│       └── hosts.yml
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
└── vagrant/
    └── Vagrantfile
```

## Testing Strategy

1. Create a Vagrant environment similar to the existing one for local testing
2. Implement molecule tests for each role
3. Test each role individually before integrating
4. Verify functionality against the original Chef implementation

## Timeline Estimate

- **Analysis and Planning**: 2-3 days
- **Role Development**:
  - nginx_multisite: 3-4 days
  - cache_services: 2-3 days
  - fastapi_app: 3-4 days
- **Integration and Testing**: 2-3 days
- **Documentation and Knowledge Transfer**: 1-2 days

**Total Estimated Time**: 11-16 days (2-3 weeks)