# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for this migration is 3-4 weeks, with moderate complexity due to the security configurations and multi-site SSL setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Multi-site Nginx configuration with SSL support, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multiple virtual hosts with SSL, security hardening (fail2ban, UFW), self-signed certificate generation

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git-based deployment, Python virtual environment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Chef policy file defining run list and cookbook versions - will be replaced by Ansible playbooks
- `solo.json`: Chef node attributes and run list - will be converted to Ansible inventory variables
- `solo.rb`: Chef configuration file - will be replaced by Ansible configuration
- `Vagrantfile`: VM configuration for development/testing - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script for Vagrant - will be replaced by Ansible provisioning

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or direct configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (openssl_*)

### Security Considerations

- **SSL Certificate Management**: Migrate self-signed certificate generation to Ansible's openssl_* modules
- **Firewall (UFW)**: Use Ansible's ufw module to manage firewall rules
- **fail2ban**: Configure with Ansible templates and service management
- **SSH Hardening**: Implement using Ansible's lineinfile or template modules for sshd_config
- **Sysctl Security Settings**: Migrate to Ansible sysctl module
- **Secrets Management**: Redis password is hardcoded in recipe - should be moved to Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of site configurations will need careful translation to Ansible templates and loops
- **SSL Certificate Management**: Self-signed certificate generation logic needs to be preserved while migrating to Ansible's SSL modules
- **Security Hardening**: Comprehensive security measures need to be maintained across the migration
- **Service Dependencies**: Ensuring proper service ordering and notifications in Ansible (e.g., PostgreSQL before FastAPI)

### Migration Order

1. **nginx-multisite cookbook** (moderate complexity, foundation for other services)
   - Base Nginx configuration
   - SSL certificate generation
   - Site configuration templates
   - Security hardening (fail2ban, UFW)

2. **cache cookbook** (low complexity)
   - Memcached configuration
   - Redis installation and configuration

3. **fastapi-tutorial cookbook** (moderate complexity)
   - PostgreSQL installation and configuration
   - Python environment setup
   - Application deployment
   - Systemd service configuration

### Assumptions

- The target environment will continue to be Fedora-based systems (with support for Ubuntu/CentOS)
- Self-signed certificates are acceptable for development (production would likely use Let's Encrypt or other CA)
- The same security hardening requirements will apply in the Ansible implementation
- The FastAPI application source will remain available at the same Git repository
- Redis authentication will still be required, but the password should be secured in Ansible Vault
- The multi-site configuration with three virtual hosts will be maintained

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all.yml  # Variables from solo.json
│   │   └── hosts
│   └── production/
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/  # Convert .erb templates to Jinja2
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
│   ├── site.yml  # Main playbook (equivalent to run_list)
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── requirements.yml  # Ansible Galaxy requirements (replacing Berksfile)
└── vagrant/
    └── Vagrantfile  # For testing
```

## Testing Strategy

1. Develop individual Ansible roles for each cookbook
2. Create equivalent Vagrant setup for testing
3. Verify each component individually:
   - Nginx configuration and site availability
   - SSL certificate generation
   - Security configurations (fail2ban, UFW)
   - Caching services functionality
   - FastAPI application deployment and database connectivity
4. Perform integration testing of the complete stack

## Timeline Estimate

- **Week 1**: Analysis and role structure setup, nginx-multisite role development
- **Week 2**: cache and fastapi-tutorial roles development
- **Week 3**: Integration, testing, and documentation
- **Week 4**: Refinement, optimization, and knowledge transfer