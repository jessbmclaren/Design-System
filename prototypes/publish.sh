#!/usr/bin/env bash
#
# Publish the EngenXT driver prototype.
#
# The prototype lives in two places: this private repository, where it is
# authored and where the review history is, and a public one, which exists
# only because GitHub Pages will not serve a private repo on a free plan.
# Those two copies drift the moment either changes, and the drift is silent:
# the live site simply keeps showing yesterday's work.
#
# This does the whole job in one command so the copy cannot be forgotten:
#   ./prototypes/publish.sh "why this changed"
#
# It is safe to run when nothing has changed, and it will tell you so.

set -euo pipefail

SOURCE_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROTOTYPE="$SOURCE_REPO/prototypes/engenxt-signup.html"
MIRROR_URL="https://github.com/jessbmclaren/EngenXT-Mobile-Sign-up.git"
MIRROR="${ENGENXT_MIRROR:-$HOME/Code/EngenXT-Mobile-Sign-up}"
LIVE="https://jessbmclaren.github.io/EngenXT-Mobile-Sign-up/"
MESSAGE="${1:-}"

say() { printf '  %s\n' "$*"; }
die() { printf '\n  STOPPED: %s\n\n' "$*" >&2; exit 1; }

[ -f "$PROTOTYPE" ] || die "cannot find $PROTOTYPE"

# ── The mirror, cloned on first use ──────────────────────────────────────
# Keeping it beside the source repo rather than in a temporary directory is
# the point: a checkout that can disappear is how the two fell out of step.
if [ ! -d "$MIRROR/.git" ]; then
  say "no local mirror yet, cloning it to $MIRROR"
  git clone --quiet "$MIRROR_URL" "$MIRROR" || die "could not clone the mirror"
fi

git -C "$MIRROR" fetch --quiet origin
git -C "$MIRROR" checkout --quiet main
git -C "$MIRROR" reset --quiet --hard origin/main

# ── Is there anything to do? ─────────────────────────────────────────────
SOURCE_DIRTY=$(git -C "$SOURCE_REPO" status --porcelain -- prototypes/engenxt-signup.html)
if cmp -s "$PROTOTYPE" "$MIRROR/index.html" && [ -z "$SOURCE_DIRTY" ]; then
  say "already published. The prototype, this repo and the live site all agree."
  exit 0
fi

[ -n "$MESSAGE" ] || die "say why this changed:  ./prototypes/publish.sh \"what you did\""

# ── Commit the source ────────────────────────────────────────────────────
if [ -n "$SOURCE_DIRTY" ]; then
  git -C "$SOURCE_REPO" add prototypes/engenxt-signup.html
  git -C "$SOURCE_REPO" commit --quiet -m "$MESSAGE"
  say "committed to $(git -C "$SOURCE_REPO" rev-parse --abbrev-ref HEAD)"
fi
git -C "$SOURCE_REPO" push --quiet origin HEAD
say "pushed the source"

# ── Copy, and prove the copy is exact ────────────────────────────────────
cp "$PROTOTYPE" "$MIRROR/index.html"
cmp -s "$PROTOTYPE" "$MIRROR/index.html" || die "the copy does not match the source"
say "copied to index.html, byte for byte"

if [ -n "$(git -C "$MIRROR" status --porcelain)" ]; then
  git -C "$MIRROR" add index.html
  git -C "$MIRROR" commit --quiet -m "$MESSAGE"
  git -C "$MIRROR" push --quiet origin main
  say "published to the mirror"
fi

# ── Wait for the live site to actually serve it ──────────────────────────
# Pages builds asynchronously, so "pushed" is not "live". Checking a string
# from the file we just published is the only honest confirmation.
STAMP=$(grep -o 'Self-check' "$PROTOTYPE" | head -1 || true)
say "waiting for the live site"
for _ in $(seq 1 40); do
  if curl -fsS "$LIVE" 2>/dev/null | cmp -s - "$PROTOTYPE"; then
    say "live and identical: $LIVE"
    exit 0
  fi
  sleep 15
done

say "pushed, but the live site has not caught up yet. It usually takes a minute."
say "check: $LIVE"
