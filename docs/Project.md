
This document walks through everything you’ve done—from GPU auto-detection to repo-level CI/CD and automation scripts—then shows you how to verify each step and automate those tests in GitHub Actions.
1. Prerequisites
- Linux machine with Intel/NVIDIA hybrid GPU  
- Bash, Git, ssh, `udevadm` installed  
- GitHub account with SSH key or Personal Access Token (PAT)  
- `pandoc` and TeX (for PDF builds) on CI runner  

2. GPU Auto-Switch Script & udev Rule

2.1. Script: `scripts/gpu-switch.sh`

```bash
#!/usr/bin/env bash
LOG="/var/log/gpu-switch.log"
PSY="USB-C-0"  # adjust from `ls /sys/class/power_supply`
ONLINE_FILE="/sys/class/power_supply/$PSY/online"

state=$(cat "$ONLINE_FILE")
echo "$(date -Iseconds) Dock online? $state" >> "$LOG"

if [[ $state -eq 1 ]]; then
  # Enable NVIDIA GPU
  prime-select nvidia
else
  # Switch to Intel GPU
  prime-select intel
fi
```

- Ensure executable:  
  ```bash
  sudo chmod +x scripts/gpu-switch.sh
  ```

2.2. udev Rule: `rules/99-gpu-switch.rules`

```udev
# Trigger on dock plug/unplug
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_NAME}=="USB-C-0", ATTR{online}=="1", RUN+="/usr/local/bin/gpu-switch.sh"
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_NAME}=="USB-C-0", ATTR{online}=="0", RUN+="/usr/local/bin/gpu-switch.sh"
```

- Copy to `/etc/udev/rules.d/` and reload:  
  ```bash
  sudo cp rules/99-gpu-switch.rules /etc/udev/rules.d/
  sudo udevadm control --reload-rules
  sudo udevadm trigger
  ```

---
3. Git Repository Setup

```
gpu-dock-auto-switch/
├── LICENSE
├── README.md
├── PROJECT.md         ← This document
├── .gitignore
├── scripts/
│   └── gpu-switch.sh
├── rules/
│   └── 99-gpu-switch.rules
└── .github/
    └── workflows/
        ├── ci-template.yml   ← Shared reusable workflow (in .github repo)
        └── ci.yml            ← Stub to call shared CI
```

1. Initialize and add SSH remote:  
   ```bash
   git init
   git remote add origin git@github.com:JohnYoungSuh/ubuntu_apps-gpu_auto_switch.git
   git add .
   git commit -m "Initial commit: GPU auto-switch + CI/CD setup"
   git push -u origin main
   ```

---

4. CI/CD with GitHub Actions
4.1. Shared Reusable Workflow (`ci-template.yml` in `.github` repo)

```yaml
name: Shared CI

on:
  workflow_call:
    inputs:
      pdf-name:
        required: true
        type: string

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install dependencies
        run: sudo apt update && sudo apt install -y pandoc texlive-xetex shellcheck markdownlint

      - name: Lint shell scripts
        run: shellcheck scripts/*.sh

      - name: Lint markdown
        run: markdownlint PROJECT.md README.md

      - name: Build PDF
        run: |
          pandoc PROJECT.md --pdf-engine=xelatex \
            -V geometry:margin=1in -o "${{ inputs.pdf-name }}.pdf"

      - name: Commit artifacts
        run: |
          git config user.name "CI Bot"
          git config user.email "ci@github.com"
          git add "${{ inputs.pdf-name }}.pdf" || echo "No changes"
          git commit -m "Auto-update PDF" || echo "Nothing to commit"
          git push
```
4.2. Stub Workflow (`.github/workflows/ci.yml` in project repo)

```yaml
name: Build & Test
on:
  push:
    branches: [main]
jobs:
  call-shared-ci:
    uses: JohnYoungSuh/.github/.github/workflows/ci-template.yml@main
    with:
      pdf-name: gpu-dock-auto-switch
  # You can add more jobs here: e.g., deploy, notify, etc.
```

---
5. Automation Script for Stubs

Place this on your workstation (e.g. `~/scripts/add-ci-stub.sh`):

```bash
#!/usr/bin/env bash
set -e
export GH_TOKEN=ghp_your_fine_grained_token

for repo in $(gh repo list JohnYoungSuh --json name --jq '.[].name'); do
  echo "Adding stub to $repo"
  gh api repos/JohnYoungSuh/$repo/contents/.github/workflows/ci.yml \
    -f message="chore: add reusable CI stub" \
    -f content="$(base64 <<<'name: Build & Test

on:
  push:
    branches: [main]

jobs:
  call-shared-ci:
    uses: JohnYoungSuh/.github/.github/workflows/ci-template.yml@main
    with:
      pdf-name: gpu-dock-auto-switch
') \
    -f branch=main \
    || echo "Failed for $repo"
done
```

Make it executable and run:
```bash
chmod +x ~/scripts/add-ci-stub.sh
~/scripts/add-ci-stub.sh
```

---

6. Manual Testing Checklist

1. **Script & Rule**  
   - Plug/unplug dock → verify `/var/log/gpu-switch.log` updates.  
   - Check `prime-select query` matches expected GPU.

2. **Git & Remote**  
   - `git remote -v` shows SSH URL.  
   - `git push`/`git pull` works without password.

3. **CI Workflow**  
   - On push, GitHub Actions → **Build & Test** runs successfully.  
   - Artifacts: generated PDF appears in repo root.

4. **Stub Automation**  
   - New repos under your account receive `.github/workflows/ci.yml`.

---

7. Automating Tests Based on Documentation

You can extend your CI to **automatically test** every instruction:

- **Shell Tests**:  
  - Use [Bats](https://github.com/bats-core/bats-core) to write tests for `gpu-switch.sh` logic.  
  - Simulate `online` values by mocking `/sys/class/power_supply/$PSY/online`.

- **Markdown Tests**:  
  - Run `markdownlint` to catch formatting errors.  
  - Use a link checker (e.g., `markdown-link-check`) to ensure internal references exist.

- **PDF Build Test**:  
  - Fail the job if `pandoc` exits non-zero or if the PDF file is missing.

- **udev Rule Simulation**:  
  - In a privileged Docker container, use `udevadm test $(udevadm info --path=...)` to verify rule parsing.

Sample “test.yml” Workflow

```yaml
name: Smoke Tests
on:
  workflow_call:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install test tools
        run: sudo apt update && sudo apt install -y bats markdownlint pandoc texlive-xetex
      - name: Run shell tests
        run: bats tests/gpu-switch.bats
      - name: Lint markdown
        run: markdownlint .
      - name: Build and verify PDF
        run: |
          pandoc PROJECT.md -o test.pdf
          [ -s test.pdf ]
```
You can call this `test.yml` from your stub or chain it with `ci-template.yml` for a full validation suite.
