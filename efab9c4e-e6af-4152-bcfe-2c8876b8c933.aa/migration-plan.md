# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services and a FastAPI application. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, security configurations, and service deployments. The estimated timeline for migration is 2-3 weeks, with moderate complexity due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and fail2ban integration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Self-signed SSL certificates, multi-site configuration, security headers, fail2ban integration, UFW firewall

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment, Git repository deployment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Chef policy configuration - will be replaced by Ansible playbook structure
- `Vagrantfile`: Development environment configuration - can be adapted for Ansible testing
- `solo.json`: Chef node configuration - will be converted to Ansible inventory variables
- `solo.rb`: Chef configuration - will be replaced by ansible.cfg
- `vagrant-provision.sh`: Provisioning script - will be replaced by Ansible playbook calls

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile)
- **Cloud Platform**: Not specified, appears to be targeting on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible openssl_* modules for certificate management

### Security Considerations

- **SSL Certificate Management**: Migrate self-signed certificate generation to Ansible's openssl_certificate module
- **Fail2ban Configuration**: Convert fail2ban jail configuration to Ansible templates
- **UFW Firewall Rules**: Use Ansible's ufw module to configure firewall rules
- **SSH Hardening**: Implement SSH security configurations using Ansible's lineinfile or template modules
- **Security Headers**: Ensure Nginx security headers are preserved in the Ansible templates
- **Redis Authentication**: Securely manage Redis password using Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: Ensure the dynamic generation of multiple Nginx virtual hosts is properly implemented in Ansible
- **SSL Certificate Management**: Properly handle SSL certificate generation and renewal processes
- **Service Dependencies**: Maintain proper ordering of service installations and configurations
- **PostgreSQL User/DB Creation**: Ensure idempotent database and user creation in Ansible
- **Python Environment Management**: Properly handle Python virtual environment creation and dependency installation

### Migration Order

1. **Base Infrastructure** (low risk, foundation)
   - Basic Nginx installation
   - System security configurations (fail2ban, UFW)
   
2. **Nginx Multi-site Configuration** (moderate complexity)
   - Virtual host configuration
   - SSL certificate generation
   - Security headers
   
3. **Caching Services** (moderate complexity)
   - Memcached configuration
   - Redis with authentication
   
4. **FastAPI Application** (high complexity, dependencies)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment
   - Systemd service configuration

### Assumptions

1. The target environment will continue to use the same operating systems (Fedora/Ubuntu/CentOS)
2. Self-signed certificates are acceptable for development; production would require proper certificates
3. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
4. The security requirements (fail2ban, UFW, SSH hardening) will remain the same
5. The current Redis password ("redis_secure_password_123") will need to be securely stored in Ansible Vault
6. The PostgreSQL credentials (user: "fastapi", password: "fastapi_password") will need to be securely stored

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── ansible.cfg
├── inventory/
│   ├── group_vars/
│   │   ├── all.yml
│   │   └── webservers.yml
│   └── hosts
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
└── Vagrantfile
```

## Testing Strategy

1. Create individual role tests using Molecule
2. Implement integration testing with Vagrant
3. Verify security configurations with appropriate scanning tools
4. Test SSL certificate generation and renewal
5. Validate multi-site functionality and security headers

## Timeline Estimate

- **Analysis and Planning**: 2-3 days
- **Role Development**: 5-7 days
- **Integration and Testing**: 3-5 days
- **Documentation and Knowledge Transfer**: 1-2 days

Total estimated time: 2-3 weeks