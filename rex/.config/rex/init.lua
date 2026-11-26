-- Rex config, migrated from Ghostty and iTerm2 on 2026-11-26.
-- Ghostty: no key bindings to migrate (theme and window settings are not migrated).

-- iTerm2, profile "Default", Keyboard Map: single-byte hex codes (action 11).
rex.bind("ctrl+2", "pane.send_key", { key = "ctrl+space" })    -- 0x32-0x40000 -> 0x00
rex.bind("ctrl+3", "pane.send_key", { key = "esc" })           -- 0x33-0x40000 -> 0x1b
rex.bind("ctrl+4", "pane.send_key", { key = "ctrl+\\" })       -- 0x34-0x40000 -> 0x1c
rex.bind("ctrl+5", "pane.send_key", { key = "ctrl+]" })        -- 0x35-0x40000 -> 0x1d
rex.bind("ctrl+6", "pane.send_key", { key = "ctrl+shift+6" })  -- 0x36-0x40000 -> 0x1e
rex.bind("ctrl+7", "pane.send_key", { key = "ctrl+shift+-" })  -- 0x37-0x40000 -> 0x1f
rex.bind("ctrl+8", "pane.send_key", { key = "backspace" })     -- 0x38-0x40000 -> 0x7f
rex.bind("ctrl+-", "pane.send_key", { key = "ctrl+shift+-" })  -- 0x2d-0x40000 -> 0x1f
