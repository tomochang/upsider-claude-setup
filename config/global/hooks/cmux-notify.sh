#!/bin/bash
# cmux notification hook for Claude Code
# Works when Claude Code is running inside cmux

# Read event JSON from stdin
INPUT=$(cat)

# Extract hook event name and data
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"' 2>/dev/null)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

case "$HOOK_EVENT" in
  Stop)
    TITLE="Claude Code"
    BODY="Response complete"
    ;;
  Notification)
    BODY=$(echo "$INPUT" | jq -r '.message // "Awaiting input"' 2>/dev/null)
    TITLE="Claude Code"
    ;;
  *)
    TITLE="Claude Code"
    BODY="$HOOK_EVENT"
    ;;
esac

# Method 1: cmux CLI (preferred)
if command -v cmux &>/dev/null; then
  cmux notify --title "$TITLE" --body "$BODY" 2>/dev/null && exit 0
fi

# Method 2: cmux CLI via app bundle (check multiple locations)
CMUX_BIN="/Applications/cmux.app/Contents/Resources/bin/cmux"
if [ ! -x "$CMUX_BIN" ]; then
  CMUX_BIN="/Volumes/cmux-macos/cmux.app/Contents/Resources/bin/cmux"
fi
if [ -x "$CMUX_BIN" ]; then
  "$CMUX_BIN" notify --title "$TITLE" --body "$BODY" 2>/dev/null && exit 0
fi

# Method 3: OSC 777 escape sequence fallback
printf '\033]777;notify;%s;%s\a' "$TITLE" "$BODY" 2>/dev/null

exit 0
