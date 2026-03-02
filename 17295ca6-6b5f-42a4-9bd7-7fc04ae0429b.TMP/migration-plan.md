# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The Chef cookbooks are well-structured and follow standard patterns
- Security configurations are comprehensive but straightforward
- External dependencies on community cookbooks will need Ansible Galaxy equivalents

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and custom site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, UFW firewall), sysctl security settings

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket - will be replaced with Ansible Galaxy requirements.yml
- `Policyfile.rb`: Defines Chef policy with run list - will be replaced with Ansible playbook structure
- `solo.json`: Contains node configuration data - will be migrated to Ansible inventory variables
- `Vagrantfile`: Defines development VM - can be adapted for Ansible testing with minimal changes
- `vagrant-provision.sh`: Installs Chef and runs cookbooks - will be replaced with Ansible provisioner
- `solo.rb`: Chef configuration file - no direct Ansible equivalent needed

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile configuration)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible Galaxy role `geerlingguy.nginx` or create custom Nginx role
- **memcached (~> 6.0)**: Replace with Ansible Galaxy role `geerlingguy.memcached`
- **redisio (~> 7.2.4)**: Replace with Ansible Galaxy role `geerlingguy.redis` or `DavidWittman.redis`
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `openssl_*` modules for certificate management

### Security Considerations

- **SSL Certificate Management**: Migrate self-signed certificate generation to Ansible's `openssl_certificate` module
- **Firewall (UFW)**: Use Ansible's `ufw` module to manage firewall rules
- **fail2ban**: Create Ansible tasks to install and configure fail2ban with appropriate jails
- **SSH Hardening**: Use Ansible's `lineinfile` module to secure SSH configuration
- **Redis Password**: Store Redis password in Ansible Vault for secure management
- **PostgreSQL Credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: Create a flexible template system in Ansible to handle multiple virtual hosts with variable SSL settings
- **Redis Configuration Workarounds**: The Chef cookbook contains a Ruby block to fix Redis configuration - this will need a custom Ansible solution
- **Service Dependencies**: Ensure proper ordering of service installations and configurations, particularly for the FastAPI application which depends on PostgreSQL

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Create base Nginx role
   - Implement SSL certificate generation
   - Configure virtual hosts
   - Implement security hardening

2. **cache** (moderate complexity)
   - Implement Memcached configuration
   - Implement Redis with authentication
   - Ensure proper service management

3. **fastapi-tutorial** (highest complexity, depends on database)
   - Set up PostgreSQL database and user
   - Configure Python environment
   - Deploy application from Git
   - Create systemd service

### Assumptions

1. The target environment will continue to be Fedora-based systems (the Vagrantfile specifies Fedora 42)
2. Self-signed certificates are acceptable for development/testing (production would likely use Let's Encrypt or other CA)
3. The security requirements (fail2ban, UFW, SSH hardening) will remain the same
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The Redis password and PostgreSQL credentials in the Chef recipes are development values and will be replaced with secure values in production
6. The current Chef implementation does not use encrypted data bags or other secret management tools

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
│   │   ├── files/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   ├── cache/
│   │   └── [similar structure]
│   └── fastapi-tutorial/
│       └── [similar structure]
├── playbooks/
│   ├── site.yml         # Main playbook (equivalent to run_list)
│   ├── nginx.yml        # Nginx-specific playbook
│   ├── cache.yml        # Cache services playbook
│   └── fastapi.yml      # FastAPI application playbook
├── requirements.yml     # Ansible Galaxy requirements (replacing Berksfile)
└── Vagrantfile          # Updated for Ansible provisioning
```

## Testing Strategy

1. Create Vagrant environment with Ansible provisioner
2. Develop and test each role individually
3. Integrate roles and test complete system
4. Verify all services are running correctly
5. Validate security configurations

## Documentation Requirements

1. README with setup instructions
2. Role-specific documentation
3. Variable reference
4. Security considerations
5. Deployment guide