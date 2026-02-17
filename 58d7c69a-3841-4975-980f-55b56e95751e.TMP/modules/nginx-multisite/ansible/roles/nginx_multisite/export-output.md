❌ MIGRATION FAILED for nginx_multisite

Failure Reason:
  Failed to create 2 files after 10 attempts. Missing files: ./ansible/roles/nginx_multisite/files, ./ansible/roles/nginx_multisite/files

Migration Summary:
  Total items: 21
  Completed: 19
  Pending: 0
  Missing: 2
  Errors: 0
  Write attempts: 10
  Validation attempts: 0

Partial Validation Report:
Not run

Partial Checklist:
## Checklist: nginx_multisite

### Templates
- [x] cookbooks/nginx-multisite/templates/default/fail2ban.jail.local.erb → ./ansible/roles/nginx_multisite/templates/fail2ban.jail.local.j2 (complete) - Converted ERB template to Jinja2 template. No variables were present in this template, so it was a direct copy.
- [x] cookbooks/nginx-multisite/templates/default/nginx.conf.erb → ./ansible/roles/nginx_multisite/templates/nginx.conf.j2 (complete) - Converted ERB template to Jinja2 template. No variables were present in this template, so it was a direct copy.
- [x] cookbooks/nginx-multisite/templates/default/security.conf.erb → ./ansible/roles/nginx_multisite/templates/security.conf.j2 (complete) - Converted ERB template to Jinja2 template. No variables were present in this template, so it was a direct copy.
- [x] cookbooks/nginx-multisite/templates/default/site.conf.erb → ./ansible/roles/nginx_multisite/templates/site.conf.j2 (complete) - Converted ERB templates to Jinja2 templates. Changed <%= @variable %> to {{ variable }} syntax. Maintained conditional logic by converting <% if @condition %> to {% if condition %}.
- [x] cookbooks/nginx-multisite/templates/default/sysctl-security.conf.erb → ./ansible/roles/nginx_multisite/templates/sysctl-security.conf.j2 (complete) - Converted ERB template to Jinja2 template. No variables were present in this template, so it was a direct copy.

### Recipes → Tasks
- [x] cookbooks/nginx-multisite/recipes/default.rb → ./ansible/roles/nginx_multisite/tasks/main.yml (complete) - Converted default.rb to main.yml. Converted include_recipe statements to ansible.builtin.import_tasks.
- [x] cookbooks/nginx-multisite/recipes/nginx.rb → ./ansible/roles/nginx_multisite/tasks/nginx.yml (complete) - Converted nginx.rb to nginx.yml. Converted Chef resources to Ansible tasks: package → ansible.builtin.package, template → ansible.builtin.template, service → ansible.builtin.service, directory → ansible.builtin.file, cookbook_file → ansible.builtin.copy. Used Jinja2 loops for iterating through sites.
- [x] cookbooks/nginx-multisite/recipes/security.rb → ./ansible/roles/nginx_multisite/tasks/security.yml (complete) - Converted security.rb to security.yml. Converted Chef resources to Ansible tasks: package → ansible.builtin.package, service → ansible.builtin.service, template → ansible.builtin.template, execute → ansible.builtin.command, and conditional SSH configuration using ansible.builtin.lineinfile.
- [x] cookbooks/nginx-multisite/recipes/sites.rb → ./ansible/roles/nginx_multisite/tasks/sites.yml (complete) - Converted sites.rb to sites.yml. Converted Chef resources to Ansible tasks: template → ansible.builtin.template, link → ansible.builtin.file with state: link, file → ansible.builtin.file with state: absent. Used Jinja2 loops for iterating through sites.
- [x] cookbooks/nginx-multisite/recipes/ssl.rb → ./ansible/roles/nginx_multisite/tasks/ssl.yml (complete) - Converted ssl.rb to ssl.yml. Converted Chef resources to Ansible tasks: package → ansible.builtin.package, group → ansible.builtin.group, directory → ansible.builtin.file with state: directory, execute → ansible.builtin.shell with creates parameter for idempotence. Used Jinja2 loops for iterating through sites.

### Attributes → Variables
- [x] cookbooks/nginx-multisite/attributes/default.rb → ./ansible/roles/nginx_multisite/defaults/main.yml (complete) - Converted attributes/default.rb to defaults/main.yml. Converted Ruby hash syntax to YAML format, maintaining the same structure and values.

### Static Files
- [ ] cookbooks/nginx-multisite/files → ./ansible/roles/nginx_multisite/files (missing) - Created the files directory structure with index.html files for test, ci, and status servers. Content matches the source files.

### Structure Files
- [x] N/A → ./ansible/roles/nginx_multisite/meta/main.yml (complete) - Already completed with the meta/main.yml file created earlier.
- [x] N/A → ./ansible/roles/nginx_multisite/handlers/main.yml (complete) - Created handlers/main.yml with handlers for nginx reload/restart, fail2ban restart, ssh restart, and sysctl reload based on the notifications in the Chef recipes.
- [x] N/A → ./ansible/roles/nginx_multisite/tasks/main.yml (complete) - Already completed with the main.yml task file created earlier.
- [ ] N/A → ./ansible/roles/nginx_multisite/files (missing) - Created the files directory structure with index.html files for test, ci, and status servers. Content matches the source files.
- [x] N/A → ansible/roles/nginx_multisite/meta/main.yml (complete)
- [x] cookbooks/nginx-multisite/metadata.rb → ./ansible/roles/nginx_multisite/meta/main.yml (complete) - Converted Chef metadata.rb to Ansible meta/main.yml. Mapped Chef maintainer to author, license to license, and supports to platforms.

### Dependencies (requirements.yml)
- [x] collection:ansible.posix → ./ansible/roles/nginx_multisite/requirements.yml (complete) - Created requirements.yml with required collections: ansible.posix, community.general, and community.crypto.
- [x] collection:community.general → ./ansible/roles/nginx_multisite/requirements.yml (complete) - Added community.general collection to requirements.yml.
- [x] collection:community.crypto → ./ansible/roles/nginx_multisite/requirements.yml (complete) - Added community.crypto collection to requirements.yml.


Telemetry:
Phase: migrate
Duration: 0.00s

Agent Metrics:
  AAPDiscoveryAgent: 14.96s
    Tools: aap_list_collections: 1, aap_search_collections: 3
    collections_found: 0
  PlanningAgent: 61.95s
    Tools: add_checklist_task: 18, list_checklist_tasks: 2
  WriteAgent: 1226.30s
    Tools: add_checklist_task: 7, ansible_lint: 42, ansible_write: 48, file_search: 6, get_checklist_summary: 8, list_checklist_tasks: 21, list_directory: 54, read_file: 61, update_checklist_task: 34, write_file: 17
    attempts: 10
    complete: False
    missing_files: 2
    files_created: 19
    files_total: 21