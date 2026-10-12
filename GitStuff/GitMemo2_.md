# Memo

## Prompt
_

Here are three refined versions of the Git branch management policy:  

---

### **1. Official Bilingual Memorandum (EN/RU)**  
**[For Both Developers and Release Managers]**  

#### **Git Branch Management Policy**  
**Date:** [Current Date]  
**To:** Development Team  
**From:** [Your Name/Position]  

---  

#### **A. Developer Responsibilities**  
1. **Branch Hygiene:**  
   - Delete merged branches promptly.  
   - Use annotated tags for postponed work.  
   - Audit personal branches weekly.  

   **Commands:**  
   ```sh
   # Delete merged branches
   git branch -d feature/xyz  
   git push origin --delete feature/xyz

   # Tag postponed features
   git tag -a postponed/feature-123 -m "Pending UX review"
   git push origin postponed/feature-123
   ```  

2. **Stale Branch Checks:**  
   ```sh
   # List inactive branches (>30 days)
   git for-each-ref --format='%(committerdate:iso8601) %(refname:short)' --sort=-committerdate | grep -v 'main\|master'
   ```  

---  

#### **B. Release Manager Duties**  
1. **Repository Maintenance:**  
   - Enforce branch cleanup policies.  
   - Send monthly reminders via automation.  
   - Manage `on-hold` tags with blockers.  

   **Commands:**  
   ```sh
   # Force-delete abandoned branches
   git push origin --delete abandoned-feature

   # Create release-hold tags
   git tag -a on-hold/payment-api -m "Blocked by PCI compliance (ETA: Jun 2024)"
   ```  

2. **Automation Scripts:**  
   ```sh
   # Cron job for stale branches
   git for-each-ref --format='%(authorname)|%(refname:short)|%(committerdate:relative)' | mail -s "Stale Branch Report" team@example.com
   ```  

---  
**References:**  
- Git Docs: [Branching](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell)  
- Internal: [BRANCH_POLICY.md](link)  

---  

### **2. Expanded Guide for Developers**  
#### **Git Branch Management: Developer’s Handbook**  

**1. Daily/Weekly Tasks:**  
- **After Merging:**  
  ```sh
  git checkout main && git pull  
  git branch --merged | xargs git branch -d
  ```  

- **Postponing Work:**  
  ```sh
  git tag -a delayed/feature-456 -m "Awaiting legal approval (Ref: ticket #789)"  
  git push origin delayed/feature-456
  ```  

**2. Troubleshooting:**  
- **Recovering Deleted Branches:**  
  ```sh
  git reflog | grep 'feature-xyz'  # Find lost commits
  git checkout -b feature-xyz <commit-hash>
  ```  

**3. Best Practices:**  
✅ Prefix branches: `feat/`, `fix/`, `exp/`  
✅ Tag dependencies: `needs/backend-api`  

---  

### **3. Release Manager’s Playbook**  
#### **Advanced Repository Governance**  

**1. Compliance Controls:**  
- **Branch Age Policy:**  
  ```sh
  # List branches >60 days old
  git for-each-ref --format='%(committerdate:iso8601)|%(refname:short)|%(authorname)' | awk -F'|' '$1 < "'$(date -d "60 days ago" +%Y-%m-%d)'" {print}'
  ```  

- **Tagging Standards:**  
  ```sh
  git tag -a deprecated/v1-legacy -m "Retired on $(date +%Y-%m-%d). Migrate to v2."
  ```  

**2. Automation Templates:**  
- **Slack Reminder Script:**  
  ```python
  #!/bin/python
  import subprocess
  stale_branches = subprocess.check_output("git for-each-ref --format='%(refname:short)' --no-merged=main", shell=True)
  post_to_slack(f"⚠️ Stale branches:\n{stale_branches}")
  ```  

**3. Escalation Paths:**  
- **Unresponsive Owners:**  
  ```sh
  git log branch-name --pretty="%an|%ae" | head -1  # Identify last author
  ```  

---  

**Style Notes:**  
- **Developers:** Step-by-step with troubleshooting.  
- **Release Managers:** Emphasis on automation/compliance.  
- **Bilingual:** For global teams.  

Let me know if you'd like to adjust the tone (e.g., more formal for auditors).

