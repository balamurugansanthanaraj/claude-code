# Stack Detection — Two-Tier Logic

Detection runs in two tiers. Tier 1 (repo name) is the primary signal and is always checked first. Tier 2 (file list) is used as fallback or for Helm refinement only.

---

## Tier 1 — Repo Name (primary)

Match `repoSlug` case-insensitively:

| Condition | Detected Stack |
|---|---|
| contains `ansible` | Ansible → stop, skip Tier 2 |
| contains `jenkins` | Jenkins Shared Library → stop, skip Tier 2 |
| contains `helm` OR contains `-infra` | Helm → proceed to Tier 2 to distinguish Chart vs Values |
| no keyword match | Unknown → run full Tier 2 |

Examples:
- `ansible-webservers` → **Ansible** ✅ done
- `jenkins-shared-library` → **Jenkins Shared Library** ✅ done
- `helm-platform-charts` → Helm confirmed, Tier 2 refines
- `platform-infra` → Helm confirmed, Tier 2 refines
- `k8s-infra` → Helm confirmed, Tier 2 refines
- `my-service` → no match, run Tier 2 for everything

---

## Tier 2 — Changed File List (fallback / Helm refinement)

| Stack | Signal |
|---|---|
| **Ansible** | `.yml`/`.yaml` under `roles/`, `playbooks/`, `tasks/`, `handlers/`, `defaults/`, `vars/`, `meta/`; or diff contains `hosts:` / `- name:` |
| **Jenkins Shared Library** | `.groovy` files under `vars/` or `src/` |
| **Helm Chart** | `Chart.yaml` present in changed files |
| **Helm Values** | `values*.yaml` present alongside a `Chart.yaml` |

> If multiple stacks are detected across both tiers, all relevant review modules will be applied.

---

## Detection Notice

Print before the review begins — state which tier triggered the match:

```
🔍 Detected stack(s): Ansible  (repo name: "ansible-webservers")
🔍 Detected stack(s): Helm Values  (repo name: "platform-infra" → refined by file list)
```
