# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx configuration with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL backend. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and scope, this migration is estimated to require 3-4 weeks of development effort with an additional 1-2 weeks for testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup with self-signed certificates, fail2ban integration, UFW firewall rules, security headers

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file for Chef cookbooks, lists both local and external dependencies
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Node configuration file with attributes for nginx sites, SSL paths, and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Vagrant configuration for local development/testing using Fedora 42
- `vagrant-provision.sh`: Provisioning script for Vagrant to install Chef and dependencies

### Target Details

Based on the source configuration files:

- **Operating System**: The repository supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) as indicated in cookbook metadata files. The Vagrantfile uses Fedora 42 for development.
- **Virtual Machine Technology**: Vagrant with libvirt provider is used for development/testing.
- **Cloud Platform**: No specific cloud provider configurations were found. The setup appears to be cloud-agnostic.

## Migration Approach

### Key Dependencies to Address

- **nginx (v12.0)**: Replace with Ansible's `nginx` role or the `ansible.builtin.package` module for installation and `ansible.builtin.template` for configuration
- **memcached (v6.0)**: Replace with Ansible's `memcached` role or direct package installation and configuration
- **redisio (v7.2.4)**: Replace with Ansible's `redis` role or direct package installation and configuration
- **ssl_certificate (v2.1)**: Replace with Ansible's `openssl_*` modules for certificate generation and management

### Security Considerations

- **SSL/TLS Configuration**: Migrate the self-signed certificate generation process using Ansible's `openssl_certificate` module
- **Firewall Rules**: Convert UFW rules to use Ansible's `ufw` module or `firewalld` module depending on target OS
- **fail2ban**: Implement using Ansible's `fail2ban` module or direct configuration file management
- **SSH Hardening**: Migrate SSH security settings using Ansible's `lineinfile` or `template` modules
- **Security Headers**: Ensure Nginx security headers are preserved in the Ansible templates
- **Redis Authentication**: Securely manage Redis password using Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: The Nginx setup with multiple virtual hosts will require careful template conversion to maintain the same functionality
- **SSL Certificate Management**: Ensuring proper permissions and ownership for SSL certificates and private keys
- **Database User Creation**: PostgreSQL user and database creation will need to be handled with Ansible's PostgreSQL modules
- **Service Dependencies**: Ensuring proper ordering of service installations and configurations, especially for the FastAPI application that depends on PostgreSQL

### Migration Order

1. **cache cookbook** (Low complexity): Start with the cache module as it has fewer dependencies and provides a foundation for the application
2. **nginx-multisite cookbook** (Medium complexity): Migrate the web server configuration next as it's a critical component but doesn't depend on the application
3. **fastapi-tutorial cookbook** (High complexity): Finally, migrate the application deployment as it depends on both the database and potentially the web server

### Assumptions

1. The current Chef setup is functional and represents the desired end state
2. Self-signed certificates are acceptable for the migrated solution (production would likely use Let's Encrypt or other CA)
3. The same operating systems (Ubuntu/CentOS) will be targeted in the Ansible migration
4. No changes to the application code or database schema are required
5. The Vagrant development environment will be preserved but converted to use Ansible provisioning
6. Hard-coded credentials in the Chef recipes (Redis password, PostgreSQL user/password) will be moved to Ansible Vault
7. The current security settings (fail2ban, UFW, SSH hardening) are appropriate and should be maintained

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
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── Vagrantfile
└── ansible.cfg
```

## Testing Strategy

1. Develop and test each role independently using Vagrant
2. Create integration tests to verify interactions between components
3. Validate security configurations using appropriate scanning tools
4. Compare performance metrics before and after migration
5. Develop idempotency tests to ensure Ansible playbooks can be run multiple times safely