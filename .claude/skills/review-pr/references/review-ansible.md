# Ansible Review Checklist

Evaluate only **added lines** from the unified diff (lines prefixed with `+`, excluding `+++`).
Use hunk headers to determine file name and line number for every finding.

---

## 🔴 SECURITY — CREDENTIAL & SECRET HYGIENE (CRITICAL — blocks merge)

Every match below is a **Critical Issue**. Flag with file, line, matched pattern, and required fix.

**Flag these patterns on added lines:**
- `password:`, `passwd:`, `secret:`, `api_key:`, `token:`, `private_key:` followed by a plain non-Jinja2 string
- Connection strings matching `://someuser:somepassword@`
- Long inline base64 blobs: strings matching `[A-Za-z0-9+/]{40,}={0,2}` not inside a Jinja2 expression
- Lines containing `-----BEGIN` — private key material (SSH keys, TLS certs, GPG keys)
- `ansible_password:` or `ansible_become_password:` set to a plain string
- LDAP/AD bind credentials: `bind_pw:`, `ldap_password:`, `ad_password:` set to a plain string
- Database credentials: `db_password:`, `db_pass:`, `jdbc_password:` set to a plain string
- Any key named `*_password`, `*_secret`, `*_token`, `*_key` set to a plain non-Jinja2 string

**Do NOT flag — these are safe:**
- `"{{ vault_... }}"` — Ansible Vault reference ✅
- `"{{ lookup('env', '...') }}"` — environment variable lookup ✅
- `"{{ some_variable }}"` — pure Jinja2 variable reference ✅
- `"{{ ... | default('') }}"` — variable with default ✅

---

## 🟡 BEST PRACTICES (warnings — should fix)

**Idempotency**
- [ ] `command:`/`shell:` tasks define both `changed_when:` and `failed_when:`
- [ ] Native Ansible modules used where available instead of `shell:` (e.g., `copy:` not `shell: cp`)
- [ ] Destructive commands (`rm -rf`, `reboot`) have a `when:` guard

**Task Quality**
- [ ] Every task has a non-empty `name:` field
- [ ] `ignore_errors: true` is accompanied by an explanatory comment

**Variables & Defaults**
- [ ] No hardcoded absolute paths like `/home/ubuntu/` — use variables or Ansible facts
- [ ] Variable names use `snake_case`
- [ ] `vars/main.yml` is not used for secrets

**Conditionals & Loops**
- [ ] `when:` uses Jinja2 boolean expressions, not `== True` or `== False`
- [ ] `loop:` preferred over deprecated `with_items:`

**Handlers**
- [ ] Services restarted via `notify:` + handler — not inline `service: state=restarted`
- [ ] Handler names are unique across the role

**Privilege Escalation**
- [ ] `become: true` applied at task level where possible, not blanket play level
- [ ] `become_user:` is explicit when target user is not `root`

**Templates & Files**
- [ ] Jinja2 templates use `.j2` extension
- [ ] Config files use `validate:` where supported (nginx, sudoers, sshd_config)

**Testing**
- [ ] New or changed roles include or update Molecule scenarios
