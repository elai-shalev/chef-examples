# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and scope, this migration is estimated to require 3-4 weeks with a team of 2 engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall)

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

- `Berksfile`: Dependency management file listing cookbook dependencies (will be replaced by Ansible Galaxy requirements.yml)
- `Policyfile.rb`: Chef policy file defining the run list and cookbook versions (will be replaced by Ansible playbook structure)
- `solo.json`: Configuration data for Chef Solo (will be migrated to Ansible inventory variables)
- `Vagrantfile`: Defines the development VM environment (can be adapted for Ansible testing)
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM (will be replaced by Ansible provisioning)

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile configuration)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or dedicated tasks for Redis installation and configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl_* modules for certificate management

### Security Considerations

- **SSL/TLS Configuration**: Migrate the SSL certificate generation and configuration using Ansible's openssl_* modules
- **Firewall (UFW)**: Use Ansible's community.general.ufw module to configure firewall rules
- **fail2ban**: Use Ansible tasks to install and configure fail2ban
- **SSH Hardening**: Use Ansible's openssh_* modules or dedicated role for SSH security configuration
- **Secrets Management**: Redis password is hardcoded in the recipe; should be migrated to Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations based on node attributes will need careful translation to Ansible templates and variables
- **SSL Certificate Management**: Self-signed certificate generation will need to be implemented using Ansible's openssl_* modules
- **Service Dependencies**: Ensuring proper ordering of service installation, configuration, and startup in Ansible
- **PostgreSQL User/DB Creation**: Converting the PostgreSQL user and database creation commands to idempotent Ansible tasks

### Migration Order

1. Base infrastructure (nginx-multisite cookbook)
   - Nginx installation and configuration
   - SSL certificate generation
   - Security hardening (fail2ban, UFW)
   
2. Caching services (cache cookbook)
   - Memcached installation and configuration
   - Redis installation and configuration
   
3. Application deployment (fastapi-tutorial cookbook)
   - PostgreSQL installation and configuration
   - Python environment setup
   - FastAPI application deployment
   - Systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems (as indicated in the Vagrantfile)
2. Self-signed certificates are acceptable for the migrated environment (production would likely use Let's Encrypt or other CA)
3. The security requirements (fail2ban, UFW, SSH hardening) will remain the same
4. The Redis password and PostgreSQL credentials will need to be secured in Ansible Vault
5. The FastAPI application source will continue to be pulled from the same Git repository
6. The multi-site configuration (test.cluster.local, ci.cluster.local, status.cluster.local) will remain unchanged

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
├── requirements.yml  # Ansible Galaxy requirements
└── vagrant/
    └── Vagrantfile  # For testing
```

## Testing Strategy

1. Create a Vagrant environment similar to the existing one for testing Ansible playbooks
2. Implement incremental testing of each role individually
3. Test the complete playbook against a clean VM to ensure proper integration
4. Verify all sites are accessible and properly configured
5. Validate security configurations (SSL, firewall, fail2ban)
6. Test the FastAPI application functionality

## Timeline Estimate

- **Week 1**: Setup Ansible structure, migrate nginx-multisite cookbook
- **Week 2**: Migrate cache cookbook, implement security configurations
- **Week 3**: Migrate fastapi-tutorial cookbook, integrate all components
- **Week 4**: Testing, documentation, and knowledge transfer