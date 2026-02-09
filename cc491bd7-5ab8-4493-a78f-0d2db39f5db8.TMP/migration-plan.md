# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server setup with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL backend. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, templates, and attributes to equivalent Ansible roles and playbooks.

**Estimated Timeline:** 3-4 weeks
**Complexity:** Medium
**Target Environment:** Fedora/RHEL-based systems with support for Ubuntu/CentOS

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and fail2ban/ufw configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security headers, firewall configuration

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy definition - will be replaced by Ansible playbook structure
- `Vagrantfile`: Development environment definition - can be adapted for Ansible testing
- `solo.json`: Chef node configuration - will be converted to Ansible inventory variables
- `vagrant-provision.sh`: Provisioning script - will be replaced by Ansible provisioning

### Target Details

- **Operating System**: Fedora 42 (primary), with support for Ubuntu 18.04+ and CentOS 7+
- **Virtual Machine Technology**: libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible community.general.nginx or builtin nginx modules
- **memcached (~> 6.0)**: Replace with Ansible community.general.memcached module
- **redisio (~> 7.2.4)**: Replace with Ansible community.redis collection
- **ssl_certificate (~> 2.1)**: Replace with Ansible community.crypto collection for certificate management

### Security Considerations

- **SSL Certificate Management**: Self-signed certificates are generated in the Chef cookbook; use Ansible's crypto modules for certificate generation
- **Firewall Configuration**: UFW configuration will need to be migrated to Ansible's ufw module
- **Fail2ban Setup**: Convert fail2ban configuration to Ansible's fail2ban modules
- **SSH Hardening**: SSH security settings need to be migrated to Ansible's ssh_config module
- **Security Headers**: Nginx security headers configuration needs to be preserved in templates
- **Redis Authentication**: Redis password is hardcoded in the recipe; should be moved to Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of multiple Nginx sites will need careful translation to Ansible templates and loops
- **Service Dependencies**: Ensuring proper ordering of service installation, configuration, and startup
- **SSL Certificate Generation**: Self-signed certificate generation logic needs to be replicated
- **PostgreSQL User/DB Creation**: Converting PostgreSQL user and database creation to idempotent Ansible tasks
- **Python Environment Setup**: Ensuring proper Python virtual environment setup and dependency installation

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Start with basic Nginx installation and configuration
   - Add SSL certificate generation
   - Implement security configurations (fail2ban, ufw)
   - Configure virtual hosts

2. **cache** (low complexity, standalone service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Set up PostgreSQL database
   - Configure Python environment
   - Deploy application code
   - Set up systemd service

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems with support for Ubuntu/CentOS
2. Self-signed certificates are acceptable for development; production would require proper certificate management
3. The current security configurations (fail2ban, ufw, SSH hardening) are appropriate for the target environment
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The current Redis password ("redis_secure_password_123") and PostgreSQL credentials are for development only and will be replaced with secure values in production
6. The current directory structure for web content (/var/www/[domain]) will be maintained
7. The current Nginx configuration with security headers and SSL settings will be preserved

## Ansible Structure Plan

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       └── all.yml
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
│           └── all.yml
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── files/
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
├── requirements.yml
└── Vagrantfile
```

## Testing Strategy

1. Develop and test each role individually using Molecule
2. Create integration tests to verify interactions between roles
3. Use the existing Vagrantfile as a basis for testing the complete deployment
4. Verify functionality against the original Chef deployment

## Documentation Requirements

1. README.md with setup instructions
2. Role-specific documentation
3. Variable documentation
4. Deployment guide