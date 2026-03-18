# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup with three main cookbooks: nginx-multisite, cache, and fastapi-tutorial. The migration to Ansible will involve converting Chef recipes, templates, attributes, and resources to Ansible roles, tasks, templates, and variables. The estimated timeline for this migration is 3-4 weeks, with medium complexity due to the security configurations and SSL certificate management.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server with multiple SSL-enabled virtual hosts, security hardening, and firewall configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate management, fail2ban integration, UFW firewall rules, security headers

- **cache**:
    - Description: Caching services configuration including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Python FastAPI application deployment with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Dependency management for Chef cookbooks - will be replaced by Ansible Galaxy requirements.yml
- `Policyfile.rb`: Chef policy definition - will be replaced by Ansible playbooks
- `solo.json`: Chef node attributes - will be replaced by Ansible inventory variables
- `solo.rb`: Chef configuration - will be replaced by ansible.cfg
- `vagrant-provision.sh`: Vagrant provisioning script - will be replaced by Ansible Vagrant provisioner
- `Vagrantfile`: Vagrant configuration - will need updates to use Ansible provisioner

### Target Details

- **Operating System**: Ubuntu 18.04 or CentOS 7 (based on cookbook support declarations)
- **Virtual Machine Technology**: VirtualBox (inferred from Vagrant usage)
- **Cloud Platform**: Not specified, appears to be targeting on-premises or generic VM deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible's `nginx` module and community.general collection
- **memcached (~> 6.0)**: Replace with Ansible's `memcached` module
- **redisio (~> 7.2.4)**: Replace with Ansible's `redis` module and community.general collection
- **ssl_certificate (~> 2.1)**: Replace with Ansible's `openssl_*` modules

### Security Considerations

- **SSL Certificate Management**: Migration must preserve the self-signed certificate generation for development environments
- **Fail2ban Configuration**: Convert fail2ban jail configuration to Ansible templates
- **UFW Firewall Rules**: Use Ansible's `ufw` module to maintain firewall configuration
- **SSH Hardening**: Maintain SSH security settings (disable root login, password authentication)
- **Security Headers**: Preserve security headers in Nginx configuration
- **Redis Password**: Securely manage Redis authentication password using Ansible Vault
- **PostgreSQL Credentials**: Securely manage database credentials using Ansible Vault

### Technical Challenges

- **Custom Resource Migration**: The `lineinfile` custom resource will need to be replaced with Ansible's native `lineinfile` module
- **Multi-site Configuration**: Ensure the dynamic generation of multiple Nginx virtual hosts is properly implemented
- **SSL Certificate Management**: Ensure proper handling of SSL certificates and private keys with appropriate permissions
- **Service Dependencies**: Maintain proper ordering of service installations and configurations
- **PostgreSQL User/Database Creation**: Ensure idempotent database and user creation

### Migration Order

1. **cache cookbook** (low complexity)
   - Simple Redis and Memcached configuration
   - Few dependencies

2. **nginx-multisite cookbook** (medium complexity)
   - Core web server functionality
   - Required for application access

3. **fastapi-tutorial cookbook** (high complexity)
   - Application deployment
   - Database configuration
   - Depends on web server being configured

### Assumptions

1. The current Chef setup is functional and tested
2. No major architectural changes are required during migration
3. Self-signed certificates are acceptable for development environments
4. The target environment will continue to be Ubuntu 18.04/CentOS 7 or newer
5. Vagrant will continue to be used for development/testing

## Ansible Structure Plan

```
ansible-project/
├── ansible.cfg
├── inventory/
│   ├── group_vars/
│   │   ├── all.yml
│   │   └── webservers.yml
│   └── hosts
├── playbooks/
│   ├── site.yml
│   ├── nginx.yml
│   ├── cache.yml
│   └── fastapi.yml
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   │   └── main.yml
│   │   ├── files/
│   │   │   ├── ci/
│   │   │   │   └── index.html
│   │   │   ├── status/
│   │   │   │   └── index.html
│   │   │   └── test/
│   │   │       └── index.html
│   │   ├── handlers/
│   │   │   └── main.yml
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── nginx.yml
│   │   │   ├── security.yml
│   │   │   ├── sites.yml
│   │   │   └── ssl.yml
│   │   └── templates/
│   │       ├── fail2ban.jail.local.j2
│   │       ├── nginx.conf.j2
│   │       ├── security.conf.j2
│   │       ├── site.conf.j2
│   │       └── sysctl-security.conf.j2
│   ├── cache/
│   │   ├── defaults/
│   │   │   └── main.yml
│   │   ├── handlers/
│   │   │   └── main.yml
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── memcached.yml
│   │   │   └── redis.yml
│   │   └── templates/
│   │       └── redis.conf.j2
│   └── fastapi-tutorial/
│       ├── defaults/
│       │   └── main.yml
│       ├── handlers/
│       │   └── main.yml
│       ├── tasks/
│       │   ├── main.yml
│       │   ├── app.yml
│       │   └── database.yml
│       └── templates/
│           ├── env.j2
│           └── fastapi-tutorial.service.j2
├── requirements.yml
└── Vagrantfile
```

## Migration Steps

1. **Setup Ansible Project Structure**
   - Create directory structure as outlined above
   - Create initial ansible.cfg and inventory files

2. **Create requirements.yml**
   - Add required Ansible Galaxy collections and roles

3. **Migrate Common Variables**
   - Convert Chef attributes to Ansible variables
   - Store sensitive data in Ansible Vault

4. **Migrate Each Role**
   - Start with cache role (simplest)
   - Convert nginx-multisite role
   - Finally, convert fastapi-tutorial role

5. **Create Playbooks**
   - Create individual playbooks for each role
   - Create site.yml to include all playbooks

6. **Update Vagrant Configuration**
   - Modify Vagrantfile to use Ansible provisioner
   - Remove vagrant-provision.sh script

7. **Testing**
   - Test each role individually
   - Test complete playbook
   - Verify all functionality matches original Chef implementation

8. **Documentation**
   - Update documentation to reflect Ansible usage
   - Document any changes in behavior or configuration

## Conclusion

This migration will convert the existing Chef-based infrastructure to Ansible while maintaining all functionality. The modular approach allows for incremental migration and testing. Special attention will be paid to security configurations and service dependencies to ensure a smooth transition.