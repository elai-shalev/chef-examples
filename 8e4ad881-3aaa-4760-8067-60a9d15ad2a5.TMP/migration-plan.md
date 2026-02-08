# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Memcached and Redis) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies to equivalent Ansible roles and playbooks.

**Estimated Timeline:**
- Analysis and Planning: 1 week
- Development of Ansible roles: 2-3 weeks
- Testing and Validation: 1-2 weeks
- Documentation and Knowledge Transfer: 1 week
- Total: 5-7 weeks

**Complexity Assessment:** Medium
- The repository has a clear structure with well-defined cookbooks
- External dependencies on community cookbooks need to be replaced with Ansible Galaxy roles
- Security configurations need careful migration
- Multiple services with interdependencies require coordinated deployment

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured with multiple SSL-enabled virtual hosts, security hardening, and custom site configurations
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw firewall), custom site templates

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database configuration, systemd service management

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket (nginx, memcached, redisio, ssl_certificate)
- `Policyfile.rb`: Defines the Chef policy with run list and cookbook dependencies
- `solo.json`: Contains node attributes for Nginx sites, SSL configuration, and security settings
- `solo.rb`: Chef Solo configuration file
- `Vagrantfile`: Defines a Fedora 42 VM for development/testing with port forwarding and network configuration
- `vagrant-provision.sh`: Shell script to provision the Vagrant VM with Chef

### Target Details

Based on the source repository analysis:

- **Operating System**: Fedora 42 (primary) with support for Ubuntu 18.04+ and CentOS 7+ (based on Vagrantfile and cookbook metadata)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible Galaxy nginx role or direct package installation and configuration
- **memcached (~> 6.0)**: Replace with Ansible Galaxy memcached role or direct package management
- **redisio (~> 7.2.4)**: Replace with Ansible Galaxy redis role or direct package management
- **ssl_certificate (~> 2.1)**: Replace with Ansible's openssl modules for certificate generation

### Security Considerations

- **Firewall (UFW)**: Migrate UFW configuration to Ansible's ufw module
- **Fail2ban**: Migrate fail2ban configuration using Ansible's template module and service management
- **SSH Hardening**: Migrate SSH security configurations using Ansible's lineinfile or template modules
- **SSL Certificates**: Ensure secure handling of SSL certificates and private keys
- **Redis Authentication**: Securely manage Redis password (currently hardcoded as 'redis_secure_password_123')
- **PostgreSQL Authentication**: Securely manage database credentials (currently hardcoded as 'fastapi_password')

### Technical Challenges

- **Multi-site Configuration**: Ensuring the dynamic generation of Nginx site configurations works correctly in Ansible
- **SSL Certificate Management**: Properly handling SSL certificate generation and permissions
- **Service Dependencies**: Maintaining the correct order of service deployment (database before application, etc.)
- **Configuration Templates**: Converting Chef templates to Ansible templates with proper variable substitution
- **Idempotency**: Ensuring all operations are idempotent, especially database user creation and Git repository deployment

### Migration Order

1. **nginx-multisite** (moderate complexity, foundation for web services)
   - Base Nginx installation and configuration
   - Security hardening (fail2ban, ufw)
   - SSL certificate generation
   - Virtual host configuration

2. **cache** (low complexity, independent service)
   - Memcached installation and configuration
   - Redis installation and configuration

3. **fastapi-tutorial** (high complexity, depends on database)
   - PostgreSQL installation and configuration
   - Python environment setup
   - Application deployment
   - Service configuration

### Assumptions

1. The target environment will continue to be Fedora 42 or compatible Linux distributions
2. The same network configuration and port mappings will be maintained
3. Self-signed SSL certificates are acceptable (production would likely use Let's Encrypt or similar)
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git will remain available
5. The current hardcoded credentials will be replaced with Ansible Vault secured variables
6. The same directory structure for web content and application code will be maintained
7. The same service users (www-data, redis, etc.) will be used in the target environment

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       ├── all.yml
│   │       └── webservers.yml
│   └── production/
│       ├── hosts.yml
│       └── group_vars/
│           ├── all.yml
│           └── webservers.yml
├── roles/
│   ├── nginx_multisite/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   └── templates/
│   ├── cache/
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
├── vault_password.txt (gitignored)
└── ansible.cfg
```

## Security Recommendations

1. Use Ansible Vault for all sensitive information:
   - Redis authentication password
   - PostgreSQL credentials
   - SSL private keys (if stored in the repository)

2. Implement more granular user permissions:
   - Create dedicated service users for each application
   - Limit sudo access to only required commands

3. Enhance SSL security:
   - Consider integrating Let's Encrypt for production
   - Implement stronger SSL parameters and ciphers

4. Add additional security measures:
   - SELinux or AppArmor profiles
   - Regular security updates via automated playbooks
   - Centralized logging for security events

## Testing Strategy

1. Develop a Vagrant-based test environment similar to the current setup
2. Create molecule tests for each role
3. Implement integration tests to verify service interactions
4. Perform security scanning on the resulting infrastructure

## Documentation Requirements

1. README with setup instructions and requirements
2. Role-specific documentation for each Ansible role
3. Variable documentation with examples
4. Deployment and rollback procedures