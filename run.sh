#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "==> write .gitignore"
cat > .gitignore <<'EOF'
# Dart
.dart_tool/
.packages
pubspec.lock
build/

# build output
dist/
dev/

# demo (не часть пакета; у пользователя создаются через `stasige init`)
/views/
/pages/
/data/
/build.json

# IDE
.idea/
*.iml
.vscode/

# OS
.DS_Store
*.log
EOF

echo "==> remove demo dart files"
rm -f bin/debug_menu.dart bin/site.dart

echo "==> untrack demo dart files (if staged)"
git rm -r --cached --ignore-unmatch bin/debug_menu.dart bin/site.dart >/dev/null 2>&1 || true

echo "==> done"