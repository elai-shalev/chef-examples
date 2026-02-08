# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security settings. Based on the complexity and scope, this migration is estimated to require 3-4 weeks with a team of 2 engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and self-signed certificate generation
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL/TLS setup, security hardening (fail2ban, UFW firewall), sysctl security settings

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

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines the run list and cookbook dependencies - will be replaced by Ansible playbook structure
- `solo.json`: Contains node configuration data - will be migrated to Ansible inventory variables
- `Vagrantfile`: Defines the development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Installs Chef and runs the cookbooks - will be replaced by Ansible provisioning
- `solo.rb`: Chef configuration file - no direct Ansible equivalent needed

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: Libvirt (from Vagrantfile)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or direct package installation and configuration
- **memcached (~> 6.0)**: Replace with Ansible memcached role or direct package installation and configuration
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or direct package installation and configuration
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate generation tasks or community roles

### Security Considerations

- **SSL/TLS Configuration**: Migrate self-signed certificate generation and secure TLS configuration
- **fail2ban**: Implement fail2ban configuration using Ansible
- **UFW Firewall**: Configure UFW using Ansible modules
- **SSH Hardening**: Migrate SSH security settings (disable root login, disable password authentication)
- **Sysctl Security**: Migrate sysctl security settings
- **Redis Authentication**: Ensure Redis password is securely managed in Ansible Vault
- **PostgreSQL Authentication**: Ensure database credentials are securely managed in Ansible Vault

### Technical Challenges

- **Multi-site Configuration**: The dynamic generation of multiple Nginx sites will need careful implementation in Ansible
- **SSL Certificate Management**: Self-signed certificate generation and management will need proper implementation
- **Service Dependencies**: Ensuring proper service ordering and dependencies (e.g., PostgreSQL before FastAPI application)
- **Template Conversion**: Converting ERB templates to Jinja2 format for Ansible
- **Security Hardening**: Ensuring all security measures are properly implemented in Ansible

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Base Nginx installation and configuration
   - SSL certificate generation
   - Virtual host configuration
   - Security hardening (fail2ban, UFW)

2. **cache** (low complexity, independent service)
   - Memcached configuration
   - Redis installation and security configuration

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - PostgreSQL installation and configuration
   - Python environment setup
   - Application deployment
   - Systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. Self-signed certificates are acceptable for the migrated environment (production would likely use Let's Encrypt or other CA)
3. The security requirements will remain the same (fail2ban, UFW, SSH hardening)
4. The FastAPI application repository will remain available at the specified URL
5. Redis and Memcached configurations will remain similar
6. The Nginx virtual hosts (test.cluster.local, ci.cluster.local, status.cluster.local) will remain the same

## Ansible Structure Plan

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       └── all.yml  # Variables from solo.json
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
│           └── all.yml
├── roles/
│   ├── nginx-multisite/
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── nginx.yml
│   │   │   ├── ssl.yml
│   │   │   ├── sites.yml
│   │   │   └── security.yml
│   │   ├── templates/
│   │   │   ├── nginx.conf.j2
│   │   │   ├── security.conf.j2
│   │   │   ├── site.conf.j2
│   │   │   ├── fail2ban.jail.local.j2
│   │   │   └── sysctl-security.conf.j2
│   │   ├── files/
│   │   │   ├── test/
│   │   │   │   └── index.html
│   │   │   ├── ci/
│   │   │   │   └── index.html
│   │   │   └── status/
│   │   │       └── index.html
│   │   └── defaults/
│   │       └── main.yml  # From attributes/default.rb
│   ├── cache/
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── memcached.yml
│   │   │   └── redis.yml
│   │   ├── templates/
│   │   │   └── redis.conf.j2
│   │   └── defaults/
│   │       └── main.yml
│   └── fastapi-tutorial/
│       ├── tasks/
│       │   ├── main.yml
│       │   ├── postgresql.yml
│       │   └── app.yml
│       ├── templates/
│       │   ├── fastapi-tutorial.service.j2
│       │   └── env.j2
│       └── defaults/
│           └── main.yml
├── playbooks/
│   ├── site.yml  # Main playbook
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── requirements.yml  # Ansible Galaxy requirements
└── Vagrantfile  # For testing
```

## Testing Strategy

1. Create Ansible roles and playbooks according to the structure above
2. Use Vagrant with the same VM configuration for testing
3. Test each role individually before integration
4. Verify functionality matches the original Chef implementation
5. Perform security testing to ensure all hardening measures are properly implemented
6. Document any differences or improvements in the Ansible implementation

## Documentation Requirements

1. README.md with setup and usage instructions
2. Role-specific documentation
3. Variable documentation
4. Security considerations and best practices
5. Testing procedures