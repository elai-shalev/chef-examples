# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting Chef cookbooks, recipes, templates, and attributes to Ansible roles, playbooks, templates, and variables.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity:** Medium
- The repository has a clear structure with well-defined cookbooks
- No complex custom resources or libraries
- Standard infrastructure components (web server, caching, application deployment)

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled virtual hosts with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw, sysctl)

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

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Defines the run list and cookbook dependencies - will be replaced by Ansible playbook structure
- `solo.json`: Contains node attributes and run list - will be converted to Ansible inventory variables
- `Vagrantfile`: Defines the development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Chef provisioning script - will be replaced by Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile) with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or direct package installation
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (openssl_*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or direct package installation
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct package installation

### Security Considerations

- **SSL Certificate Management**: Self-signed certificates are generated in the Chef cookbook; use Ansible's openssl_* modules for certificate generation
- **Firewall Configuration**: UFW configuration will be migrated to Ansible ufw module
- **Fail2ban Configuration**: Fail2ban setup will be migrated to Ansible templates and service management
- **SSH Hardening**: SSH configuration (disable root login, password authentication) will be migrated to Ansible ssh_config module
- **Redis Authentication**: Redis password is hardcoded in the recipe; should be moved to Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of Nginx site configurations based on node attributes will need to be replicated in Ansible using loops and templates
- **SSL Certificate Generation**: Self-signed certificate generation logic will need to be migrated to Ansible's openssl_* modules
- **Service Dependencies**: Ensuring proper service dependencies and ordering in Ansible (e.g., PostgreSQL before FastAPI application)
- **Redis Configuration Hack**: The Chef cookbook includes a hack to fix Redis configuration; this will need a clean implementation in Ansible

### Migration Order

1. **nginx-multisite** (Priority 1)
   - Core infrastructure component that other services depend on
   - Contains security configurations that should be established first

2. **cache** (Priority 2)
   - Dependent services that the application will use
   - Moderate complexity with Redis authentication

3. **fastapi-tutorial** (Priority 3)
   - Application deployment that depends on other infrastructure components
   - Involves database setup, application deployment, and service configuration

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems
2. Self-signed certificates are acceptable for development/testing (production would likely use different certificate management)
3. The current security configurations are appropriate for the target environment
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The current Redis password and PostgreSQL credentials are for development only and will be replaced with secure values in production
6. The current directory structure in the target system (/opt/fastapi-tutorial, /var/www/*, etc.) should be maintained

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventory/
│   ├── group_vars/
│   │   ├── all.yml          # Common variables
│   │   └── webservers.yml   # Web server specific variables
│   └── hosts                # Inventory file
├── roles/
│   ├── nginx-multisite/     # Nginx multi-site configuration
│   ├── cache/               # Redis and Memcached
│   └── fastapi-tutorial/    # FastAPI application
├── playbooks/
│   ├── site.yml             # Main playbook
│   ├── nginx.yml            # Nginx specific playbook
│   ├── cache.yml            # Cache services playbook
│   └── fastapi.yml          # FastAPI application playbook
├── requirements.yml         # Ansible Galaxy requirements
└── Vagrantfile              # For local testing
```

## Security Recommendations

1. Move all sensitive data (passwords, keys) to Ansible Vault
2. Implement proper certificate management for production
3. Consider using Ansible's crypto modules for more secure key generation
4. Review and possibly enhance the current security configurations
5. Implement proper secret rotation mechanisms