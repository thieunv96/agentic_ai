#!/usr/bin/env python3
"""
Pre-tool-use hook: blocks or gates dangerous shell commands.

Reads a PreToolUse JSON payload from stdin and writes a permission decision
to stdout. Only acts on shell execution tools (Bash, run_in_terminal, etc.).
All other tools pass through transparently.

Exit codes:
  0  — allow or ask (decision encoded in stdout JSON)
  2  — hard block (also encoded in stdout JSON, but exit-2 signals blocking error)
"""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass
from typing import Optional


# ---------------------------------------------------------------------------
# Pattern definitions
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class DangerPattern:
    name: str
    pattern: re.Pattern
    decision: str   # "deny" | "ask"
    reason: str


def _p(pattern: str) -> re.Pattern:
    """Compile a case-insensitive pattern."""
    return re.compile(pattern, re.IGNORECASE)


# DENY patterns — always blocked, no confirmation possible.
# These are unambiguously catastrophic on any system.
DENY_PATTERNS: list[DangerPattern] = [
    DangerPattern(
        name="rm_root",
        pattern=_p(r'\brm\b.*-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*\s+(\/\*?|~\/?\*?|~\s*$|\$HOME\/?\*?)'),
        decision="deny",
        reason="Recursively deletes the filesystem root or home directory.",
    ),
    DangerPattern(
        name="dd_block_device",
        pattern=_p(r'\bdd\b.*\bof\s*=\s*\/dev\/(sd[a-z]|nvme\d|vd[a-z]|hd[a-z]|xvd[a-z])\b'),
        decision="deny",
        reason="Writes directly to a block device — irreversible disk destruction.",
    ),
    DangerPattern(
        name="mkfs",
        pattern=_p(r'\bmkfs(\.\w+)?\s+\/dev\/'),
        decision="deny",
        reason="Formats a disk partition — irreversible data loss.",
    ),
    DangerPattern(
        name="shred_block_device",
        pattern=_p(r'\bshred\b.*\/dev\/(sd[a-z]|nvme\d|vd[a-z]|hd[a-z])'),
        decision="deny",
        reason="Shreds a block device — permanent disk wipe.",
    ),
    DangerPattern(
        name="wipefs",
        pattern=_p(r'\bwipefs\b.*\/dev\/'),
        decision="deny",
        reason="Wipes filesystem signatures from a device — data unrecoverable.",
    ),
    DangerPattern(
        name="fork_bomb",
        pattern=_p(r':\(\)\s*\{.*:\|:.*&.*\}\s*;?\s*:'),
        decision="deny",
        reason="Fork bomb detected — will crash the system.",
    ),
    DangerPattern(
        name="overwrite_block_device",
        pattern=_p(r'>\s*\/dev\/(sd[a-z]|nvme\d|vd[a-z]|hd[a-z])'),
        decision="deny",
        reason="Direct write to block device via shell redirection.",
    ),
    DangerPattern(
        name="chmod_root",
        pattern=_p(r'\bchmod\b.*-[a-zA-Z]*R[a-zA-Z]*\s+(000|777)\s+\/\s*$'),
        decision="deny",
        reason="Recursively changes permissions on filesystem root.",
    ),
    DangerPattern(
        name="mv_root_to_null",
        pattern=_p(r'\bmv\b\s+\/\*\s+\/dev\/null'),
        decision="deny",
        reason="Moves all root files to /dev/null — destroys the entire filesystem.",
    ),
    DangerPattern(
        name="find_root_delete",
        pattern=_p(r'\bfind\s+\/\s+.*-delete\b'),
        decision="deny",
        reason="Recursively deletes all files from /.",
    ),
]


# ASK patterns — require explicit user confirmation before proceeding.
# These are potentially destructive but sometimes intentional.
ASK_PATTERNS: list[DangerPattern] = [
    DangerPattern(
        name="rm_rf_any",
        pattern=_p(r'\brm\b.*-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*'),
        decision="ask",
        reason="Recursive force delete — verify the target path is correct.",
    ),
    DangerPattern(
        name="sudo_rm",
        pattern=_p(r'\bsudo\b.*\brm\b'),
        decision="ask",
        reason="Privileged file deletion detected.",
    ),
    DangerPattern(
        name="git_push_force",
        pattern=_p(r'\bgit\b.*\bpush\b.*(\s--force\b|\s-f\b)'),
        decision="ask",
        reason="Force-push overwrites remote history — irreversible for others.",
    ),
    DangerPattern(
        name="git_reset_hard",
        pattern=_p(r'\bgit\b.*\breset\b.*--hard\b'),
        decision="ask",
        reason="Hard reset discards all uncommitted changes permanently.",
    ),
    DangerPattern(
        name="git_clean",
        pattern=_p(r'\bgit\b.*\bclean\b.*-[a-zA-Z]*f'),
        decision="ask",
        reason="git clean -f removes untracked files that cannot be recovered.",
    ),
    DangerPattern(
        name="drop_database",
        pattern=_p(r'\b(DROP\s+(TABLE|DATABASE|SCHEMA|INDEX)\b|TRUNCATE\s+TABLE\b)'),
        decision="ask",
        reason="Destructive SQL statement — will permanently delete data.",
    ),
    DangerPattern(
        name="kill_sig9",
        pattern=_p(r'\bkill\b\s+-9\b|\bkill\b\s+-SIGKILL\b|\bpkill\b\s+-9\b'),
        decision="ask",
        reason="SIGKILL forcefully terminates process(es) with no cleanup.",
    ),
    DangerPattern(
        name="chmod_777_recursive",
        pattern=_p(r'\bchmod\b.*-[a-zA-Z]*R[a-zA-Z]*\s+777\b'),
        decision="ask",
        reason="Recursively granting world-writable permissions is a security risk.",
    ),
    DangerPattern(
        name="truncate_file",
        pattern=_p(r'\btruncate\b.*-s\s+0\b'),
        decision="ask",
        reason="Truncating a file to zero bytes destroys its contents.",
    ),
    DangerPattern(
        name="history_clear",
        pattern=_p(r'\bhistory\s+-c\b'),
        decision="ask",
        reason="Clears shell history — potential evidence destruction.",
    ),
    DangerPattern(
        name="sudo_reboot_poweroff",
        pattern=_p(r'\b(sudo\s+)?(reboot|poweroff|shutdown|halt)\b'),
        decision="ask",
        reason="System power/restart command — will interrupt all running processes.",
    ),
    DangerPattern(
        name="pip_install_system",
        pattern=_p(r'\bpip3?\s+install\b(?!.*--user\b)(?!.*venv)'),
        decision="ask",
        reason="System-wide pip install may overwrite project dependencies. Prefer a virtual environment.",
    ),
]

# Tools that execute shell commands — apply guard only to these.
SHELL_TOOL_NAMES = {
    "bash",
    "run_in_terminal",
    "execute_command",
    "computer",
    "terminal",
    "shell",
    "exec",
    "run_command",
}


# ---------------------------------------------------------------------------
# Core logic
# ---------------------------------------------------------------------------

def extract_command(tool_input: dict) -> Optional[str]:
    """Extract the shell command string from a tool input dict."""
    for key in ("command", "cmd", "input", "query", "code"):
        if key in tool_input and isinstance(tool_input[key], str):
            return tool_input[key]
    return None


def check_command(command: str) -> tuple[str, str]:
    """
    Check a command string against all patterns.

    Returns (decision, reason) where decision is "allow" | "ask" | "deny".
    DENY patterns take precedence over ASK patterns.
    """
    # Check DENY patterns first — they are absolute.
    for pat in DENY_PATTERNS:
        if pat.pattern.search(command):
            return "deny", f"[{pat.name}] {pat.reason}"

    # Check ASK patterns — first match wins.
    for pat in ASK_PATTERNS:
        if pat.pattern.search(command):
            return "ask", f"[{pat.name}] {pat.reason}"

    return "allow", ""


def make_decision_output(decision: str, reason: str) -> dict:
    return {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,
            "permissionDecisionReason": reason,
        }
    }


def main() -> int:
    raw = sys.stdin.read().strip()
    if not raw:
        # No input — pass through silently.
        return 0

    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as exc:
        # Malformed input — warn but do not block.
        sys.stderr.write(f"[check_dangerous_command] Warning: could not parse stdin JSON: {exc}\n")
        return 0

    # Only inspect tool calls that execute shell commands.
    tool_name: str = str(payload.get("tool_name", payload.get("toolName", ""))).lower()
    if tool_name not in SHELL_TOOL_NAMES:
        return 0

    tool_input: dict = payload.get("tool_input", payload.get("toolInput", {}))
    if not isinstance(tool_input, dict):
        return 0

    command = extract_command(tool_input)
    if not command:
        return 0

    decision, reason = check_command(command)

    if decision == "allow":
        return 0

    # Emit the permission decision JSON.
    output = make_decision_output(decision, reason)
    sys.stdout.write(json.dumps(output, indent=2))
    sys.stdout.write("\n")

    # Exit 2 for DENY so the runtime treats it as a blocking error.
    return 2 if decision == "deny" else 0


if __name__ == "__main__":
    sys.exit(main())
