Migration Summary for fastapi_tutorial:
  Total items: 11
  Completed: 11
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
- [x] cookbooks/fastapi-tutorial/recipes/default.rb → ./ansible/roles/fastapi_tutorial/tasks/install.yml (complete) - Converted Chef recipe to Ansible tasks

### Attributes → Variables
- [x] N/A → ./ansible/roles/fastapi_tutorial/vars/main.yml (complete) - Created variables file with all required settings

### Structure Files
- [x] cookbooks/fastapi-tutorial/metadata.rb → ./ansible/roles/fastapi_tutorial/meta/main.yml (complete) - Created meta/main.yml with role metadata
- [x] N/A → ./ansible/roles/fastapi_tutorial/tasks/main.yml (complete) - Created main tasks file that imports install.yml
- [x] N/A → ./ansible/roles/fastapi_tutorial/defaults/main.yml (complete) - Created defaults file with configurable variables
- [x] N/A → ./ansible/roles/fastapi_tutorial/handlers/main.yml (complete) - Created handlers file with systemd reload and service restart handlers
- [x] N/A → ansible/roles/fastapi_tutorial/meta/main.yml (complete)

### Dependencies (requirements.yml)
- [x] collection:community.postgresql → ./ansible/roles/fastapi_tutorial/requirements.yml (complete) - Added community.postgresql collection to requirements.yml
- [x] collection:ansible.posix → ./ansible/roles/fastapi_tutorial/requirements.yml (complete) - Added ansible.posix collection to requirements.yml


Telemetry:
Phase: migrate
Duration: 0.00s

Agent Metrics:
  AAPDiscoveryAgent: 0.00s
  PlanningAgent: 48.34s
    Tools: add_checklist_task: 10, list_checklist_tasks: 2, list_directory: 2, read_file: 2
  WriteAgent: 130.00s
    Tools: ansible_lint: 3, ansible_write: 13, list_checklist_tasks: 2, read_file: 2, update_checklist_task: 10, write_file: 3
    attempts: 1
    complete: True
    files_created: 11
    files_total: 11
  ValidationAgent: 11.19s
    collections_installed: 2
    collections_failed: 0
    validators_passed: ['ansible-lint', 'role-check']
    validators_failed: []
    attempts: 0
    complete: True
    has_errors: False