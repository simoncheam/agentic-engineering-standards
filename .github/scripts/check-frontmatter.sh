#!/usr/bin/env bash
# Frontmatter and README checks for this repo (AD-7: exit 0 or 1, no tokens spent).
# Run from the repo root: bash .github/scripts/check-frontmatter.sh
set -u
fail=0
err() { echo "FAIL: $*"; fail=1; }

frontmatter() { awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1' "$1"; }

# --- Skills: AD-9 — entrypoint <=> (disable-model-invocation: true AND argument-hint); never unusable by everyone
for f in .claude/skills/*/SKILL.md; do
  fm=$(frontmatter "$f")
  d=$(printf '%s\n' "$fm" | grep -c '^disable-model-invocation: true$')
  a=$(printf '%s\n' "$fm" | grep -c '^argument-hint:')
  u=$(printf '%s\n' "$fm" | grep -c '^user-invocable: false$')
  [ "$d" = "$a" ] || err "$f: AD-9 — disable-model-invocation ($d) and argument-hint ($a) must both be present or both absent"
  [ "$d" = 1 ] && [ "$u" = 1 ] && err "$f: user-invocable: false with disable-model-invocation: true — nobody can run it"
  if printf '%s\n' "$fm" | grep -q '^context: fork$'; then
    agent=$(printf '%s\n' "$fm" | sed -n 's/^agent: *//p')
    [ -n "$agent" ] || err "$f: context: fork without agent:"
    case "$agent" in
      Explore|Plan|general-purpose) ;;
      *) [ -f ".claude/agents/$agent.md" ] || err "$f: agent '$agent' has no .claude/agents/$agent.md" ;;
    esac
  fi
done

# --- Agents: name = filename; description, tools, model present; no agent may Edit
for f in .claude/agents/*.md; do
  [ "$(basename "$f")" = README.md ] && continue
  fm=$(frontmatter "$f")
  name=$(basename "$f" .md)
  printf '%s\n' "$fm" | grep -qx "name: $name" || err "$f: name must be '$name'"
  for k in description tools model; do
    printf '%s\n' "$fm" | grep -q "^$k:" || err "$f: missing $k:"
  done
  printf '%s\n' "$fm" | grep -E '^tools:.*\bEdit\b' >/dev/null && err "$f: agents never get Edit"
  grep -q "\`$name\`" .claude/agents/README.md || err ".claude/agents/README.md does not name '$name'"
done

# --- README claims: every directory in the structure block exists; hooks are 'planned' while none exist
awk '/^## Structure/{s=1} s && /^```/{c++; next} s && c==1' README.md > /tmp/readme-structure.$$
top=""
while IFS= read -r line; do
  case "$line" in
    *"── "*) child=$(printf '%s' "$line" | sed -n 's/.*── \([^ ]*\/\).*/\1/p')
             [ -n "$child" ] && ! git check-ignore -q "$top$child" && { [ -d "$top$child" ] || err "README structure block: $top$child does not exist"; } ;;
    [a-z.]*/*) top=$(printf '%s' "$line" | sed 's/ .*//'); [ -d "$top" ] || err "README structure block: $top does not exist" ;;
  esac
done < /tmp/readme-structure.$$
rm -f /tmp/readme-structure.$$
if [ "$(find .claude/hooks -type f ! -name README.md | wc -l | tr -d ' ')" = 0 ]; then
  grep -q 'hooks/.*planned' README.md || err "README: no hooks exist, so the hooks/ line must say planned"
  grep -qi 'no hooks exist' .claude/hooks/README.md || err ".claude/hooks/README.md must say no hooks exist yet"
fi

[ "$fail" = 0 ] && echo "ok: frontmatter and README checks passed"
exit "$fail"
