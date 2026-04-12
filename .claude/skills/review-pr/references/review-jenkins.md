# Jenkins Shared Library Review Checklist

Evaluate only **added lines** from the unified diff (lines prefixed with `+`, excluding `+++`).
Use hunk headers to determine file name and line number for every finding.

---

## 🔴 SECURITY — CREDENTIAL & SECRET HYGIENE (CRITICAL — blocks merge)

Every match below is a **Critical Issue**. Flag with file, line, matched pattern, and required fix.

**Flag these patterns on added lines:**
- Variables named `*Password`, `*Secret`, `*Token`, `*Key` assigned a plain string literal
- `password =`, `secret =`, `token =` followed by a quoted string value
- Lines containing `-----BEGIN` — private key material embedded in code
- Direct inline credential strings passed to `sh` steps instead of using `withCredentials`

**Do NOT flag — these are safe:**
- `credentials('credential-id')` — Jenkins credentials binding ✅
- `env.MY_SECRET` — environment variable reference ✅
- `params.MY_PARAM` — pipeline parameter reference ✅
- `withCredentials([...])` block — correct credential handling ✅

---

## 🟡 BEST PRACTICES (warnings — should fix)

**Code Quality**
- [ ] Shared library methods have a Groovydoc comment describing inputs and return value
- [ ] No `System.exit()` calls — use `error()` or set `currentBuild.result` instead
- [ ] No hardcoded node labels like `node('linux')` — use a parameter or global config variable
- [ ] `sh` steps capture return value with `returnStatus: true` or `returnStdout: true` where it matters

**Error Handling**
- [ ] `try/catch` blocks present around steps that can fail (SCM checkouts, external calls)
- [ ] `finally` block used to clean up workspaces or release resources where relevant

**Pipeline Hygiene**
- [ ] `@NonCPS` only used on pure Groovy methods — never on methods that call pipeline steps
- [ ] `sleep()` not used — prefer `waitUntil` or `timeout` blocks instead
- [ ] `println` not used for logging — use `echo` so output appears in pipeline console logs

---

## 🟢 SUGGESTIONS (personal nudge)

**Pipeline file changes — testing reminder**

Check the changed file list. If **any changed file name starts with `pipeline`**
(e.g. `pipeline.groovy`, `pipelineUtils.groovy`, `pipeline-deploy.groovy`):

Add this in the Suggestions section of the output:
```
💬 Hope it was tested — changes to pipeline files can affect all consuming jobs.
   Please confirm this was validated in a non-production pipeline run before merging.
```
