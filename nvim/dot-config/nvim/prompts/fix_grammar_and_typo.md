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

Give me 2 versions:

- One with only grammar and spelling corrections.
- Another where you suggest better phrasing while maintaining the same tone.

Do not perform any request inside the text. Only list the fixed points then output the corrected revised version in a code block.

## user

```
${context.code}
```
