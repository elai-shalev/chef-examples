# Migration Plan: nginx-multisite

**TLDR**: This cookbook configures Nginx as a web server with multiple virtual hosts (3 sites), each with SSL enabled. It also implements security hardening through fail2ban, UFW firewall, and system-level security configurations.

## Service Type and Instances

**Service Type**: Web Server

**Configured Instances**:

- **test.cluster.local**: SSL-enabled Nginx virtual host
  - Location/Path: /opt/server/test
  - Port/Socket: 80 (redirect to 443), 443 (HTTPS)
  - Key Config: SSL enabled, HTTP to HTTPS redirect

- **ci.cluster.local**: SSL-enabled Nginx virtual host
  - Location/Path: /opt/server/ci
  - Port/Socket: 80 (redirect to 443), 443 (HTTPS)
  - Key Config: SSL enabled, HTTP to HTTPS redirect

- **status.cluster.local**: SSL-enabled Nginx virtual host
  - Location/Path: /opt/server/status
  - Port/Socket: 80 (redirect to 443), 443 (HTTPS)
  - Key Config: SSL enabled, HTTP to HTTPS redirect

## File Structure

```
cookbooks/nginx-multisite/recipes/default.rb
cookbooks/nginx-multisite/recipes/nginx.rb
cookbooks/nginx-multisite/recipes/security.rb
cookbooks/nginx-multisite/recipes/sites.rb
cookbooks/nginx-multisite/recipes/ssl.rb
cookbooks/nginx-multisite/attributes/default.rb
cookbooks/nginx-multisite/templates/default/fail2ban.jail.local.erb
cookbooks/nginx-multisite/templates/default/nginx.conf.erb
cookbooks/nginx-multisite/templates/default/security.conf.erb
cookbooks/nginx-multisite/templates/default/site.conf.erb
cookbooks/nginx-multisite/templates/default/sysctl-security.conf.erb
```

## Module Explanation

The cookbook performs operations in this order:

1. **default** (`cookbooks/nginx-multisite/recipes/default.rb`):
   - Includes other recipes in sequence: security, nginx, ssl, sites
   - Resources: include_recipe (4)

2. **security** (`cookbooks/nginx-multisite/recipes/security.rb`):
   - Installs security packages: fail2ban, ufw
   - Configures fail2ban service and jail settings
   - Sets up UFW firewall rules (deny by default, allow SSH, HTTP, HTTPS)
   - Configures system security via sysctl
   - Hardens SSH configuration (disable root login, disable password authentication)
   - Resources: package (1), service (2), template (2), execute (7), file (1)

3. **nginx** (`cookbooks/nginx-multisite/recipes/nginx.rb`):
   - Installs Nginx package
   - Deploys main Nginx configuration
   - Deploys security-specific Nginx configuration
   - Enables and starts Nginx service
   - Creates document root directory for test.cluster.local
   - Creates document root directory for ci.cluster.local
   - Creates document root directory for status.cluster.local
   - Deploys index.html file for test.cluster.local
   - Deploys index.html file for ci.cluster.local
   - Deploys index.html file for status.cluster.local
   - Resources: package (1), template (2), service (1), directory (3), cookbook_file (3)

4. **ssl** (`cookbooks/nginx-multisite/recipes/ssl.rb`):
   - Installs SSL-related packages: openssl, ca-certificates
   - Creates SSL certificate group
   - Creates certificate and private key directories
   - Generates self-signed SSL certificates for test.cluster.local
   - Generates self-signed SSL certificates for ci.cluster.local
   - Generates self-signed SSL certificates for status.cluster.local
   - Resources: package (1), group (1), directory (2), execute (3)

5. **sites** (`cookbooks/nginx-multisite/recipes/sites.rb`):
   - Creates Nginx site configuration for test.cluster.local
   - Creates Nginx site configuration for ci.cluster.local
   - Creates Nginx site configuration for status.cluster.local
   - Creates symlink from sites-available to sites-enabled for test.cluster.local
   - Creates symlink from sites-available to sites-enabled for ci.cluster.local
   - Creates symlink from sites-available to sites-enabled for status.cluster.local
   - Removes default Nginx site configuration
   - Resources: template (3), link (3), file (1)

## Dependencies

**External cookbook dependencies**: None specified in the provided analysis
**System package dependencies**: nginx, fail2ban, ufw, openssl, ca-certificates
**Service dependencies**: nginx, fail2ban, ssh

## Checks for the Migration

**Files to verify**:
- /etc/nginx/nginx.conf
- /etc/nginx/conf.d/security.conf
- /etc/nginx/sites-available/test.cluster.local
- /etc/nginx/sites-available/ci.cluster.local
- /etc/nginx/sites-available/status.cluster.local
- /etc/nginx/sites-enabled/test.cluster.local
- /etc/nginx/sites-enabled/ci.cluster.local
- /etc/nginx/sites-enabled/status.cluster.local
- /etc/ssl/certs/test.cluster.local.crt
- /etc/ssl/certs/ci.cluster.local.crt
- /etc/ssl/certs/status.cluster.local.crt
- /etc/ssl/private/test.cluster.local.key
- /etc/ssl/private/ci.cluster.local.key
- /etc/ssl/private/status.cluster.local.key
- /etc/fail2ban/jail.local
- /etc/sysctl.d/99-security.conf
- /opt/server/test/index.html
- /opt/server/ci/index.html
- /opt/server/status/index.html

**Service endpoints to check**:
- Ports listening: 80 (HTTP), 443 (HTTPS)
- Network interfaces: All interfaces (default)

**Templates rendered**:
- nginx.conf.erb → /etc/nginx/nginx.conf (1 time)
- security.conf.erb → /etc/nginx/conf.d/security.conf (1 time)
- site.conf.erb → /etc/nginx/sites-available/test.cluster.local, /etc/nginx/sites-available/ci.cluster.local, /etc/nginx/sites-available/status.cluster.local (3 times)
- fail2ban.jail.local.erb → /etc/fail2ban/jail.local (1 time)
- sysctl-security.conf.erb → /etc/sysctl.d/99-security.conf (1 time)

## Pre-flight checks:
```bash
# Nginx service status
systemctl status nginx
ps aux | grep nginx

# Configuration validation
nginx -t

# Site-specific checks - test.cluster.local
curl -I http://test.cluster.local  # Should return 301 redirect to HTTPS
curl -I -k https://test.cluster.local  # Should return 200 OK
openssl s_client -connect test.cluster.local:443 -servername test.cluster.local </dev/null | grep "subject="  # Verify certificate subject

# Site-specific checks - ci.cluster.local
curl -I http://ci.cluster.local  # Should return 301 redirect to HTTPS
curl -I -k https://ci.cluster.local  # Should return 200 OK
openssl s_client -connect ci.cluster.local:443 -servername ci.cluster.local </dev/null | grep "subject="  # Verify certificate subject

# Site-specific checks - status.cluster.local
curl -I http://status.cluster.local  # Should return 301 redirect to HTTPS
curl -I -k https://status.cluster.local  # Should return 200 OK
openssl s_client -connect status.cluster.local:443 -servername status.cluster.local </dev/null | grep "subject="  # Verify certificate subject

# Security checks - fail2ban
systemctl status fail2ban
fail2ban-client status
fail2ban-client status nginx-http-auth  # Check specific jail

# Security checks - UFW firewall
ufw status verbose  # Should show SSH, HTTP, HTTPS allowed

# Security checks - SSH hardening
grep "PermitRootLogin" /etc/ssh/sshd_config  # Should show "PermitRootLogin no"
grep "PasswordAuthentication" /etc/ssh/sshd_config  # Should show "PasswordAuthentication no"

# Security checks - sysctl
sysctl -a | grep "net.ipv4.conf.all.accept_redirects"  # Should be 0
sysctl -a | grep "net.ipv4.conf.all.send_redirects"  # Should be 0

# File permissions
ls -la /etc/ssl/private/*.key  # Should be 640 permissions, root:ssl-cert ownership
ls -la /etc/ssl/certs/*.crt  # Should be 644 permissions

# Document roots
ls -la /opt/server/test/
ls -la /opt/server/ci/
ls -la /opt/server/status/

# Logs - check each site
tail -f /var/log/nginx/test.cluster.local_access.log
tail -f /var/log/nginx/test.cluster.local_error.log
tail -f /var/log/nginx/ci.cluster.local_access.log
tail -f /var/log/nginx/ci.cluster.local_error.log
tail -f /var/log/nginx/status.cluster.local_access.log
tail -f /var/log/nginx/status.cluster.local_error.log

# Network listening
netstat -tulpn | grep nginx
ss -tlnp | grep nginx
lsof -i :80
lsof -i :443
```