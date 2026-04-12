# Bitbucket Data Center — API Auth & Data Fetch

## 1. Check Prerequisites

Verify the user has set both environment variables.
If either is missing, stop immediately and print:

```
⚠️  Missing credentials. Set these in PowerShell before invoking this command:

  $Env:BITBUCKET_HOST   = "bitbucket.mycompany.com"    # DC hostname only — no https://
  $Env:BITBUCKET_TOKEN  = "your-personal-access-token"

To generate a PAT in Bitbucket DC:
  Profile (top-right avatar) → Manage Account → Personal Access Tokens → Create token
  Required permissions: Repository = Read  |  Pull Requests = Read

Then re-run: /review-pr <pr-url>
```

---

## 2. Parse the PR URL

`$ARGUMENTS` is a Bitbucket Data Center PR URL in this format:

```
https://{host}/projects/{projectKey}/repos/{repoSlug}/pull-requests/{pr_id}
```

Extract:
- `host`       → e.g. `bitbucket.mycompany.com`
- `projectKey` → e.g. `OPS`
- `repoSlug`   → e.g. `ansible-webservers`
- `pr_id`      → e.g. `42`

All API calls use base: `https://{host}/rest/api/latest`

If the URL does not match this structure, stop and print:
```
❌ URL not recognised as a Bitbucket Data Center PR URL.
Expected: https://{host}/projects/{projectKey}/repos/{repoSlug}/pull-requests/{pr_id}
```

---

## 3. API Calls

All requests use:
```
Authorization: Bearer {BITBUCKET_TOKEN}
Accept: application/json
```

**Error handling — stop immediately:**

| HTTP Status | Message to print |
|---|---|
| `401` | `❌ Auth failed. BITBUCKET_TOKEN is invalid or expired. Regenerate at: Profile → Manage Account → Personal Access Tokens` |
| `403` | `❌ Permission denied. Token needs Repository Read + Pull Request Read on this repo.` |
| `404` | `❌ PR not found. Double-check projectKey, repoSlug, and pr_id in the URL.` |

### Call 1 — PR Metadata
```
GET https://{host}/rest/api/latest/projects/{projectKey}/repos/{repoSlug}/pull-requests/{pr_id}
```
Extract:
- `title`                   → PR title
- `id`                      → PR number
- `author.user.displayName` → author name
- `fromRef.displayId`       → source branch
- `toRef.displayId`         → target branch

### Call 2 — Changed File List
```
GET https://{host}/rest/api/latest/projects/{projectKey}/repos/{repoSlug}/pull-requests/{pr_id}/changes
```
Extract `path.toString` from each entry in `values[]`.
If `isLastPage` is `false`, paginate using `?start={nextPageStart}` until all files are collected.

### Call 3 — Unified Diff
```
GET https://{host}/rest/api/latest/projects/{projectKey}/repos/{repoSlug}/pull-requests/{pr_id}/diff
```
Returns full unified diff text — this is the primary review input.
Parse hunk headers (`@@ -x,y +a,b @@ filename`) to map each added line (`+` prefix, excluding `+++`) to its file path and line number.
