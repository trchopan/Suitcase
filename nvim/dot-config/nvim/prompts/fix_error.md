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
@{full_stack_dev}

I have the following error:

````
(please paste the error message here)
````

Help me inspect and fix it. You can add in log printing and ask me to provide the output.
