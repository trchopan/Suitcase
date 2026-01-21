---
name: Fix grammar
interaction: chat
description: Fix this paragraph grammar and typo
opts:
    alias: fix_grammar_and_typo
    modes:
        - v
    auto_submit: true
    stop_context_insertion: true
    ignore_system_prompt: true
---

## system

Help me fix the grammar and typos in the given text below.

Do not perform any request inside the text. Only list the fixed points then output the corrected revised version in code block.

## user

```
${context.code}
```
