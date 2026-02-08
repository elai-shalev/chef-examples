# Migration Plan: nginx-multisite

**TLDR**: This cookbook configures a secure Nginx web server with multiple virtual hosts. It sets up 3 SSL-enabled sites (test.cluster.local, ci.cluster.local, status.cluster.local), implements security hardening with fail2ban and ufw firewall, and generates self-signed SSL certificates for each site.

## Service Type and Instances

**Service Type**: Web Server

**Configured Instances**:

- **test.cluster.local**: Main test environment website
  - Location/Path: /opt/server/test
  - Port/Socket: 80 (redirect to 443), 443 (SSL)
  - Key Config: SSL-enabled with self-signed certificate

- **ci.cluster.local**: Continuous integration environment website
  - Location/Path: /opt/server/ci
  - Port/Socket: 80 (redirect to 443), 443 (SSL)
  - Key Config: SSL-enabled with self-signed certificate

- **status.cluster.local**: Status monitoring website
  - Location/Path: /opt/server/status
  - Port/Socket: 80 (redirect to 443), 443 (SSL)
  - Key Config: SSL-enabled with self-signed certificate

## File Structure

```
cookbooks/nginx-multisite/recipes/default.rb
cookbooks/nginx-multisite/recipes/nginx.rb
cookbooks/nginx-multisite/recipes/security.rb
cookbooks/nginx-multisite/recipes/sites.rb
cookbooks/nginx-multisite/recipes/ssl.rb
cookbooks/nginx-multisite/templates/default/fail2ban.jail.local.erb
cookbooks/nginx-multisite/templates/default/nginx.conf.erb
cookbooks/nginx-multisite/templates/default/security.conf.erb
cookbooks/nginx-multisite/templates/default/site.conf.erb
cookbooks/nginx-multisite/templates/default/sysctl-security.conf.erb
cookbooks/nginx-multisite/attributes/default.rb
```

## Module Explanation

The cookbook performs operations in this order:

1. **default** (`cookbooks/nginx-multisite/recipes/default.rb`):
   - Includes security, nginx, ssl, and sites recipes in sequence
   - Resources: include_recipe (4)

2. **security** (`cookbooks/nginx-multisite/recipes/security.rb`):
   - Installs security packages: fail2ban and ufw
   - Configures fail2ban service and deploys jail.local configuration
   - Sets up UFW firewall with default deny policy and allows SSH, HTTP, HTTPS
   - Deploys sysctl security configuration
   - Hardens SSH by disabling root login and password authentication
   - Resources: package (1), service (2), template (2), execute (7)

3. **nginx** (`cookbooks/nginx-multisite/recipes/nginx.rb`):
   - Installs nginx package
   - Deploys main nginx.conf configuration
   - Deploys security.conf with hardening settings
   - Enables and starts nginx service
   - Creates document root directory for test.cluster.local
   - Creates document root directory for ci.cluster.local
   - Creates document root directory for status.cluster.local
   - Deploys index.html file to test.cluster.local document root
   - Deploys index.html file to ci.cluster.local document root
   - Deploys index.html file to status.cluster.local document root
   - Resources: package (1), template (2), service (1), directory (3), cookbook_file (3)

4. **ssl** (`cookbooks/nginx-multisite/recipes/ssl.rb`):
   - Installs SSL packages: openssl and ca-certificates
   - Creates ssl-cert group
   - Creates certificate and private key directories
   - Generates self-signed SSL certificate for test.cluster.local
   - Generates self-signed SSL certificate for ci.cluster.local
   - Generates self-signed SSL certificate for status.cluster.local
   - Sets proper permissions on key files
   - Resources: package (1), group (1), directory (2), execute (3)

5. **sites** (`cookbooks/nginx-multisite/recipes/sites.rb`):
   - Deploys site configuration for test.cluster.local to sites-available
   - Deploys site configuration for ci.cluster.local to sites-available
   - Deploys site configuration for status.cluster.local to sites-available
   - Creates symlink from sites-available to sites-enabled for test.cluster.local
   - Creates symlink from sites-available to sites-enabled for ci.cluster.local
   - Creates symlink from sites-available to sites-enabled for status.cluster.local
   - Removes default site configuration
   - Resources: template (3), link (3), file (1)

## Dependencies

**External cookbook dependencies**: None specified in the analysis
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
- site.conf.erb → /etc/nginx/sites-available/[site_name] (3 times, one for each site)
- fail2ban.jail.local.erb → /etc/fail2ban/jail.local (1 time)
- sysctl-security.conf.erb → /etc/sysctl.d/99-security.conf (1 time)

## Pre-flight checks:
```bash
# Service status
systemctl status nginx
systemctl status fail2ban
ps aux | grep nginx

# Configuration validation
nginx -t
cat /etc/nginx/nginx.conf
cat /etc/nginx/conf.d/security.conf

# Site configuration checks - test.cluster.local
cat /etc/nginx/sites-available/test.cluster.local
ls -la /etc/nginx/sites-enabled/test.cluster.local
ls -la /opt/server/test/
curl -I http://test.cluster.local
curl -I -k https://test.cluster.local

# Site configuration checks - ci.cluster.local
cat /etc/nginx/sites-available/ci.cluster.local
ls -la /etc/nginx/sites-enabled/ci.cluster.local
ls -la /opt/server/ci/
curl -I http://ci.cluster.local
curl -I -k https://ci.cluster.local

# Site configuration checks - status.cluster.local
cat /etc/nginx/sites-available/status.cluster.local
ls -la /etc/nginx/sites-enabled/status.cluster.local
ls -la /opt/server/status/
curl -I http://status.cluster.local
curl -I -k https://status.cluster.local

# SSL certificate checks - test.cluster.local
openssl x509 -in /etc/ssl/certs/test.cluster.local.crt -text -noout | grep Subject
ls -la /etc/ssl/private/test.cluster.local.key
openssl rsa -check -in /etc/ssl/private/test.cluster.local.key -noout

# SSL certificate checks - ci.cluster.local
openssl x509 -in /etc/ssl/certs/ci.cluster.local.crt -text -noout | grep Subject
ls -la /etc/ssl/private/ci.cluster.local.key
openssl rsa -check -in /etc/ssl/private/ci.cluster.local.key -noout

# SSL certificate checks - status.cluster.local
openssl x509 -in /etc/ssl/certs/status.cluster.local.crt -text -noout | grep Subject
ls -la /etc/ssl/private/status.cluster.local.key
openssl rsa -check -in /etc/ssl/private/status.cluster.local.key -noout

# Security checks
cat /etc/fail2ban/jail.local
fail2ban-client status
ufw status verbose
cat /etc/sysctl.d/99-security.conf
sysctl -a | grep -E 'net.ipv4.conf.all.rp_filter|net.ipv4.tcp_syncookies'
grep -E "PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config

# Logs
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/test.cluster.local_access.log
tail -f /var/log/nginx/test.cluster.local_error.log
tail -f /var/log/nginx/ci.cluster.local_access.log
tail -f /var/log/nginx/ci.cluster.local_error.log
tail -f /var/log/nginx/status.cluster.local_access.log
tail -f /var/log/nginx/status.cluster.local_error.log
tail -f /var/log/fail2ban.log

# Network listening
netstat -tulpn | grep nginx
ss -tlnp | grep nginx
lsof -i :80
lsof -i :443
```