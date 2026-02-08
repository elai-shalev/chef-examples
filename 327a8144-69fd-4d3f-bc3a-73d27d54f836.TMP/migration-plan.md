# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure for deploying a multi-site Nginx server, caching services (Redis and Memcached), and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies to Ansible roles and playbooks. Based on the complexity and interdependencies, this migration is estimated to be of medium complexity and should take approximately 3-4 weeks with 1-2 dedicated engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and custom site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate management, security hardening (fail2ban, UFW firewall), custom site templates

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment setup, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy definition - will be replaced by Ansible playbook structure
- `solo.json`: Chef node configuration - will be replaced by Ansible inventory and variable files
- `solo.rb`: Chef configuration - will be replaced by ansible.cfg
- `Vagrantfile`: Development environment definition - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script - will be replaced by Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or direct package installation
- **memcached (~> 6.0)**: Replace with Ansible memcached role or direct package installation
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct package installation
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management tasks

### Security Considerations

- **SSL Certificate Management**: Self-signed certificates are generated in the Chef cookbook. Ansible should use the `community.crypto` collection for certificate management.
- **Firewall Configuration**: UFW firewall rules are configured in the security recipe. Ansible should use the `ansible.posix.firewalld` module for Fedora or the `community.general.ufw` module for Ubuntu.
- **Fail2ban Configuration**: Fail2ban is configured for intrusion prevention. Ansible should use dedicated fail2ban role or tasks.
- **SSH Hardening**: SSH configuration includes disabling root login and password authentication. Ansible should use the `ansible.posix.ssh_config` module.
- **Redis Authentication**: Redis is configured with a hardcoded password. Ansible should use Ansible Vault for secure password storage.

### Technical Challenges

- **Multi-site Nginx Configuration**: The nginx-multisite cookbook manages multiple virtual hosts with SSL. This will require careful translation to Ansible templates and handlers.
- **Redis Configuration Patching**: The Chef cookbook uses a ruby_block to modify Redis configuration files after installation. Ansible will need to use templates or lineinfile modules to achieve the same result.
- **Service Orchestration**: The Chef recipes manage service dependencies (e.g., PostgreSQL before FastAPI). Ansible will need to maintain these dependencies through proper task ordering.
- **SSL Certificate Management**: Self-signed certificates are generated and managed in Chef. Ansible will need equivalent functionality using the crypto modules.

### Migration Order

1. **cache cookbook** (Priority 1, moderate complexity)
   - Relatively self-contained with clear dependencies
   - Good starting point to establish patterns for service management

2. **nginx-multisite cookbook** (Priority 2, high complexity)
   - Complex with multiple recipes and templates
   - Core infrastructure component that other services depend on

3. **fastapi-tutorial cookbook** (Priority 3, moderate complexity)
   - Depends on PostgreSQL and potentially the web server
   - Application deployment should come after infrastructure components

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions.
2. Self-signed certificates are acceptable for the migrated solution (production would likely use Let's Encrypt or other CA).
3. The same directory structure for web content and configuration will be maintained.
4. The FastAPI application source will continue to be pulled from the same Git repository.
5. Redis and Memcached configurations will maintain the same port and security settings.
6. The same security hardening measures will be implemented in Ansible.

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
│       │   └── all.yml  # Production variables
│       └── hosts        # Production hosts
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
├── ansible.cfg         # Ansible configuration
└── Vagrantfile         # For local testing
```

## Migration Timeline Estimate

- **Planning and Setup**: 3 days
  - Create Ansible project structure
  - Set up testing environment
  - Define variable structure

- **Role Development**:
  - cache role: 3 days
  - nginx-multisite role: 5 days
  - fastapi-tutorial role: 4 days

- **Integration and Testing**: 5 days
  - Integrate roles into complete playbooks
  - Test on Vagrant environment
  - Verify functionality matches original Chef deployment

- **Documentation and Knowledge Transfer**: 2 days
  - Document new Ansible structure
  - Create usage examples
  - Document any manual steps or considerations

**Total Estimated Timeline**: 3-4 weeks