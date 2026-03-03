# Migration Plan: nginx-multisite

**TLDR**: This cookbook configures Nginx as a web server with multiple virtual hosts (3 sites), each with SSL enabled. It also implements security hardening through fail2ban, UFW firewall, SSH hardening, and system-level security configurations.

## Service Type and Instances

**Service Type**: Web Server

**Configured Instances**:

- **test.cluster.local**: Primary test environment website
  - Location/Path: /opt/server/test
  - Port/Socket: 80 (redirect to 443), 443 (SSL)
  - Key Config: SSL enabled, HTTP to HTTPS redirect

- **ci.cluster.local**: Continuous integration environment website
  - Location/Path: /opt/server/ci
  - Port/Socket: 80 (redirect to 443), 443 (SSL)
  - Key Config: SSL enabled, HTTP to HTTPS redirect

- **status.cluster.local**: Status monitoring website
  - Location/Path: /opt/server/status
  - Port/Socket: 80 (redirect to 443), 443 (SSL)
  - Key Config: SSL enabled, HTTP to HTTPS redirect

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
   - Includes other recipes in sequence: security, nginx, ssl, sites
   - Resources: include_recipe (4)

2. **security** (`cookbooks/nginx-multisite/recipes/security.rb`):
   - Installs security packages: fail2ban, ufw
   - Enables and starts fail2ban service
   - Configures fail2ban with custom jail settings
   - Configures UFW firewall: default deny, allow SSH/HTTP/HTTPS, enable
   - Deploys system security settings via sysctl
   - Hardens SSH configuration: disable root login, disable password authentication
   - Resources: package (1), service (2), template (2), execute (7)

3. **nginx** (`cookbooks/nginx-multisite/recipes/nginx.rb`):
   - Installs nginx package
   - Deploys main nginx.conf configuration
   - Deploys security-specific nginx configuration
   - Enables and starts nginx service
   - Creates document root directories for each site
   - Deploys index.html files for each site
   - Iterations: Runs 3 times for sites: test.cluster.local, ci.cluster.local, status.cluster.local
   - Resources: package (1), template (2), service (1), directory (3), cookbook_file (3)

4. **ssl** (`cookbooks/nginx-multisite/recipes/ssl.rb`):
   - Installs SSL-related packages: openssl, ca-certificates
   - Creates ssl-cert group
   - Creates certificate and private key directories
   - Generates self-signed SSL certificates for each site
   - Iterations: Runs 3 times for sites: test.cluster.local, ci.cluster.local, status.cluster.local
   - Resources: package (1), group (1), directory (2), execute (3)

5. **sites** (`cookbooks/nginx-multisite/recipes/sites.rb`):
   - Creates Nginx site configuration files for each site
   - Creates symlinks to enable each site
   - Removes default nginx site
   - Iterations: Runs 3 times for sites: test.cluster.local, ci.cluster.local, status.cluster.local
   - Resources: template (3), link (3), file (1)

## Dependencies

**External cookbook dependencies**: None specified in the provided analysis

**System package dependencies**: 
- nginx
- fail2ban
- ufw
- openssl
- ca-certificates

**Service dependencies**: 
- nginx
- fail2ban
- ssh

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
- /etc/fail2ban/jail.local
- /etc/sysctl.d/99-security.conf
- /etc/ssl/certs/test.cluster.local.crt
- /etc/ssl/certs/ci.cluster.local.crt
- /etc/ssl/certs/status.cluster.local.crt
- /etc/ssl/private/test.cluster.local.key
- /etc/ssl/private/ci.cluster.local.key
- /etc/ssl/private/status.cluster.local.key
- /opt/server/test/index.html
- /opt/server/ci/index.html
- /opt/server/status/index.html

**Service endpoints to check**:
- Ports listening: 80, 443
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
systemctl status ufw

# Nginx configuration validation
nginx -t

# Check enabled sites
ls -la /etc/nginx/sites-enabled/
[ ! -L /etc/nginx/sites-enabled/default ] && echo "Default site correctly removed"

# Check each site configuration
# Site: test.cluster.local
grep -q "server_name test.cluster.local" /etc/nginx/sites-available/test.cluster.local && echo "test.cluster.local config OK"
[ -d /opt/server/test ] && echo "Document root exists"
[ -f /opt/server/test/index.html ] && echo "Index file exists"

# Site: ci.cluster.local
grep -q "server_name ci.cluster.local" /etc/nginx/sites-available/ci.cluster.local && echo "ci.cluster.local config OK"
[ -d /opt/server/ci ] && echo "Document root exists"
[ -f /opt/server/ci/index.html ] && echo "Index file exists"

# Site: status.cluster.local
grep -q "server_name status.cluster.local" /etc/nginx/sites-available/status.cluster.local && echo "status.cluster.local config OK"
[ -d /opt/server/status ] && echo "Document root exists"
[ -f /opt/server/status/index.html ] && echo "Index file exists"

# SSL certificate verification
# Site: test.cluster.local
[ -f /etc/ssl/certs/test.cluster.local.crt ] && echo "SSL certificate exists"
[ -f /etc/ssl/private/test.cluster.local.key ] && echo "SSL key exists"
openssl x509 -in /etc/ssl/certs/test.cluster.local.crt -text -noout | grep "Subject: CN=test.cluster.local"

# Site: ci.cluster.local
[ -f /etc/ssl/certs/ci.cluster.local.crt ] && echo "SSL certificate exists"
[ -f /etc/ssl/private/ci.cluster.local.key ] && echo "SSL key exists"
openssl x509 -in /etc/ssl/certs/ci.cluster.local.crt -text -noout | grep "Subject: CN=ci.cluster.local"

# Site: status.cluster.local
[ -f /etc/ssl/certs/status.cluster.local.crt ] && echo "SSL certificate exists"
[ -f /etc/ssl/private/status.cluster.local.key ] && echo "SSL key exists"
openssl x509 -in /etc/ssl/certs/status.cluster.local.crt -text -noout | grep "Subject: CN=status.cluster.local"

# Security configuration checks
grep -q "server_tokens off" /etc/nginx/conf.d/security.conf && echo "Nginx security config OK"
grep -q "PermitRootLogin no" /etc/ssh/sshd_config && echo "SSH root login disabled"
grep -q "PasswordAuthentication no" /etc/ssh/sshd_config && echo "SSH password auth disabled"

# Fail2ban configuration
grep -q "\[nginx-http-auth\]" /etc/fail2ban/jail.local && echo "Fail2ban nginx config OK"
fail2ban-client status

# Firewall checks
ufw status verbose | grep "Status: active"
ufw status | grep "22/tcp"
ufw status | grep "80/tcp"
ufw status | grep "443/tcp"

# Sysctl security settings
sysctl net.ipv4.conf.all.rp_filter | grep "= 1"
sysctl net.ipv4.conf.all.accept_redirects | grep "= 0"
sysctl net.ipv4.tcp_syncookies | grep "= 1"

# HTTP to HTTPS redirect check
# Site: test.cluster.local
curl -I -L http://test.cluster.local | grep -q "301 Moved Permanently" && echo "HTTP to HTTPS redirect works"
curl -I -k https://test.cluster.local | grep -q "200 OK" && echo "HTTPS works"

# Site: ci.cluster.local
curl -I -L http://ci.cluster.local | grep -q "301 Moved Permanently" && echo "HTTP to HTTPS redirect works"
curl -I -k https://ci.cluster.local | grep -q "200 OK" && echo "HTTPS works"

# Site: status.cluster.local
curl -I -L http://status.cluster.local | grep -q "301 Moved Permanently" && echo "HTTP to HTTPS redirect works"
curl -I -k https://status.cluster.local | grep -q "200 OK" && echo "HTTPS works"

# Network listening
netstat -tulpn | grep nginx
ss -tlnp | grep nginx
lsof -i :80
lsof -i :443

# Logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/test.cluster.local_access.log
tail -f /var/log/nginx/test.cluster.local_error.log
tail -f /var/log/nginx/ci.cluster.local_access.log
tail -f /var/log/nginx/ci.cluster.local_error.log
tail -f /var/log/nginx/status.cluster.local_access.log
tail -f /var/log/nginx/status.cluster.local_error.log
```