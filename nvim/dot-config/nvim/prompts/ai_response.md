---
name: Response to the AI message
interaction: chat
description: Response to the AI message
opts:
    alias: ai_response
    modes:
        - n
    auto_submit: false
    stop_context_insertion: true
    ignore_system_prompt: false
---

## user

@{neovim__list_directory}
@{file_search}
@{read_file}

Below is a message from AI regarding this code base. Help me respond to it.

First review the message and read the files it mentioned. Then try to answer the AI message in concise manner. 

At the end, add the list of the files the AI requested in Markdown format. The file list should be at the end of the answer, each file starting with `@` character instead of the Markdown style `-`. There should be no space after `@`.


AI MESSAGE

````
(paste AI response here)
````
