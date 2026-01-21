---
name: Fix error
interaction: chat
description: Propose fix for current buffer
opts:
    alias: fix_error
    auto_submit: false
    stop_context_insertion: true
    ignore_system_prompt: false
---

## user

#{buffer}

I have the following error:

(please paste the error message here)

Help me fix it.
