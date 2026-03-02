# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The codebase is well-structured with clear separation of concerns
- External dependencies are clearly defined
- Security configurations are present and need careful migration
- Multiple services with interdependencies require coordinated deployment

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled virtual hosts with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw), custom site templates

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

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines the Chef policy with run list and cookbook versions - will be replaced by Ansible playbook
- `solo.json`: Contains node attributes and run list - will be converted to Ansible inventory variables
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Defines the development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisions the VM with Chef - will be replaced with Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ as indicated in cookbook metadata
- **Virtual Machine Technology**: libvirt (as specified in Vagrantfile)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.nginx collection or geerlingguy.nginx role
- **memcached (~> 6.0)**: Replace with geerlingguy.memcached role
- **redisio (~> 7.2.4)**: Replace with geerlingguy.redis role
- **ssl_certificate (~> 2.1)**: Replace with Ansible's built-in openssl modules or community.crypto collection

### Security Considerations

- **SSL Certificate Management**: The current implementation generates self-signed certificates. Migration should use Ansible's crypto modules for certificate generation or integrate with Let's Encrypt.
- **Firewall Configuration**: UFW rules need to be migrated to equivalent Ansible UFW module tasks.
- **Fail2ban Configuration**: Configuration needs to be migrated to Ansible tasks.
- **SSH Hardening**: SSH configuration hardening needs to be preserved in Ansible.
- **Redis Authentication**: Redis password is hardcoded in the recipe and should be moved to Ansible Vault.
- **PostgreSQL Credentials**: Database credentials are hardcoded and should be moved to Ansible Vault.

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations based on node attributes needs to be replicated using Ansible's templating system.
- **Service Coordination**: The interdependencies between services (Nginx, Redis, Memcached, PostgreSQL, FastAPI) need to be maintained in the Ansible playbook.
- **SSL Certificate Generation**: The self-signed certificate generation logic needs to be replicated in Ansible.
- **Python Environment Management**: The Python virtual environment setup and dependency installation need to be handled by Ansible.

### Migration Order

1. **cache cookbook** (Low complexity, foundational services)
   - Implement Redis role
   - Implement Memcached role

2. **nginx-multisite cookbook** (Medium complexity, depends on SSL certificates)
   - Implement Nginx base configuration
   - Implement SSL certificate generation
   - Implement virtual host configuration
   - Implement security hardening (fail2ban, ufw)

3. **fastapi-tutorial cookbook** (High complexity, depends on PostgreSQL)
   - Implement PostgreSQL role
   - Implement FastAPI application deployment
   - Implement systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems, with potential support for Ubuntu and CentOS as indicated in the cookbook metadata.
2. Self-signed certificates are acceptable for the migrated solution, though the Ansible roles should be designed to allow for easy integration with proper certificates.
3. The security hardening measures (fail2ban, ufw, SSH configuration) are required in the migrated solution.
4. The FastAPI application source will continue to be available at the specified Git repository.
5. The current directory structure and naming conventions for document roots and SSL certificates will be maintained.
6. The Redis and PostgreSQL passwords in the current implementation are placeholders and will be replaced with proper secrets management in Ansible.
7. The Vagrant development environment will be maintained but updated to use Ansible provisioning instead of Chef.

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
│   ├── site.yml         # Main playbook (equivalent to run_list)
│   ├── nginx.yml        # Nginx-specific playbook
│   ├── cache.yml        # Cache services playbook
│   └── fastapi.yml      # FastAPI application playbook
├── requirements.yml     # Ansible Galaxy requirements (replacing Berksfile)
├── Vagrantfile          # Updated for Ansible provisioning
└── ansible.cfg         # Ansible configuration
```

## Vault Strategy

Create an Ansible Vault to store sensitive information:

1. Redis authentication password
2. PostgreSQL database credentials
3. SSL private keys (if not generated on the fly)
4. Any other sensitive information discovered during migration

## Testing Strategy

1. Develop a test suite using Molecule to validate each role independently
2. Create integration tests to verify the interaction between roles
3. Update the Vagrantfile to use Ansible provisioning for local testing
4. Implement idempotence tests to ensure playbooks can be run multiple times safely