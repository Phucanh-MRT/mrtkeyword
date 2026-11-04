# MRT Keyword

This folder is the MRT Keyword skill package (Vietnamese video-editing skill for Claude Code and Codex).

- The skill itself is `mrtkeyword/SKILL.md`: when the user asks to make a video from a recorded video or a voice file
  ("dựng video", "/mrtkeyword", "$mrtkeyword"), read that file and follow it step by step.
- Installation is done by `CAI-DAT.bat` (it links the skill into `%USERPROFILE%\.claude\skills` and `%USERPROFILE%\.agents\skills`).
  If `mrtkeyword/tools/.venv` or `mrtkeyword/template/node_modules` is missing, ask the user to run `CAI-DAT.bat`.
- Reply to the user in Vietnamese.
