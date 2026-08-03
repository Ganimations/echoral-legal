#!/bin/bash
# Publish Echoral legal pages to GitHub Pages (one-time GitHub login required).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SITE="$ROOT/echoral-legal"
ARCH="$(uname -m)"
GH="$ROOT/.deploy-tools/gh_2.65.0_macOS_${ARCH}/bin/gh"

if [[ ! -x "$GH" ]]; then
  echo "Missing gh CLI. Re-download from GitHub releases or run from project root."
  exit 1
fi

cd "$SITE"

if [[ ! -d .git ]]; then
  git init -b main
  git add .
  git commit -m "Add Echoral legal and support pages"
fi

if ! "$GH" auth status >/dev/null 2>&1; then
  echo ""
  echo "GitHub'a bir kez giriş yapman gerekiyor (tarayıcı açılacak)."
  echo "Önerilen kullanıcı adı: abdulganigungor"
  echo "E-posta: Ganiunchus@hotmail.com"
  echo ""
  "$GH" auth login -h github.com -p https -w
fi

USER="$("$GH" api user -q .login)"
REPO="echoral-legal"

if "$GH" repo view "$USER/$REPO" >/dev/null 2>&1; then
  echo "Repo exists: $USER/$REPO"
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$USER/$REPO.git"
  git push -u origin main
else
  "$GH" repo create "$REPO" --public --source=. --remote=origin --push
fi

"$GH" api "repos/$USER/$REPO/pages" \
  -f build_type=legacy \
  -f source[branch]=main \
  -f source[path]="/" >/dev/null 2>&1 || true

PRIVACY="https://$USER.github.io/$REPO/privacy.html"
SUPPORT="https://$USER.github.io/$REPO/support.html"

echo ""
echo "✓ Yayınlandı (GitHub Pages birkaç dakika sürebilir)"
echo ""
echo "App Store Connect → URL'ler:"
echo "  Privacy Policy URL: $PRIVACY"
echo "  Support URL:        $SUPPORT"
echo ""
echo "Kontrol:"
echo "  open $SUPPORT"
