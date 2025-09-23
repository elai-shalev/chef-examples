# Chef to Ansible Migration Plan

## Module Migration Plan

This repository contains 2 Chef cookbooks that need individual migration planning:

### Cookbooks Inventory
- **nginx-multisite**: Configures nginx with multiple SSL-enabled subdomains
- **cache**: Configures caching services (memcached and redis)

### Individual Migration Plans
- [nginx-multisite migration plan](migration-nginx-multisite-plan.md)
- [cache migration plan](migration-cache-plan.md)

### Infrastructure Files
- `Vagrantfile`: VM provisioning configuration  
- `Policyfile.rb`: Chef policy definition
- `solo.json`: Chef solo configuration
- `solo.rb`: Chef solo runner configuration
- `deploy.sh`: Deployment script
- `vagrant-provision.sh`: Vagrant provisioning script

## Migration Approach

### Per-Module Strategy
Each cookbook has its own detailed migration plan with:
- Module explanation and dependency analysis
- Complete file inventory and structure
- Specific migration checks and validation steps
- Security considerations and rollback procedures

### Global Migration Coordination
1. **nginx-multisite** should be migrated first (self-contained, no external dependencies)
2. **cache** requires external dependencies resolution (memcached ~> 6.0, redisio cookbooks)
3. Integration testing should verify both modules work together in Ansible

### Key Dependencies to Address
- **memcached cookbook (~> 6.0)**: Replace with Ansible galaxy role (e.g., geerlingguy.memcached)
- **redisio cookbook**: Replace with Ansible galaxy role (e.g., geerlingguy.redis)
- **SSL certificate management**: Custom implementation needed
- **Multi-site nginx configuration**: Template conversion from ERB to Jinja2

### Security Considerations
- Change default Redis password from 'redis_secure_password_123'
- Use Ansible vault for sensitive configuration
- Maintain SSH hardening and firewall configurations
- Preserve fail2ban intrusion prevention setup