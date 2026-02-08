# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx setup with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, security configurations, and service deployments. Based on the complexity and scope, this migration is estimated to require 3-4 weeks with 1-2 dedicated engineers.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Multi-site Nginx configuration with SSL support, security hardening, and virtual host management for multiple subdomains
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: SSL certificate generation, UFW firewall configuration, Fail2ban integration, multiple virtual hosts with separate document roots

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Git repository deployment, Python virtual environment setup, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management file listing cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy file defining the run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Configuration data for Chef Solo with site configurations and security settings - will be migrated to Ansible variables
- `Vagrantfile`: VM configuration for development and testing - can be adapted for Ansible testing
- `vagrant-provision.sh`: Provisioning script for Vagrant - will be replaced by Ansible provisioning
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration

### Target Details

Based on the source configuration files:

- **Operating System**: Fedora 42 (from Vagrantfile), with support for Ubuntu 18.04+ and CentOS 7+ (from cookbook metadata)
- **Virtual Machine Technology**: libvirt (from Vagrantfile)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **ssl_certificate (~> 2.1)**: Replace with Ansible crypto modules (community.crypto.openssl_*)
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or direct configuration tasks

### Security Considerations

- **Fail2ban configuration**: Migrate fail2ban jail configuration to Ansible templates
- **UFW firewall rules**: Use Ansible UFW module to configure firewall rules
- **SSH hardening**: Implement SSH configuration using Ansible's lineinfile or template modules
- **SSL certificates**: Use Ansible's crypto modules for certificate generation and management
- **Redis password**: Store Redis password in Ansible Vault for secure management
- **PostgreSQL credentials**: Store database credentials in Ansible Vault

### Technical Challenges

- **Custom resource (lineinfile)**: The custom Chef resource will need to be replaced with Ansible's native lineinfile module
- **Ruby blocks for configuration fixes**: The Ruby block for fixing Redis configuration will need to be converted to Ansible's lineinfile or replace module
- **Multi-site configuration**: The dynamic site configuration will require careful templating in Ansible
- **Service dependencies**: Ensuring proper service ordering and dependencies in Ansible

### Migration Order

1. **nginx-multisite cookbook** (moderate complexity, foundation for other services)
   - Basic Nginx installation and configuration
   - SSL certificate generation
   - Virtual host configuration
   - Security hardening (fail2ban, UFW)

2. **cache cookbook** (moderate complexity)
   - Memcached configuration
   - Redis installation and configuration

3. **fastapi-tutorial cookbook** (high complexity, depends on other services)
   - PostgreSQL database setup
   - Python environment configuration
   - Application deployment
   - Service configuration

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. The same network configuration (ports 80/443) will be maintained
3. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt)
4. The FastAPI application repository will remain available at the specified URL
5. The current security configurations (fail2ban, UFW, SSH hardening) are appropriate for the target environment
6. Redis password and PostgreSQL credentials will need to be securely managed in the new Ansible setup
7. The current directory structure for web content (/opt/server/[site]) will be maintained

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all.yml  # Development environment variables
│   │   └── hosts        # Development inventory
│   └── production/
│       ├── group_vars/
│       │   └── all.yml  # Production environment variables
│       └── hosts        # Production inventory
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   ├── files/
│   │   │   ├── ci/
│   │   │   ├── status/
│   │   │   └── test/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── nginx.yml
│   │   │   ├── security.yml
│   │   │   ├── sites.yml
│   │   │   └── ssl.yml
│   │   ├── templates/
│   │   └── vars/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── memcached.yml
│   │   │   └── redis.yml
│   │   ├── templates/
│   │   └── vars/
│   └── fastapi-tutorial/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       │   ├── main.yml
│       │   ├── app.yml
│       │   └── database.yml
│       ├── templates/
│       └── vars/
├── playbooks/
│   ├── site.yml        # Main playbook
│   ├── nginx.yml       # Nginx-specific playbook
│   ├── cache.yml       # Cache services playbook
│   └── fastapi.yml     # FastAPI application playbook
├── requirements.yml    # Ansible Galaxy requirements
└── Vagrantfile         # For local testing
```

## Testing Strategy

1. Create unit tests for each role using Molecule
2. Implement integration testing using Vagrant with the same VM configuration
3. Verify each component individually before combining them
4. Test the complete stack deployment to ensure all services work together properly

## Timeline Estimate

- **Week 1**: Analysis and role structure setup, basic Nginx configuration
- **Week 2**: Security configurations, SSL, and cache services implementation
- **Week 3**: FastAPI application deployment and database configuration
- **Week 4**: Testing, documentation, and refinement

Total estimated effort: 3-4 weeks with 1-2 dedicated engineers