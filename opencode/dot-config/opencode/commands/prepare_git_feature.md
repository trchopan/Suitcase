---
description: Prepare git feature branch
agent: build
model: github-copilot/claude-haiku-4.5
---

I want to prepare the git branch for the feature with title:

!`grep "^#{1,2}" "$1" | head -n 1`

!`if [ -n "$2" ]; then 
    cat "$2";
else 
    cat "GIT_WORKFLOW.md";
fi`

Based on the title and conventions, please create a new feature branch following the naming conventions.
