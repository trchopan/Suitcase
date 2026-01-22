---
name: Apply patch from AI
interaction: chat
description: Apply a patch from AI
opts:
    alias: ai_patch
    modes:
        - n
    auto_submit: false
    stop_context_insertion: true
    ignore_system_prompt: false
---

## user

#{buffer}
@{full_stack_dev}

Help me apply this patch

(paste patch here)
