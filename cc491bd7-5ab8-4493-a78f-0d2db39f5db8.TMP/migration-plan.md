# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The Chef cookbooks are well-structured and follow standard patterns
- Security configurations are comprehensive but straightforward
- External dependencies on community cookbooks will need Ansible equivalents

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled websites with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall)

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git-based deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy configuration - will be replaced by Ansible playbook structure
- `solo.json`: Chef node configuration - will be replaced by Ansible inventory and variable files
- `solo.rb`: Chef configuration file - no direct Ansible equivalent needed
- `Vagrantfile`: VM configuration for testing - can be adapted for Ansible testing with minimal changes
- `vagrant-provision.sh`: Provisioning script - will be replaced by Ansible provisioning in Vagrantfile

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile configuration)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role (e.g., geerlingguy.nginx)
- **memcached (~> 6.0)**: Replace with Ansible memcached role (e.g., geerlingguy.memcached)
- **redisio (~> 7.2.4)**: Replace with Ansible redis role (e.g., geerlingguy.redis)
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management tasks or community roles

### Security Considerations

- **Firewall (ufw)**: Migrate to Ansible firewall module (ansible.posix.firewalld for Fedora)
- **Fail2ban**: Migrate to Ansible fail2ban role or direct configuration
- **SSL Certificate Management**: Use Ansible crypto modules for certificate generation
- **SSH Hardening**: Use Ansible to configure SSH security settings
- **Redis Authentication**: Ensure Redis password is stored securely in Ansible Vault
- **PostgreSQL Authentication**: Store database credentials in Ansible Vault

### Technical Challenges

- **Multi-site Nginx Configuration**: Create a flexible Ansible role that can generate site configurations from variables
- **SSL Certificate Generation**: Implement proper certificate management with Ansible crypto modules
- **Service Dependencies**: Ensure proper ordering of service deployments (e.g., PostgreSQL before FastAPI app)
- **Python Environment Management**: Create idempotent Ansible tasks for Python virtual environment setup
- **Configuration Templates**: Convert Chef templates to Ansible Jinja2 templates

### Migration Order

1. **nginx-multisite** (Priority 1)
   - Core infrastructure component that other services depend on
   - Start with basic Nginx installation and configuration
   - Add multi-site and SSL capabilities
   - Implement security hardening

2. **cache** (Priority 2)
   - Implement Memcached configuration
   - Implement Redis with authentication
   - Ensure proper integration with Nginx

3. **fastapi-tutorial** (Priority 3)
   - Set up PostgreSQL database
   - Deploy Python application with virtual environment
   - Configure systemd service
   - Integrate with Nginx and caching services

### Assumptions

1. The target environment will continue to be Fedora-based systems
2. The same network configuration and port mappings will be maintained
3. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt)
4. The FastAPI application repository will remain available at the specified URL
5. Redis and PostgreSQL passwords in the Chef recipes are placeholders and will be replaced with secure values
6. The current security configurations (fail2ban, ufw, SSH hardening) are appropriate for the target environment
7. The Nginx sites configuration (test.cluster.local, ci.cluster.local, status.cluster.local) will remain the same

## Ansible Structure Recommendation

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
│   ├── nginx_multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   ├── cache_services/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   └── fastapi_app/
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

1. Create Ansible Molecule tests for each role
2. Update Vagrantfile to use Ansible provisioner
3. Implement integration tests to verify:
   - Nginx serves all configured sites with SSL
   - Caching services are running and properly configured
   - FastAPI application is deployed and accessible
   - Security configurations are properly applied

## Documentation Requirements

1. README.md with setup and usage instructions
2. Role-specific documentation for each Ansible role
3. Variable documentation for all configurable options
4. Example playbooks for common deployment scenarios