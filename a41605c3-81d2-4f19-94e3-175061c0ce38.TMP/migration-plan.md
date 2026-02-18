# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure configuration for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three primary cookbooks with their dependencies, configuration templates, and security hardening settings.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible Roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- Well-structured Chef cookbooks with clear separation of concerns
- Standard package installations and configurations
- Some security hardening that will need careful translation
- Secrets management needs improvement in the Ansible implementation

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured to host multiple SSL-enabled virtual hosts with security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall), sysctl security settings

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks, lists external dependencies from Chef Supermarket
- `Policyfile.rb`: Chef Policyfile defining the run list and cookbook dependencies
- `solo.json`: Configuration data for Chef Solo, contains site configurations and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and networking
- `vagrant-provision.sh`: Shell script to provision the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Supports both Ubuntu (>= 18.04) and CentOS (>= 7.0) based on cookbook metadata. The Vagrantfile uses Fedora 42, suggesting RHEL-family compatibility is important.
- **Virtual Machine Technology**: Vagrant with libvirt provider, suggesting KVM virtualization.
- **Cloud Platform**: No explicit cloud provider dependencies found. The configuration appears to be designed for on-premises or generic cloud VMs.

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible `nginx` role or community.general collection
- **ssl_certificate (~> 2.1)**: Replace with Ansible `openssl_*` modules for certificate management
- **memcached (~> 6.0)**: Replace with Ansible memcached role or direct package installation
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role or direct package installation

### Security Considerations

- **fail2ban configuration**: Migrate fail2ban jail configuration to Ansible templates
- **ufw firewall rules**: Replace with Ansible `ufw` module or `firewalld` for RHEL-based systems
- **SSH hardening**: Migrate SSH configuration hardening to Ansible using `lineinfile` or templates
- **sysctl security settings**: Migrate to Ansible `sysctl` module
- **Redis password**: Currently hardcoded in recipe, should be moved to Ansible Vault
- **PostgreSQL credentials**: Currently hardcoded in recipe, should be moved to Ansible Vault

### Technical Challenges

- **SSL Certificate Generation**: Chef cookbook generates self-signed certificates; need to implement equivalent functionality in Ansible using the `openssl_*` modules
- **Multi-site Configuration**: Need to carefully translate the Nginx site configuration templating to Ansible
- **Redis Configuration Hack**: The Chef cookbook includes a hack to fix Redis configuration; need to ensure proper Redis configuration in Ansible
- **FastAPI Application Deployment**: Need to ensure proper Python virtual environment setup and application deployment

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for other services)
   - Create base Nginx role
   - Implement SSL certificate generation
   - Implement virtual host configuration
   - Implement security hardening

2. **cache** (low complexity, standalone service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial** (high complexity, depends on PostgreSQL)
   - Implement PostgreSQL installation and configuration
   - Implement Python environment setup
   - Implement application deployment
   - Implement systemd service configuration

### Assumptions

1. The target environment will continue to be either Ubuntu (>= 18.04) or CentOS (>= 7.0) or Fedora
2. Self-signed SSL certificates are acceptable for the migrated solution
3. The same security hardening requirements will apply to the Ansible implementation
4. The FastAPI application source will continue to be available at the specified Git repository
5. The Redis and PostgreSQL passwords in the Chef recipes are development passwords and will be replaced with proper secrets management in Ansible
6. The Nginx site configuration structure will remain similar (test.cluster.local, ci.cluster.local, status.cluster.local)
7. The current Chef implementation does not use encrypted data bags or other secret management, so no existing secrets need to be migrated

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all/
│   │   │       ├── vars.yml
│   │   │       └── vault.yml
│   │   └── hosts.yml
│   └── production/
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
└── vagrant/
    └── Vagrantfile
```

## Security Improvements

1. Move hardcoded passwords to Ansible Vault
2. Implement more granular firewall rules
3. Consider using Let's Encrypt for SSL certificates instead of self-signed certificates
4. Implement more comprehensive SSH hardening
5. Add SELinux/AppArmor configuration for additional security

## Testing Strategy

1. Create Vagrant environment similar to the existing one for development testing
2. Implement molecule tests for individual roles
3. Create integration tests to verify the complete stack works together
4. Test on both Ubuntu and CentOS/Fedora to ensure cross-platform compatibility