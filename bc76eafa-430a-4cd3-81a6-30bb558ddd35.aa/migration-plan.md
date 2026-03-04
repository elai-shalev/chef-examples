# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This migration plan outlines the process of converting a Chef-based infrastructure to Ansible. The repository contains three primary Chef cookbooks (nginx-multisite, cache, and fastapi-tutorial) with dependencies on external cookbooks from the Chef Supermarket. The infrastructure appears to be a web application environment with Nginx serving multiple SSL-enabled sites, caching services (Redis and Memcached), and a FastAPI Python application with PostgreSQL database.

Based on the complexity and scope of the existing Chef cookbooks, this migration is estimated to require approximately 3-4 weeks of development effort, with an additional 1-2 weeks for testing and validation.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled subdomains, security hardening, and site-specific configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site SSL configuration, security hardening (fail2ban, ufw), self-signed certificate generation

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

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket (nginx, memcached, redisio)
- `Policyfile.rb`: Defines the Chef policy with run list and cookbook dependencies
- `solo.json`: Contains node attributes for Nginx sites, SSL configuration, and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Shell script for provisioning the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: The cookbooks support both Ubuntu (>= 18.04) and CentOS (>= 7.0), with the Vagrantfile specifying Fedora 42 as the development environment.
- **Virtual Machine Technology**: Vagrant with libvirt provider is used for development/testing.
- **Cloud Platform**: No specific cloud platform configurations were identified. The setup appears to be designed for on-premises or generic VM deployment.

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role or community.general.nginx_* modules
- **memcached (~> 6.0)**: Replace with Ansible memcached role or package installation tasks
- **redisio (~> 7.2.4)**: Replace with Ansible redis role or package installation tasks
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl_* modules for certificate management

### Security Considerations

- **fail2ban configuration**: Migrate using Ansible's package and template modules to configure fail2ban
- **ufw firewall rules**: Replace with Ansible's ufw module or firewalld module depending on target OS
- **SSH hardening**: Use Ansible's lineinfile or template module to configure SSH security settings
- **Redis password**: Use Ansible Vault to securely store the Redis password
- **SSL certificates**: Use Ansible's openssl_* modules to generate and manage certificates
- **PostgreSQL credentials**: Use Ansible Vault to securely store database credentials

### Technical Challenges

- **Multi-site Nginx configuration**: Creating a flexible Ansible role that can handle multiple sites with different SSL configurations
- **Self-signed certificate generation**: Implementing certificate generation logic in Ansible
- **Redis configuration**: Ensuring compatibility with different Redis versions across distributions
- **FastAPI deployment**: Managing Python virtual environments and dependencies in Ansible
- **Service orchestration**: Ensuring proper service start order and dependencies

### Migration Order

1. **cache cookbook** (low complexity, foundational service)
   - Implement Redis and Memcached configuration
   - Test caching services independently

2. **nginx-multisite cookbook** (moderate complexity, core infrastructure)
   - Implement base Nginx configuration
   - Implement SSL certificate generation
   - Configure multiple virtual hosts
   - Implement security hardening

3. **fastapi-tutorial cookbook** (high complexity, application layer)
   - Implement PostgreSQL database setup
   - Configure Python environment and dependencies
   - Deploy application code
   - Configure systemd service

### Assumptions

- The target environment will continue to support both Ubuntu and CentOS/RHEL-based distributions
- Self-signed certificates are acceptable for development, but production may require integration with Let's Encrypt or other certificate authorities
- The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
- The current security configurations (fail2ban, ufw, SSH hardening) are appropriate for the target environment
- Redis authentication is required in the new environment
- The PostgreSQL database will be hosted on the same server as the application

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
│   ├── nginx_multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   ├── cache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   └── fastapi_app/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       ├── templates/
│       └── vars/
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

## Implementation Details

### nginx_multisite Role

Key tasks to implement:
- Install Nginx package
- Configure Nginx main configuration
- Generate self-signed SSL certificates
- Create site configuration templates
- Configure security settings (fail2ban, ufw)
- Configure system security settings

### cache Role

Key tasks to implement:
- Install and configure Memcached
- Install and configure Redis with password authentication
- Configure service dependencies and startup

### fastapi_app Role

Key tasks to implement:
- Install Python and system dependencies
- Clone application repository
- Set up Python virtual environment
- Install Python dependencies
- Configure PostgreSQL database
- Create environment configuration
- Configure systemd service

## Testing Strategy

1. Create Vagrant-based test environment similar to the existing setup
2. Implement molecule tests for each role
3. Test roles individually before integration
4. Test complete playbook against development environment
5. Validate functionality against original Chef implementation

## Timeline Estimate

- **Week 1**: Analysis and role structure setup
- **Week 2**: Implement cache and nginx_multisite roles
- **Week 3**: Implement fastapi_app role and integration
- **Week 4**: Testing, documentation, and refinement
- **Week 5**: Validation and production deployment preparation