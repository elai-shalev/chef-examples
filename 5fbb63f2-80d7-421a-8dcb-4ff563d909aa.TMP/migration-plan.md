# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure configuration to Ansible. The repository contains three primary Chef cookbooks managing a multi-site Nginx web server environment with caching services (Redis and Memcached) and a FastAPI Python application with PostgreSQL backend. The estimated complexity is moderate, with an estimated timeline of 3-4 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificate generation
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall), sysctl security settings

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies including nginx (~> 12.0), memcached (~> 6.0), redisio (~> 7.2.4), and ssl_certificate (~> 2.1)
- `Policyfile.rb`: Defines the Chef policy with run list and cookbook dependencies
- `solo.json`: Contains node configuration including Nginx site definitions and security settings
- `solo.rb`: Chef Solo configuration file defining cookbook paths and log settings
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Bash script for provisioning the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora (based on Vagrantfile specifying "generic/fedora42"), with compatibility for Ubuntu (>= 18.04) and CentOS (>= 7.0) as specified in cookbook metadata
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate generation

### Security Considerations

- **SSL/TLS Configuration**: Migrate self-signed certificate generation using Ansible's openssl_certificate module
- **Firewall (UFW)**: Use Ansible's community.general.ufw module to configure firewall rules
- **fail2ban**: Use Ansible tasks to install and configure fail2ban
- **SSH Hardening**: Configure SSH security settings using Ansible's template module
- **sysctl Security Settings**: Use Ansible's sysctl module to apply kernel parameter security settings
- **Redis Password**: Securely manage Redis authentication password using Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: Create Ansible templates for multiple virtual hosts with shared SSL configuration
- **Service Dependencies**: Ensure proper ordering of service installation and configuration
- **PostgreSQL User/Database Creation**: Implement idempotent database setup using Ansible's postgresql_* modules
- **Python Environment Management**: Create tasks for Python virtual environment and dependency installation

### Migration Order

1. **Base Infrastructure** (low complexity)
   - System packages installation
   - Security configurations (firewall, fail2ban, sysctl)
   
2. **Nginx Configuration** (moderate complexity)
   - Base Nginx installation and configuration
   - SSL certificate generation
   - Virtual host configuration
   
3. **Caching Services** (moderate complexity)
   - Memcached installation and configuration
   - Redis installation with authentication
   
4. **FastAPI Application** (high complexity)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment and service setup

### Assumptions

1. The target environment will continue to use Fedora as the primary OS, with potential compatibility for Ubuntu and CentOS
2. Self-signed certificates are acceptable for the migrated environment (production would likely require proper certificates)
3. The current security configurations (fail2ban, UFW, SSH hardening) are appropriate for the target environment
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The Redis password "redis_secure_password_123" will need to be stored securely in Ansible Vault
6. The PostgreSQL credentials (user: fastapi, password: fastapi_password) will need to be stored securely in Ansible Vault
7. The current directory structure for web content (/var/www/[site]) and application (/opt/fastapi-tutorial) will be maintained

## Implementation Details

### Ansible Structure

```
ansible/
├── inventory/
│   ├── hosts.yml                  # Host inventory file
│   └── group_vars/                # Group variables
│       ├── all.yml               # Variables for all hosts
│       └── webservers.yml        # Variables for web servers
├── roles/
│   ├── common/                   # Common configurations
│   ├── nginx-multisite/          # Nginx configuration
│   ├── cache/                    # Redis and Memcached
│   └── fastapi-app/              # FastAPI application
├── playbooks/
│   ├── site.yml                  # Main playbook
│   ├── nginx.yml                 # Nginx-specific playbook
│   ├── cache.yml                 # Cache services playbook
│   └── fastapi.yml               # FastAPI application playbook
└── ansible.cfg                   # Ansible configuration
```

### Key Ansible Modules to Use

- **package**: For installing system packages
- **template**: For configuration file templating
- **file/directory**: For file and directory management
- **service**: For service management
- **git**: For application repository cloning
- **command/shell**: For executing commands when necessary
- **openssl_***: For SSL certificate management
- **postgresql_***: For PostgreSQL database management
- **community.general.ufw**: For firewall configuration
- **sysctl**: For kernel parameter configuration

### Testing Strategy

1. Create a Vagrant environment similar to the existing one but using Ansible provisioning
2. Implement incremental testing of each role
3. Validate functionality against the original Chef implementation
4. Perform integration testing of the complete environment

## Timeline Estimate

- **Week 1**: Analysis and role structure setup
- **Week 2**: Implementation of common, nginx-multisite, and cache roles
- **Week 3**: Implementation of fastapi-app role and integration
- **Week 4**: Testing, documentation, and handover

## Migration Risks

1. Differences in idempotency behavior between Chef and Ansible
2. Potential missing edge cases in the original Chef recipes
3. Dependency version compatibility issues
4. Service ordering and dependency management