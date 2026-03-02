# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application backed by PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security hardening features.

**Estimated Timeline:** 2-3 weeks
**Complexity:** Medium
**Team Size Recommendation:** 1-2 DevOps engineers

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, UFW), sysctl security settings

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

- `Berksfile`: Defines cookbook dependencies from Chef Supermarket - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines Chef policy with run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Contains node configuration data - will be migrated to Ansible inventory variables
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Defines development VM - can be adapted for Ansible testing
- `vagrant-provision.sh`: Installs Chef and runs cookbooks - will be replaced by Ansible provisioning

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile configuration)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be designed for on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role from Galaxy or custom role
- **memcached (~> 6.0)**: Replace with Ansible memcached role from Galaxy
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role from Galaxy
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management tasks

### Security Considerations

- **fail2ban configuration**: Migrate fail2ban jail configuration to Ansible templates
- **UFW firewall rules**: Use Ansible UFW module to configure firewall
- **SSH hardening**: Migrate SSH security configurations using Ansible's lineinfile or template module
- **SSL certificates**: Migrate self-signed certificate generation to Ansible tasks
- **Redis password**: Store Redis password in Ansible Vault
- **PostgreSQL credentials**: Store database credentials in Ansible Vault
- **sysctl security settings**: Migrate sysctl security configurations to Ansible tasks

### Technical Challenges

- **Multi-site configuration**: Ensure the dynamic generation of Nginx site configurations is properly migrated to Ansible templates
- **Service dependencies**: Maintain proper ordering of service installations and configurations
- **SSL certificate management**: Ensure proper permissions and ownership of SSL certificates and keys
- **Database initialization**: Ensure PostgreSQL database creation and user setup is idempotent
- **Python environment setup**: Ensure proper setup of Python virtual environment and dependencies

### Migration Order

1. **nginx-multisite cookbook** (moderate complexity, foundation for web services)
   - Start with basic Nginx installation and configuration
   - Add SSL certificate generation
   - Add virtual host configuration
   - Add security hardening features

2. **cache cookbook** (low complexity, independent service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial cookbook** (high complexity, application deployment)
   - Implement PostgreSQL database setup
   - Implement Python environment setup
   - Implement application deployment
   - Implement systemd service configuration

### Assumptions

1. The target environment will continue to be Fedora-based systems
2. Self-signed certificates are acceptable for development (production would likely use Let's Encrypt or other CA)
3. The security hardening requirements will remain the same
4. The FastAPI application source code will remain available at the specified Git repository
5. The multi-site configuration pattern will be maintained
6. Redis authentication will continue to be required
7. The current directory structure in the target environment will be maintained

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── ansible.cfg
├── inventory/
│   ├── group_vars/
│   │   ├── all.yml
│   │   └── webservers.yml
│   └── hosts
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
└── Vagrantfile
```

## Migration Tasks

1. **Infrastructure Setup**
   - Create Ansible directory structure
   - Set up Ansible configuration
   - Create inventory files
   - Set up Ansible Vault for secrets

2. **Role Creation**
   - Create base roles for each cookbook
   - Migrate templates from Chef to Ansible
   - Convert Chef resources to Ansible tasks
   - Implement handlers for service notifications

3. **Variable Management**
   - Convert node attributes to Ansible variables
   - Set up group_vars and host_vars
   - Secure sensitive information with Ansible Vault

4. **Testing**
   - Update Vagrantfile for Ansible provisioning
   - Test each role individually
   - Test complete playbook

5. **Documentation**
   - Document role usage and variables
   - Create example inventory
   - Document testing procedures

## Conclusion

This migration involves converting three Chef cookbooks to Ansible roles while maintaining the same functionality. The primary challenges will be ensuring proper service dependencies, security configurations, and dynamic site generation. By following the migration order and addressing the identified technical challenges, the migration can be completed successfully within the estimated timeline.