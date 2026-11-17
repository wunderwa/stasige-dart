#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

cat > .gitignore <<'EOF'
# Dart
.dart_tool/
.packages
pubspec.lock
build/

# build output
/dist/
/dev/

# demo copies of template in repo root (templates/default is source of truth)
/views/
/pages/
/data/
/styles/
/scripts/
/assets/
/css/
/wrk
/bin/wrk.dart
/build.json

# IDE
.idea/
*.iml
.vscode/

# OS
.DS_Store
*.log
EOF

echo "==> git status --short"
git add -A
git status --short
