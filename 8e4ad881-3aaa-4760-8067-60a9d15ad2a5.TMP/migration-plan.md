# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The codebase is well-structured with clear separation of concerns
- Security configurations are comprehensive and will require careful migration
- External dependencies on community cookbooks will need Ansible equivalents

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall)

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

- `Berksfile`: Defines cookbook dependencies (nginx, memcached, redisio, ssl_certificate)
- `Policyfile.rb`: Defines the Chef policy with run list and cookbook dependencies
- `solo.json`: Contains node attributes including Nginx site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Shell script to provision the Vagrant VM with Chef

### Target Details

- **Operating System**: Fedora (based on Vagrantfile specifying "generic/fedora42")
- **Virtual Machine Technology**: Vagrant with libvirt provider
- **Cloud Platform**: Not specified, appears to be designed for on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible Galaxy role `geerlingguy.nginx` or custom Ansible role
- **memcached (~> 6.0)**: Replace with Ansible Galaxy role `geerlingguy.memcached`
- **redisio (~> 7.2.4)**: Replace with Ansible Galaxy role `geerlingguy.redis` or `DavidWittman.redis`
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `openssl_*` modules for certificate management

### Security Considerations

- **Firewall (ufw)**: Migrate to Ansible's `ufw` module or `firewalld` module depending on target OS
- **fail2ban**: Use Ansible Galaxy role `geerlingguy.security` or create custom role for fail2ban configuration
- **SSH hardening**: Use Ansible's `lineinfile` module to configure SSH settings or Galaxy role `dev-sec.ssh-hardening`
- **Redis password**: Store in Ansible Vault and reference in templates
- **PostgreSQL credentials**: Store database credentials in Ansible Vault
- **SSL certificates**: Use Ansible's `openssl_*` modules for self-signed certificates or integrate with Let's Encrypt

### Technical Challenges

- **Multi-site configuration**: Ensure Ansible templates properly handle the dynamic site configuration that Chef currently manages
- **Service dependencies**: Maintain proper ordering of service installations and configurations (e.g., PostgreSQL before FastAPI app)
- **Idempotency**: Ensure database creation tasks are idempotent (currently using "|| true" in Chef)
- **Template conversion**: Convert ERB templates to Jinja2 format for Ansible
- **Testing**: Develop equivalent testing strategy using Molecule or similar tools

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Create base Nginx role
   - Implement SSL certificate generation
   - Configure virtual hosts
   - Implement security hardening

2. **cache** (low complexity, standalone service)
   - Configure Memcached
   - Configure Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Configure PostgreSQL
   - Deploy FastAPI application
   - Set up systemd service

### Assumptions

1. The target environment will continue to be Fedora-based systems
2. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt or other CA)
3. The same security hardening measures will be maintained
4. The FastAPI application source will continue to be available at the specified Git repository
5. Redis and Memcached configurations will remain similar
6. The multi-site configuration pattern will be preserved
7. No changes to the application architecture are planned during migration

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
├── roles/
│   ├── nginx-multisite/
│   ├── cache/
│   └── fastapi-tutorial/
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── group_vars/
│   └── all/
│       ├── main.yml
│       └── vault.yml
└── vagrant/
    └── Vagrantfile
```

## Testing Strategy

1. Develop Ansible roles with Molecule for unit testing
2. Use the existing Vagrant setup to test the full deployment
3. Create integration tests to verify:
   - Nginx sites are accessible
   - SSL certificates are valid
   - Security measures are in place
   - Redis and Memcached are operational
   - FastAPI application is running and can connect to PostgreSQL

## Documentation Requirements

1. README with setup instructions
2. Role documentation with all variables
3. Playbook usage examples
4. Vault management procedures
5. Testing procedures