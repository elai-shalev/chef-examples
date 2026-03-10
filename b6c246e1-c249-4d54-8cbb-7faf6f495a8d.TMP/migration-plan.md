# MIGRATION FROM CHEF TO ANSIBLE

## Executive Summary

This repository contains a Chef-based infrastructure setup for a multi-site Nginx web server with caching services (Redis and Memcached) and a FastAPI application with PostgreSQL. The migration to Ansible will involve converting three Chef cookbooks with their dependencies, configuration templates, and security settings. The estimated timeline for migration is 2-3 weeks, with moderate complexity due to the security configurations and multi-site SSL setup.

## Module Migration Plan

This repository contains Chef cookbooks that need individual migration planning:

### MODULE INVENTORY

- **nginx-multisite**:
    - Description: Configures Nginx with multiple SSL-enabled virtual hosts, security hardening, and proper SSL configuration
    - Path: cookbooks/nginx-multisite
    - Technology: Chef
    - Key Features: Multi-site configuration, SSL certificate generation, security hardening (fail2ban, ufw, SSH hardening), sysctl security settings

- **cache**:
    - Description: Configures caching services including Memcached and Redis with authentication
    - Path: cookbooks/cache
    - Technology: Chef
    - Key Features: Redis with password authentication, Memcached configuration, log directory management

- **fastapi-tutorial**:
    - Description: Deploys a FastAPI Python application with PostgreSQL database backend
    - Path: cookbooks/fastapi-tutorial
    - Technology: Chef
    - Key Features: Python virtual environment setup, Git repository deployment, PostgreSQL database creation, systemd service configuration

### Infrastructure Files

- `Berksfile`: Defines cookbook dependencies (nginx, ssl_certificate, memcached, redisio) - will be replaced by Ansible Galaxy requirements
- `Policyfile.rb`: Defines the run list and cookbook versions - will be replaced by Ansible playbook structure
- `solo.json`: Contains node configuration data including Nginx site definitions and security settings - will be migrated to Ansible variables
- `solo.rb`: Chef Solo configuration - will be replaced by Ansible configuration
- `Vagrantfile`: Defines the development VM environment - will need updates for Ansible provisioning
- `vagrant-provision.sh`: Installs Chef and runs the cookbooks - will be replaced with Ansible provisioning script

### Target Details

- **Operating System**: Fedora 42 (based on Vagrantfile configuration)
- **Virtual Machine Technology**: Libvirt (based on Vagrantfile provider configuration)
- **Cloud Platform**: Not specified, appears to be targeting on-premises deployment

## Migration Approach

### Key Dependencies to Address

- **nginx (~> 12.0)**: Replace with Ansible nginx role from Galaxy or custom role
- **memcached (~> 6.0)**: Replace with Ansible memcached role from Galaxy
- **redisio (~> 7.2.4)**: Replace with Ansible Redis role from Galaxy
- **ssl_certificate (~> 2.1)**: Replace with Ansible certificate management tasks or community role

### Security Considerations

- **Firewall (UFW)**: Migrate UFW rules to Ansible ufw module
- **Fail2ban**: Migrate fail2ban configuration to Ansible fail2ban role
- **SSH hardening**: Migrate SSH security settings using Ansible's lineinfile or template module
- **SSL configuration**: Ensure proper SSL certificate generation and configuration in Ansible
- **Sysctl security settings**: Migrate sysctl security configurations using Ansible sysctl module
- **Redis password**: Ensure secure handling of Redis password in Ansible Vault

### Technical Challenges

- **Multi-site SSL configuration**: Ensure proper handling of multiple SSL-enabled sites with appropriate certificate generation
- **Security hardening**: Comprehensive migration of all security measures including fail2ban, ufw, SSH hardening, and sysctl settings
- **Service dependencies**: Maintain proper service dependencies and ordering during deployment
- **PostgreSQL user/database creation**: Ensure idempotent database and user creation in Ansible

### Migration Order

1. **nginx-multisite cookbook** (moderate complexity, foundation for other services)
   - Start with basic Nginx installation and configuration
   - Add SSL certificate generation
   - Configure virtual hosts
   - Implement security hardening

2. **cache cookbook** (low complexity, independent service)
   - Implement Memcached configuration
   - Implement Redis with authentication

3. **fastapi-tutorial cookbook** (high complexity, depends on PostgreSQL)
   - Set up PostgreSQL database
   - Deploy FastAPI application
   - Configure systemd service

### Assumptions

1. The current Chef setup is functional and represents the desired end state
2. The target environment will continue to be Fedora 42 with libvirt virtualization
3. Self-signed SSL certificates are acceptable (production would likely use Let's Encrypt)
4. The FastAPI application repository at https://github.com/dibanez/fastapi_tutorial.git is available and compatible
5. Redis password "redis_secure_password_123" will need to be stored securely in Ansible Vault
6. PostgreSQL credentials (fastapi/fastapi_password) will need to be stored securely in Ansible Vault
7. The current security configurations (fail2ban, ufw, SSH hardening) are appropriate for the target environment

## Ansible Structure Recommendation

```
ansible-nginx-multisite/
├── inventories/
│   ├── development/
│   │   ├── group_vars/
│   │   │   └── all.yml  # Development-specific variables
│   │   └── hosts        # Development inventory
│   └── production/
│       ├── group_vars/
│       │   └── all.yml  # Production-specific variables
│       └── hosts        # Production inventory
├── roles/
│   ├── nginx-multisite/
│   │   ├── defaults/
│   │   │   └── main.yml  # Default variables
│   │   ├── files/
│   │   │   ├── ci/
│   │   │   │   └── index.html
│   │   │   ├── status/
│   │   │   │   └── index.html
│   │   │   └── test/
│   │   │       └── index.html
│   │   ├── handlers/
│   │   │   └── main.yml  # Nginx restart/reload handlers
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
│   │   │   └── main.yml  # Default variables
│   │   ├── handlers/
│   │   │   └── main.yml  # Service handlers
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── memcached.yml
│   │   │   └── redis.yml
│   │   └── templates/
│   │       └── redis.conf.j2
│   └── fastapi-tutorial/
│       ├── defaults/
│       │   └── main.yml  # Default variables
│       ├── handlers/
│       │   └── main.yml  # Service handlers
│       ├── tasks/
│       │   ├── main.yml
│       │   ├── app.yml
│       │   └── database.yml
│       └── templates/
│           ├── env.j2
│           └── fastapi-tutorial.service.j2
├── playbooks/
│   ├── site.yml        # Main playbook
│   ├── nginx.yml       # Nginx-specific playbook
│   ├── cache.yml       # Cache-specific playbook
│   └── fastapi.yml     # FastAPI-specific playbook
├── requirements.yml    # Ansible Galaxy requirements
├── ansible.cfg        # Ansible configuration
└── Vagrantfile        # Updated for Ansible provisioning
```

## Implementation Details

### Ansible Galaxy Requirements

```yaml
# requirements.yml
---
roles:
  - name: geerlingguy.nginx
    version: 3.1.0
  - name: geerlingguy.memcached
    version: 2.2.0
  - name: geerlingguy.redis
    version: 1.7.0
  - name: dev-sec.ssh-hardening
    version: 9.8.0
```

### Variable Structure

```yaml
# group_vars/all.yml
---
# Nginx configuration
nginx_sites:
  test.cluster.local:
    document_root: /opt/server/test
    ssl_enabled: true
  ci.cluster.local:
    document_root: /opt/server/ci
    ssl_enabled: true
  status.cluster.local:
    document_root: /opt/server/status
    ssl_enabled: true

nginx_ssl:
  certificate_path: /etc/ssl/certs
  private_key_path: /etc/ssl/private

# Security configuration
security:
  fail2ban:
    enabled: true
  ufw:
    enabled: true
  ssh:
    disable_root: true
    password_auth: false

# Redis configuration
redis_password: "{{ vault_redis_password }}"

# PostgreSQL configuration
postgresql_user: fastapi
postgresql_password: "{{ vault_postgresql_password }}"
postgresql_db: fastapi_db
```

### Vault Structure

```yaml
# vault.yml (encrypted)
---
vault_redis_password: redis_secure_password_123
vault_postgresql_password: fastapi_password
```

## Testing Strategy

1. Create Vagrant environment with Ansible provisioning
2. Test each role individually
3. Test complete deployment
4. Verify all sites are accessible and properly secured
5. Verify Redis authentication works
6. Verify FastAPI application is running and can connect to PostgreSQL

## Documentation Requirements

1. README with setup instructions
2. Role documentation for each Ansible role
3. Variable documentation
4. Deployment guide