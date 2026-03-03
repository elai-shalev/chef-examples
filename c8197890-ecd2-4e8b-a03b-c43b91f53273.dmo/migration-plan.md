# MIGRATION FROM CHEF TO ANSIBLE

This migration plan outlines the process of converting a Chef-based infrastructure to Ansible. The repository contains three primary Chef cookbooks that need to be migrated: nginx-multisite, cache, and fastapi-tutorial. The migration is estimated to be of medium complexity and should take approximately 2-3 weeks to complete.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Nginx web server configured with multiple virtual hosts, SSL termination, and security hardening
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multiple virtual hosts (3 sites), SSL configuration with self-signed certificates, HTTP to HTTPS redirection, security hardening (fail2ban, UFW firewall, SSH hardening)

- **cache**:
    - Description: Dual caching system with Memcached and Redis
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Memcached configuration (64MB memory, 1024 max connections), Redis with password authentication, service management

- **fastapi-tutorial**:
    - Description: Python FastAPI web application with PostgreSQL database
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment, Git repository deployment, PostgreSQL database setup, systemd service management

### Infrastructure Files

- `Policyfile.lock.json`: Contains cookbook dependencies and version constraints. Migration should ensure all dependencies are properly mapped to Ansible roles or collections.
- `solo.json`: Contains node-specific configuration for the Chef run. This data will need to be migrated to Ansible inventory variables or group_vars.

### Target Details

Based on the source configuration files:

- **Operating System**: Linux (likely Debian/Ubuntu based on package management and service configuration)
- **Virtual Machine Technology**: Not specified, assume standard VM environment
- **Cloud Platform**: Not specified, appears to be on-premises or generic cloud deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (12.3.1)**: Replace with Ansible community.general.nginx module or geerlingguy.nginx role
- **memcached (6.1.0)**: Replace with Ansible community.general.memcached module or geerlingguy.memcached role
- **redisio (7.2.4)**: Replace with Ansible community.general.redis module or geerlingguy.redis role
- **selinux (6.2.4)**: Replace with Ansible linux-system-roles.selinux role
- **ssl_certificate (2.1.0)**: Replace with Ansible community.crypto collection for certificate management
- **Python 3 and PostgreSQL**: Use Ansible's built-in apt module for package installation and postgresql_* modules for database configuration

### Security Considerations

- **SSL Certificates**: Migration must preserve the SSL certificate generation and configuration for the three virtual hosts
- **fail2ban**: Configuration needs to be migrated to use Ansible's template module for jail.local
- **UFW Firewall**: Replace with Ansible's community.general.ufw module
- **SSH Hardening**: Use Ansible's template module to configure sshd_config with appropriate security settings
- **System Security**: Migrate sysctl security settings using Ansible's sysctl module

### Technical Challenges

- **Redis Configuration**: The Chef cookbook uses a ruby_block to modify Redis configuration. This will need to be replaced with Ansible's lineinfile or template module.
- **Multiple Virtual Hosts**: Ensuring all three Nginx virtual hosts are properly configured with their respective SSL certificates
- **Service Dependencies**: Ensuring proper ordering of service installation and configuration, especially for the FastAPI application which depends on PostgreSQL
- **Python Virtual Environment**: Properly setting up the Python virtual environment and installing dependencies using Ansible

### Migration Order

1. **cache module** (moderate complexity)
   - Start with installing and configuring Memcached and Redis
   - This provides the caching layer needed by other services

2. **nginx-multisite module** (high complexity)
   - Configure Nginx with multiple virtual hosts and SSL
   - Implement security hardening (fail2ban, UFW, SSH)

3. **fastapi-tutorial module** (moderate complexity)
   - Set up PostgreSQL database
   - Deploy FastAPI application
   - Configure systemd service

### Assumptions

1. The target environment will be similar to the source environment (Linux-based, likely Debian/Ubuntu)
2. Self-signed certificates are acceptable for the migration (as used in the original Chef cookbooks)
3. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git is still accessible
4. The passwords used in the original configuration (e.g., 'redis_secure_password_123', 'fastapi_password') can be reused or will be replaced with new secure passwords
5. The directory structure for web content (/opt/server/test, /opt/server/ci, /opt/server/status) will remain the same
6. The FastAPI application will continue to run on port 8000
7. The Redis and Memcached configurations (memory limits, connection limits) will remain the same

## Ansible Project Structure

The migrated Ansible project will follow this structure:

```
ansible-project/
├── ansible.cfg
├── inventory/
│   ├── hosts
│   └── group_vars/
│       └── all.yml
├── playbooks/
│   ├── site.yml
│   ├── cache.yml
│   ├── nginx.yml
│   └── fastapi.yml
└── roles/
    ├── cache/
    │   ├── defaults/
    │   ├── handlers/
    │   ├── tasks/
    │   ├── templates/
    │   └── vars/
    ├── nginx-multisite/
    │   ├── defaults/
    │   ├── handlers/
    │   ├── tasks/
    │   ├── templates/
    │   └── vars/
    └── fastapi-tutorial/
        ├── defaults/
        ├── handlers/
        ├── tasks/
        ├── templates/
        └── vars/
```

## Migration Tasks

### 1. Set Up Ansible Project Structure

- Create the directory structure as outlined above
- Configure ansible.cfg with appropriate settings
- Create inventory file with target hosts

### 2. Migrate Cache Module

- Create cache role with tasks for Memcached and Redis installation
- Convert Chef templates to Ansible templates for configuration files
- Implement handlers for service restart
- Test Memcached and Redis functionality

### 3. Migrate Nginx-Multisite Module

- Create nginx-multisite role with tasks for Nginx installation
- Convert Chef templates to Ansible templates for nginx.conf, site configurations
- Implement SSL certificate generation
- Configure security features (fail2ban, UFW, SSH hardening)
- Test Nginx with multiple virtual hosts and SSL

### 4. Migrate FastAPI-Tutorial Module

- Create fastapi-tutorial role with tasks for Python and PostgreSQL installation
- Implement Git repository cloning
- Configure Python virtual environment and dependencies
- Set up PostgreSQL database and user
- Create systemd service for FastAPI application
- Test FastAPI application functionality

### 5. Create Main Playbook

- Create site.yml that includes all role playbooks
- Ensure proper ordering of roles
- Add tags for selective execution

### 6. Testing and Validation

- Test each role individually
- Test the complete playbook
- Validate service functionality
- Verify security configurations

## Conclusion

This migration plan provides a comprehensive approach to converting the Chef cookbooks to Ansible roles. By following the outlined steps and addressing the identified challenges, the migration can be completed successfully while maintaining the functionality and security of the original infrastructure.