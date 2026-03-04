✅ Migration Summary for fastapi_tutorial:
  Total items: 12
  Completed: 12
  Pending: 0
  Missing: 0
  Errors: 0
  Write attempts: 1
  Validation attempts: 0

Final Validation Report:
All migration tasks have been completed successfully

All validations passed

Final checklist:
## Checklist: fastapi_tutorial

### Templates
- [x] N/A → ./ansible/roles/fastapi_tutorial/templates/env.j2 (complete) - Created Jinja2 template for environment configuration file
- [x] N/A → ./ansible/roles/fastapi_tutorial/templates/fastapi-tutorial.service.j2 (complete) - Created Jinja2 template for systemd service file

### Recipes → Tasks
- [x] cookbooks/fastapi-tutorial/recipes/default.rb → ./ansible/roles/fastapi_tutorial/tasks/main.yml (complete) - Converted Chef recipe to Ansible tasks

### Attributes → Variables
- [x] cookbooks/fastapi-tutorial/recipes/default.rb → ./ansible/roles/fastapi_tutorial/vars/main.yml (complete) - Created variables file from Chef recipe attributes

### Structure Files
- [x] cookbooks/fastapi-tutorial/metadata.rb → ./ansible/roles/fastapi_tutorial/meta/main.yml (complete) - Created meta/main.yml from Chef metadata.rb
- [x] N/A → ./ansible/roles/fastapi_tutorial/tasks/main.yml (complete) - Tasks file already created
- [x] N/A → ./ansible/roles/fastapi_tutorial/defaults/main.yml (complete) - Created defaults/main.yml with default variable values
- [x] N/A → ./ansible/roles/fastapi_tutorial/handlers/main.yml (complete) - Created handlers/main.yml with systemd reload handler
- [x] N/A → ansible/roles/fastapi_tutorial/meta/main.yml (complete)

### Dependencies (requirements.yml)
- [x] collection:community.postgresql → ./ansible/roles/fastapi_tutorial/requirements.yml (complete) - Created requirements.yml with required collections
- [x] collection:ansible.posix → ./ansible/roles/fastapi_tutorial/requirements.yml (complete) - Added ansible.posix collection to requirements.yml
- [x] collection:community.general → ./ansible/roles/fastapi_tutorial/requirements.yml (complete) - Added community.general collection to requirements.yml


Telemetry:
Phase: migrate
Duration: 0.00s

Agent Metrics:
  AAPDiscoveryAgent: 0.00s
  PlanningAgent: 55.84s
    Tools: add_checklist_task: 12, list_checklist_tasks: 3, list_directory: 2, read_file: 2
  WriteAgent: 101.95s
    Tools: ansible_lint: 1, ansible_write: 8, list_checklist_tasks: 2, read_file: 2, update_checklist_task: 11, write_file: 2
    attempts: 1
    complete: True
    files_created: 12
    files_total: 12
  ValidationAgent: 15.93s
    collections_installed: 3
    collections_failed: 0
    validators_passed: ['ansible-lint', 'role-check']
    validators_failed: []
    attempts: 0
    complete: True
    has_errors: False