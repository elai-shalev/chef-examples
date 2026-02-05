# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting 3 Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The repository has a moderate number of cookbooks with clear responsibilities
- External dependencies on community cookbooks need to be replaced with Ansible Galaxy roles
- Security configurations need careful migration
- Secrets management needs to be implemented with Ansible Vault

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and site configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall)

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef policy file defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Shell script to provision the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ mentioned in cookbook metadata
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role from Galaxy or custom role
- **memcached (~> 6.0)**: Replace with Ansible memcached role from Galaxy
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role from Galaxy
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management tasks

### Security Considerations

- **SSL Certificate Management**: The current setup generates self-signed certificates. Migrate to Ansible's openssl modules for certificate generation or consider integrating with Let's Encrypt via Ansible.
- **Firewall Configuration**: UFW firewall rules need to be migrated to Ansible's ufw module.
- **fail2ban Configuration**: Migrate fail2ban configuration to Ansible's template module.
- **SSH Hardening**: SSH security configurations need to be migrated to Ansible's lineinfile or template modules.
- **Redis Authentication**: Redis password is hardcoded in the recipe. Move to Ansible Vault for secure storage.
- **PostgreSQL Credentials**: Database credentials are hardcoded. Move to Ansible Vault for secure storage.

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations based on node attributes needs to be replicated using Ansible's templating system.
- **Service Dependencies**: Ensuring proper ordering of service installations and configurations, particularly for the FastAPI application which depends on PostgreSQL.
- **SSL Certificate Generation**: Replicating the self-signed certificate generation logic in Ansible.
- **Redis Configuration Hacks**: The Chef recipe contains a hack to fix Redis configuration. This needs to be properly addressed in Ansible.

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Start with basic Nginx installation
   - Add SSL certificate generation
   - Add security hardening (fail2ban, ufw)
   - Add multi-site configuration

2. **cache** (low complexity, independent service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Set up PostgreSQL
   - Deploy FastAPI application
   - Configure systemd service

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions.
2. Self-signed certificates are acceptable for development; production would likely use different certificate sources.
3. The security requirements (fail2ban, ufw, SSH hardening) will remain the same.
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available.
5. The Redis configuration hack is necessary due to compatibility issues that may need investigation during migration.
6. The current Chef setup is functional and represents the desired end state for the Ansible configuration.

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
├── roles/
│   ├── nginx-multisite/
│   ├── cache/
│   └── fastapi-tutorial/
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

## Migration Steps

1. **Create Base Structure**:
   - Set up Ansible directory structure
   - Create inventory files for development and production
   - Set up group_vars for variable storage

2. **Migrate Variables**:
   - Extract node attributes from Chef recipes and solo.json
   - Convert to Ansible variables in group_vars
   - Move sensitive data to vault.yml

3. **Create Roles**:
   - Create role for each Chef cookbook
   - Convert Chef resources to Ansible tasks
   - Create templates from Chef templates

4. **Create Playbooks**:
   - Create main site.yml playbook
   - Create individual playbooks for each role

5. **Test and Validate**:
   - Create Vagrant setup for testing
   - Validate functionality against Chef implementation

6. **Document**:
   - Create README with usage instructions
   - Document variables and customization options
   - Create migration report comparing Chef and Ansible implementations