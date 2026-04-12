# Output Format & Verdict Logic

## Verdict Decision

Count all confirmed Critical Issues across all applied review modules.

```
IF critical_issues_count > 0  →  verdict = "❌ DECLINED"
ELSE                          →  verdict = "✅ APPROVED"
```

---

## Output Template

Produce output **exactly** in this structure:

```
## PR Review: {PR title} — #{pr_id}
🔗 {full PR URL}
👤 Author: {author display name}
🔀 {source_branch} → {target_branch}
🔍 Stack(s): {detected stacks and trigger reason}

---
## Verdict: ❌ DECLINED
---
> This PR is DECLINED and must NOT be merged.
> {X} critical issue(s) found. All must be resolved before this PR can be approved.

─── replace the DECLINED block above with a one-line approval note when APPROVED ───

### 🔴 Critical Issues  (blocks merge — must fix)

| # | File | Line | Finding | Required Fix |
|---|------|------|---------|--------------|
| 1 | roles/nginx/tasks/main.yml | 14 | Hardcoded `password: S3cr3t123` | Replace with `{{ vault_nginx_password }}` |

(Omit this section entirely if no critical issues found)

### 🟡 Warnings  (should fix before merge)
- `roles/common/tasks/main.yml:32` — `shell: cp` used where `copy:` module exists. Replace with `copy:` module.

### 🟢 Suggestions  (nice to have)
- ...

### ✅ Looks Good
- ...

### Summary
{2–3 sentence assessment. End with exactly one of:}
  🚫 DO NOT MERGE — resolve critical issues first.
  👍 Safe to merge after addressing warnings.
  ✅ Good to merge.
```

---

## Hard Rules

- Verdict banner is **always first** — immediately after the PR metadata header.
- Every finding must include: file path, line number from diff hunk, exactly what was found, and a concrete required fix.
- Never soften language on Critical Issues. No "consider" or "might want to". Say "must fix".
- Never fabricate findings. Only flag what is confirmed present in the diff.
- If the diff is empty or PR has no changed files, print: `⚠️  No changes found in this PR diff. Nothing to review.`
