#!/usr/bin/env bash
#
# Publish the EngenXT driver prototypes.
#
# The prototypes live in two places: this private repository, where they are
# authored and where the review history is, and a public one, which exists
# only because GitHub Pages will not serve a private repo on a free plan.
# Those two copies drift the moment either changes, and the drift is silent:
# the live site simply keeps showing yesterday's work.
#
# This does the whole job in one command so the copy cannot be forgotten:
#   ./prototypes/publish.sh "why this changed"
#
# It is safe to run when nothing has changed, and it will tell you so.
#
# There is more than one prototype now, and they link to each other, so they
# are published together. Publishing one flow and not the one it hands over to
# is how a live site ends up with a button that leads nowhere.

set -euo pipefail

SOURCE_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIRROR_URL="https://github.com/jessbmclaren/EngenXT-Mobile-Sign-up.git"
MIRROR="${ENGENXT_MIRROR:-$HOME/Code/EngenXT-Mobile-Sign-up}"
LIVE="https://jessbmclaren.github.io/EngenXT-Mobile-Sign-up"
MESSAGE="${1:-}"

# Each entry is "source file in prototypes/  ->  name it is served under".
# The sign-up flow is the landing page, so it is the one that becomes
# index.html. Everything else keeps its own name, which is what the links
# between the flows expect.
PAGES=(
  "engenxt-signup.html:index.html"
  "engenxt-onboarding.html:engenxt-onboarding.html"
)

say() { printf '  %s\n' "$*"; }
die() { printf '\n  STOPPED: %s\n\n' "$*" >&2; exit 1; }

for entry in "${PAGES[@]}"; do
  src="$SOURCE_REPO/prototypes/${entry%%:*}"
  [ -f "$src" ] || die "cannot find $src"
done

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

# ── The shared block must be identical in every prototype ────────────────
# The prototypes deliberately each carry their own copy of the tokens and the
# shared atoms. A <link> cannot be read back over file:// (cssRules throws a
# SecurityError on an external sheet), which would silently break the design
# specification panel and the self-check, and a shared file that is missing
# leaves an unstyled page rather than a loud error. Duplication is the right
# trade for something whose whole value is that double-clicking it works.
#
# What was never acceptable is drift nobody notices. So it is checked here,
# where both files are in one place, and a mismatch stops the publish.
token_block() {
  awk '/^:root \{/,/^\}/' "$1" | sed 's/[[:space:]]\+/ /g'
}
FIRST=""
for entry in "${PAGES[@]}"; do
  file="${entry%%:*}"
  sum=$(token_block "$SOURCE_REPO/prototypes/$file" | shasum | cut -d' ' -f1)
  if [ -z "$FIRST" ]; then FIRST="$sum"; FIRST_FILE="$file"
  elif [ "$sum" != "$FIRST" ]; then
    printf '\n  STOPPED: the token block in %s no longer matches %s\n' "$file" "$FIRST_FILE" >&2
    printf '  These are meant to be identical copies. Diff them and make them agree:\n' >&2
    printf "    diff <(awk '/^:root {/,/^}/' prototypes/%s) <(awk '/^:root {/,/^}/' prototypes/%s)\n\n" "$FIRST_FILE" "$file" >&2
    exit 1
  fi
done
say "token block identical across ${#PAGES[@]} prototypes"

# ── Is there anything to do? ─────────────────────────────────────────────
SOURCE_DIRTY=""
MIRROR_STALE=""
for entry in "${PAGES[@]}"; do
  file="${entry%%:*}"; dest="${entry##*:}"
  src="$SOURCE_REPO/prototypes/$file"
  dirty=$(git -C "$SOURCE_REPO" status --porcelain -- "prototypes/$file")
  [ -n "$dirty" ] && SOURCE_DIRTY="$SOURCE_DIRTY $file"
  cmp -s "$src" "$MIRROR/$dest" || MIRROR_STALE="$MIRROR_STALE $file"
done

if [ -z "$SOURCE_DIRTY" ] && [ -z "$MIRROR_STALE" ]; then
  say "already published. The prototypes, this repo and the live site all agree."
  exit 0
fi

[ -n "$MESSAGE" ] || die "say why this changed:  ./prototypes/publish.sh \"what you did\""

# ── Commit the source ────────────────────────────────────────────────────
if [ -n "$SOURCE_DIRTY" ]; then
  for file in $SOURCE_DIRTY; do
    git -C "$SOURCE_REPO" add "prototypes/$file"
  done
  git -C "$SOURCE_REPO" commit --quiet -m "$MESSAGE"
  say "committed$SOURCE_DIRTY to $(git -C "$SOURCE_REPO" rev-parse --abbrev-ref HEAD)"
fi
git -C "$SOURCE_REPO" push --quiet origin HEAD
say "pushed the source"

# ── Copy, and prove each copy is exact ───────────────────────────────────
for entry in "${PAGES[@]}"; do
  file="${entry%%:*}"; dest="${entry##*:}"
  cp "$SOURCE_REPO/prototypes/$file" "$MIRROR/$dest"
  cmp -s "$SOURCE_REPO/prototypes/$file" "$MIRROR/$dest" || die "the copy of $file does not match the source"
  say "copied $file to $dest, byte for byte"
done

if [ -n "$(git -C "$MIRROR" status --porcelain)" ]; then
  git -C "$MIRROR" add -A
  git -C "$MIRROR" commit --quiet -m "$MESSAGE"
  git -C "$MIRROR" push --quiet origin main
  say "published to the mirror"
fi

# ── Wait for the live site to actually serve it ──────────────────────────
# Pages builds asynchronously, so "pushed" is not "live". Comparing the served
# bytes against the file we just published is the only honest confirmation,
# and every page has to pass, not just the first one.
say "waiting for the live site"
for _ in $(seq 1 40); do
  all_live=1
  for entry in "${PAGES[@]}"; do
    file="${entry%%:*}"; dest="${entry##*:}"
    url="$LIVE/$dest"
    [ "$dest" = "index.html" ] && url="$LIVE/"
    curl -fsS "$url" 2>/dev/null | cmp -s - "$SOURCE_REPO/prototypes/$file" || all_live=0
  done
  if [ "$all_live" = "1" ]; then
    say "live and identical:"
    for entry in "${PAGES[@]}"; do
      dest="${entry##*:}"
      [ "$dest" = "index.html" ] && say "  $LIVE/" || say "  $LIVE/$dest"
    done
    exit 0
  fi
  sleep 15
done

say "pushed, but the live site has not caught up yet. It usually takes a minute."
say "check: $LIVE/"
