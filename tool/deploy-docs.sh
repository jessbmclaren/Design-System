#!/usr/bin/env bash
# Build the docs app and publish it to the `gh-pages` branch for GitHub Pages.
#
# The docs are a Flutter web app; GitHub cannot build Flutter, so we build
# locally (with the toolchain that is known to work) and push the compiled
# output to an orphan `gh-pages` branch. Enable it once under
#   Settings -> Pages -> Source: Deploy from a branch -> gh-pages -> / (root)
# and the site lives at https://<owner>.github.io/<repo>/.
#
# Usage:  ./tool/deploy-docs.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXAMPLE_DIR="$REPO_ROOT/example"
BASE_HREF="/Design-System/"   # the project-pages subpath
WORKTREE="$(mktemp -d)"

echo "==> Building docs (release, base-href $BASE_HREF)"
cd "$EXAMPLE_DIR"
flutter build web --release --no-tree-shake-icons --base-href "$BASE_HREF"

echo "==> Publishing build/web to gh-pages"
cd "$REPO_ROOT"
SHA="$(git rev-parse --short HEAD)"
# A fresh worktree on an orphan gh-pages branch keeps main's history clean.
git worktree remove --force "$WORKTREE" 2>/dev/null || true
git worktree add --force -B gh-pages "$WORKTREE"
# Replace the worktree contents with the freshly built site.
find "$WORKTREE" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
cp -R "$EXAMPLE_DIR/build/web/." "$WORKTREE/"
touch "$WORKTREE/.nojekyll"   # stop Jekyll from dropping _-prefixed assets
cd "$WORKTREE"
git add -A
git commit -q -m "Deploy docs ($SHA)" || { echo "No changes to deploy."; }
git push -f origin gh-pages
cd "$REPO_ROOT"
git worktree remove --force "$WORKTREE"
echo "==> Done. Enable Settings -> Pages -> gh-pages -> / (root) if you haven't."
