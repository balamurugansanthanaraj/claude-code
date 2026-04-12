# Helm Review Checklist

> 🚧 Checklist content to be added.
> Apply this file when the detected stack is Helm Chart or Helm Values.

Evaluate only **added lines** from the unified diff (lines prefixed with `+`, excluding `+++`).
Use hunk headers to determine file name and line number for every finding.

---

## Helm Chart vs Helm Values

Determine sub-type from the file list:
- Changed files include `Chart.yaml` → **Helm Chart** review
- Changed files include `values*.yaml` → **Helm Values** review
- Both present → apply both sections below

---

## 🔴 SECURITY (CRITICAL — blocks merge)

_(To be defined)_

---

## 🟡 BEST PRACTICES (warnings)

_(To be defined)_

---

## 🟢 SUGGESTIONS

_(To be defined)_
