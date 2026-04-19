# Nginx Multisite Role

This Ansible role configures Nginx with multiple SSL-enabled subdomains.

## Requirements

- Ansible 2.9 or higher
- Ubuntu 18.04+ or CentOS/RHEL 7+

## Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| nginx_multisite_domains | List of domains to configure | [] |
| nginx_multisite_ssl_cert_path | Path to SSL certificates | /etc/ssl/certs |
| nginx_multisite_ssl_key_path | Path to SSL private keys | /etc/ssl/private |
| nginx_multisite_default_root | Default document root | /var/www/html |

## Example Playbook

```yaml
- hosts: webservers
  roles:
    - role: nginx_multisite
      vars:
        nginx_multisite_domains:
          - name: test.cluster.local
            root: /opt/server/test
          - name: ci.cluster.local
            root: /opt/server/ci
          - name: status.cluster.local
            root: /opt/server/status
```

## License

Apache-2.0