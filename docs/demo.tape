# Terminal recording of new mode for the README. Render: vhs docs/demo.tape
# Render only with `pgrep -af ffmpeg` empty and a memory cap:
#   systemd-run --user --scope -p MemoryMax=4G vhs docs/demo.tape
# vhs buffers every shown frame for ffmpeg; an unhidden 3-minute capture took WSL down.
# Runs a real session (~$0.40) in a throwaway folder. Interview answers take the first option,
# which is the recommended one. Long waits are cut in the GIF by the Hide/Show pairs.
Output docs/demo.gif
Require claude
Set Shell zsh
Set FontSize 15
Set Width 1000
Set Height 600
Set TypingSpeed 40ms
Set Theme "Catppuccin Mocha"

Hide
Type "cd $(mktemp -d) && git init -q -b main && clear" Enter
Show

Type "claude --plugin-dir ~/projects/harnify" Enter
Hide
# The trust dialog defaults to "No, exit".
Wait+Screen@30s /trust this folder/
Down Enter
Wait+Screen@30s /for shortcuts/
Show
Type "/harnify:init an Arabic-first recipe site where Syrian home cooks share family recipes" Sleep 1s Enter

# Each interview round: wait for the question dialog, take the first option.
Hide
Wait+Screen@5m /Enter to select|❯ 1\./
Show
Sleep 3s
Enter Sleep 1s Enter Sleep 1s Enter Sleep 1s Enter Sleep 1s Enter
Hide
Wait+Screen@5m /Enter to select|❯ 1\.|Done|Next:/
Show
Sleep 2s
Enter Sleep 1s Enter Sleep 1s Enter Sleep 1s Enter

Hide
Wait+Screen@10m /docs\/agent\/logs|Next:/
Show
Sleep 6s
Ctrl+C Ctrl+C
Type "tree -a -I .git -L 3" Enter
Sleep 5s
