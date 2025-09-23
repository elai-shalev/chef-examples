# X2Ansible - Infrastructure Migration Tool Specification

## Overview
X2Ansible is a stateless AI-powered tool that migrates infrastructure code from Chef, Puppet, and Salt to Ansible. All operations are Git-based with no persistent state.

## Project Structure
```
src/
├── inputs/
│   ├── chef.py          # Chef cookbook analyzer
│   ├── puppet.py        # Puppet manifest analyzer
│   ├── salt.py          # Salt state analyzer
│   └── analyze.py       # Root analyzer - detects technology and delegates
├── exporters/
│   └── ansible.py       # Ansible playbook generator
├── init.py              # Project initialization and analysis
├── migrate.py           # Migration orchestrator
└── validate.py          # Migration validation

app.py                   # Main CLI entry point
```

## Commands and Workflow

### 1. Project Initialization
```bash
app.py --init <git-repo-url>
```

**Target Audience**: Engineering managers and senior engineers requiring 10,000-foot view for planning and decision-making

**Purpose**: Clone infrastructure repository and create executive-level migration plan with effort estimates, risks, and strategic recommendations

**Process**:
1. Clone the specified Git repository
2. Analyze directory structure using `ls`/`grep` to detect technology (Chef cookbooks, Puppet manifests, Salt states)
3. Delegate to appropriate analyzer in `src/inputs/analyze.py`
4. Generate high-level migration overview with strategic insights
5. Create `MIGRATION-PLAN.md` with project summary and next steps

**Output**: `MIGRATION-PLAN.md` containing:
- Executive Summary: Technology stack, scale, and complexity assessment
- Detected infrastructure technology
- Repository structure overview
- Recommended migration approach

### 2. Detailed Analysis
```bash
app.py --analyze
```

**Target Audience**: Senior engineers who create subtasks for each component/module to migrate.
**Purpose**: Create dependency graph and granular migration tasks

**Process**:
1. `src/inputs/analyze.py` determines technology type
2. Delegates to specific analyzer (`chef.py`, `puppet.py`, or `salt.py`)
3. Technology-specific analyzer:
   - Maps all cookbooks/manifests/states
   - Analyzes dependencies between components
   - Creates dependency graph
   - Generates individual migration plans for each component

**Output**: Individual migration plan files:
- `migrate-security-plan.md`
- `migrate-nginx-plan.md`
- `migrate-postgres-plan.md`
- `migrate-kafka-plan.md`
- etc.

Each plan contains:
- Component overview and purpose
- Dependencies and requirements
- Current configuration analysis
- Proposed Ansible equivalent structure
- Migration complexity assessment

**Updates**: `MIGRATION-PLAN.md` with checklist:
```markdown
## Migration Tasks
- [ ] Migrate security cookbook (see migrate-security-plan.md)
- [ ] Migrate nginx cookbook (see migrate-nginx-plan.md)
- [ ] Migrate postgres cookbook (see migrate-postgres-plan.md)
- [ ] Migrate kafka cookbook (see migrate-kafka-plan.md)
```

### 3. Component Migration
```bash
app.py --migrate "component-name"
```
**Target Audience**: Engineers who need to proceed with the migration and want to use technology to accelerate their work.

**Examples**:
- `app.py --migrate "postgres"`
- `app.py --migrate "nginx"`
- `app.py --migrate "security"`

**Purpose**: Generate Ansible playbooks for specific component

**Process**:
1. `src/migrate.py` reads corresponding `migrate-{component}-plan.md`
2. Delegates to `src/exporters/ansible.py`
3. Ansible exporter:
   - Analyzes source configuration
   - Uses AI to convert logic to Ansible equivalent
   - Generates playbook files, roles, and variables
   - Creates directory structure following Ansible best practices

**Output**: Ansible files in `ansible/` directory:
```
ansible/
├── playbooks/
│   └── postgres.yml
├── roles/
│   └── postgres/
│       ├── tasks/main.yml
│       ├── handlers/main.yml
│       ├── vars/main.yml
│       └── templates/
└── inventory/
    └── group_vars/
```

### 4. Migration Validation
```bash
app.py --validate "component-name"
```
**Examples**:
- `app.py --validate "postgres"`
- `app.py --validate "nginx"`

**Purpose**: Compare original and generated configurations for consistency

**Process**:
1. `src/validate.py` analyzes both original and generated Ansible code
2. Performs semantic comparison of:
   - Package installations
   - Service configurations
   - File templates and variables
   - Security settings
   - Network configurations
3. Generates validation report

**Output**: `validation-{component}.md` containing:
- Configuration comparison matrix
- Identified discrepancies
- Manual verification checklist
- Pre-flight checks for deployment
- Recommended testing procedures

## Core Principles

### Stateless Operation
- No persistent databases or state files
- All information derived from Git repositories
- Results stored as markdown files in working directory

### AI-Driven Analysis
- Each module uses AI to understand configuration intent
- Context-aware conversion maintaining semantic equivalence
- Dependency analysis to ensure proper migration order

### Modular Architecture
- Technology-specific input analyzers
- Pluggable exporter system (currently Ansible, extensible)
- Separation of concerns between analysis, migration, and validation

## Error Handling
- Graceful degradation when components cannot be analyzed
- Clear error messages with suggested remediation
- Partial migration support (migrate what's possible, flag issues)

## Future Extensibility
- Additional exporters (Terraform, Kubernetes, etc.)
- Support for more input technologies
- Enhanced dependency resolution
- Integration with CI/CD pipelines

## Success Criteria
- Successful migration of common infrastructure patterns
- Generated Ansible code follows best practices
- Validation catches semantic differences
- Clear manual verification procedures
- Minimal human intervention required for straightforward migrations

