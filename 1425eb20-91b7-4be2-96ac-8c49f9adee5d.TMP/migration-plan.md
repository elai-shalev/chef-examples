# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server setup with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security settings. The estimated complexity is moderate, with an expected timeline of 3-4 weeks for complete migration, testing, and documentation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificates
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, ufw, sysctl)

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment, Git repository deployment, PostgreSQL database setup, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines the run list and cookbook dependencies - will be replaced by Ansible playbook structure
- `solo.json`: Contains node configuration data - will be migrated to Ansible inventory variables
- `Vagrantfile`: Defines the development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Installs Chef and runs cookbooks - will be replaced by Ansible provisioning

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or direct package installation and configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules for certificate generation
- **memcached (~> 6.0)**: Replace with Ansible memcached role or direct package installation
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct package installation and configuration

### Security Considerations

- **SSL/TLS Configuration**: Migrate self-signed certificate generation and configuration, ensuring proper file permissions
- **Firewall (ufw)**: Migrate firewall rules using Ansible's ufw or firewalld modules depending on target OS
- **fail2ban**: Migrate fail2ban configuration using Ansible's template module
- **SSH Hardening**: Migrate SSH security configurations (disable root login, password authentication)
- **System Hardening**: Migrate sysctl security settings
- **Redis Authentication**: Ensure Redis password is properly handled in Ansible Vault
- **PostgreSQL Authentication**: Secure database credentials using Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: Ensure the Nginx multi-site configuration is properly templated in Ansible
- **SSL Certificate Management**: Properly handle certificate generation and renewal processes
- **Service Dependencies**: Maintain proper ordering of service installations and configurations
- **Idempotency**: Ensure all operations are idempotent, particularly database user creation and application deployment
- **Environment Variables**: Properly manage environment variables for the FastAPI application

### Migration Order

1. Base infrastructure (nginx-multisite) - foundation for other components
2. Caching services (cache cookbook) - middleware layer
3. Application deployment (fastapi-tutorial) - depends on infrastructure and database

### Assumptions

1. The target environment will continue to be Fedora/RHEL-based systems
2. Self-signed certificates are acceptable for development (production would require proper CA-signed certificates)
3. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
4. The current security configurations are appropriate for the target environment
5. No custom Chef resources are being used that would require special handling
6. The current directory structure in the target environment (/opt/fastapi-tutorial, /etc/ssl/*, etc.) should be maintained

## Ansible Structure Plan

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       └── all.yml  # Variables from solo.json
│   └── production/
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/main.yml  # From cookbook attributes
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── nginx.yml
│   │   │   ├── security.yml
│   │   │   ├── ssl.yml
│   │   │   └── sites.yml
│   │   └── templates/
│   │       ├── nginx.conf.j2
│   │       ├── security.conf.j2
│   │       ├── site.conf.j2
│   │       ├── fail2ban.jail.local.j2
│   │       └── sysctl-security.conf.j2
│   ├── cache/
│   │   ├── defaults/main.yml
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── memcached.yml
│   │   │   └── redis.yml
│   │   └── templates/
│   │       └── redis.conf.j2
│   └── fastapi-tutorial/
│       ├── defaults/main.yml
│       ├── tasks/
│       │   ├── main.yml
│       │   ├── app.yml
│       │   └── database.yml
│       └── templates/
│           ├── env.j2
│           └── fastapi-tutorial.service.j2
├── playbooks/
│   ├── site.yml          # Main playbook
│   ├── nginx.yml         # Individual component playbooks
│   ├── cache.yml
│   └── fastapi.yml
├── requirements.yml      # Ansible Galaxy requirements
└── Vagrantfile           # For testing
```

## Testing Strategy

1. Create Vagrant environment similar to current setup but using Ansible provisioner
2. Implement automated tests for each role
3. Verify all sites are accessible and properly configured
4. Test security configurations
5. Validate application functionality

## Documentation Requirements

1. README with setup instructions
2. Role documentation
3. Variable documentation
4. Security considerations
5. Deployment guide