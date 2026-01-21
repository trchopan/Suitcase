---
name: Check naming and typo
interaction: chat
description: Check naming and typo of selected text
opts:
    alias: check_naming_and_typo
    modes:
        - v
    auto_submit: true
    stop_context_insertion: true
    ignore_system_prompt: true
---

## system

Please check the correctness of the naming in the code provided in the buffer.

Output the updated code block. Do not output the full buffer.

## user

#{buffer}

CODE BLOCK TO CHECK:

````${context.filetype}
${context.code}
````
