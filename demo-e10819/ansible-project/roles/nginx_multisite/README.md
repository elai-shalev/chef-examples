# Nginx Multisite Role

This Ansible role installs and configures Nginx with support for multiple virtual hosts and security hardening.

## Features

- Installs and configures Nginx
- Supports multiple virtual hosts
- SSL/TLS support with self-signed certificates
- Security hardening:
  - Fail2ban integration
  - UFW firewall configuration
  - Sysctl security settings
  - SSH hardening

## Requirements

- Ansible 2.9 or higher
- Ubuntu 20.04 (Focal) or higher
- Debian 11 (Bullseye) or higher

## Role Variables

```yaml
# Nginx configuration
nginx:
  # SSL configuration
  ssl:
    certificate_path: /etc/ssl/certs
    private_key_path: /etc/ssl/private
  
  # Site configuration
  sites:
    example.com:
      document_root: /var/www/example.com
      ssl_enabled: true
    test.example.com:
      document_root: /var/www/test.example.com
      ssl_enabled: false

# Security configuration
security:
  ssh:
    disable_root: true
    password_auth: false
```

## Example Playbook

```yaml
---
- hosts: webservers
  become: true
  roles:
    - role: nginx_multisite
      vars:
        nginx:
          sites:
            mysite.example.com:
              document_root: /var/www/mysite
              ssl_enabled: true
            blog.example.com:
              document_root: /var/www/blog
              ssl_enabled: true
```

## License

MIT

## Author Information

Created by the Ansible Migration Team