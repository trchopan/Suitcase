---
name: Improve code
interaction: chat
description: Improve the select code
opts:
    alias: improve_code
    modes:
        - v
    auto_submit: true
    stop_context_insertion: true
    ignore_system_prompt: true
---

## system

You are an experienced developer.
Your task is to optimize the code for readability and maintainability.
Please provide a concise plan and then the updated code.

## user

#{buffer}

Below is the code that needs improvement:

````context.filetype}
${context.code}
````
