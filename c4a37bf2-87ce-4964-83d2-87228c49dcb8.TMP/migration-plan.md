# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure to Ansible. The repository contains three Chef cookbooks that manage a multi-site Nginx web server, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL. The estimated complexity is moderate, with an expected timeline of 3-4 weeks for complete migration, including testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw), sysctl security settings

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

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket (nginx, ssl_certificate, memcached, redisio)
- `Policyfile.rb`: Defines the run list and cookbook dependencies
- `solo.json`: Contains node attributes for Nginx sites, SSL configuration, and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Bash script for provisioning the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora/RHEL-based (Fedora 42 specified in Vagrantfile)
- **Virtual Machine Technology**: Libvirt (specified in Vagrantfile)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (community.crypto.*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or direct configuration

### Security Considerations

- **SSL Certificate Management**: Migration must preserve secure certificate generation and storage
  - Use Ansible's crypto modules for certificate generation
  - Maintain proper file permissions for private keys
  
- **Firewall Configuration (UFW)**: Preserve security rules
  - Use Ansible's ufw module to configure firewall rules
  - Ensure default deny policy is maintained
  
- **fail2ban Configuration**: Maintain intrusion prevention
  - Use Ansible to deploy fail2ban configuration
  - Ensure jail settings are preserved
  
- **SSH Hardening**: Maintain secure SSH configuration
  - Use Ansible to configure sshd_config with secure settings
  - Preserve settings for root login and password authentication
  
- **Redis Authentication**: Maintain password protection
  - Ensure Redis password is securely stored (consider Ansible Vault)
  - Configure Redis with authentication in Ansible

### Technical Challenges

- **Multi-site Nginx Configuration**: The Chef cookbook dynamically generates site configurations
  - Solution: Use Ansible templates with loops to generate site configurations
  - Ensure SSL certificate paths are consistent
  
- **PostgreSQL User/Database Setup**: The Chef cookbook uses inline SQL commands
  - Solution: Use Ansible's postgresql_* modules for more idempotent management
  - Ensure database credentials are securely stored
  
- **Python Application Deployment**: The Chef cookbook manages a virtual environment and service
  - Solution: Use Ansible's pip module for Python dependencies
  - Use Ansible's git and systemd modules for deployment and service management

### Migration Order

1. **cache cookbook** (Low complexity)
   - Simple Redis and Memcached configuration
   - Few dependencies on other components
   
2. **nginx-multisite cookbook** (Medium complexity)
   - Core web server functionality
   - Security configurations
   - SSL certificate management
   
3. **fastapi-tutorial cookbook** (High complexity)
   - Application deployment
   - Database configuration
   - Service management

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems
2. The same security requirements will apply in the new environment
3. The multi-site configuration pattern will be maintained
4. Self-signed certificates are acceptable for development (production would likely use different certificates)
5. The FastAPI application repository will remain available at the specified URL
6. The Redis password in the Chef cookbook is for development and will be replaced with a secure password in production

## Ansible Structure Recommendation

```
ansible-project/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── tasks/
│   │   └── templates/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi-tutorial/
│       ├── defaults/
│       ├── tasks/
│       └── templates/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
└── group_vars/
    └── all/
        ├── vars.yml
        └── vault.yml
```

## Testing Strategy

1. Create Vagrant environment similar to the existing one
2. Develop and test each role individually
3. Integrate roles and test complete deployment
4. Verify functionality matches the original Chef deployment
5. Perform security scanning to ensure hardening measures are effective

## Documentation Requirements

1. README with setup instructions
2. Role documentation with variable descriptions
3. Inventory setup guide
4. Vault usage instructions for secrets management