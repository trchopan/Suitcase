local ok, chatgpt = pcall(require, "chatgpt")
if not ok then
    return
end

chatgpt.setup({
    api_key_cmd = "secret-openai"
})

local wk = require('which-key')
wk.register({
    p = {
        name = "ChatGPT with Instructions",
        e = {
            function()
                chatgpt.edit_with_instructions()
            end,
            "Edit with instructions",
        },
    },
}, {
    prefix = "<leader>",
    mode = "v",
})


wk.register({
    p = {
        name = "ChatGPT",
        p = {
            function()
                chatgpt.openChat()
            end,
            "Open chat window",
        },
        c = {
            function()
                chatgpt.complete_code()
            end,
            "Complete code",
        },
    },
}, {
    prefix = "<leader>",
    mode = "n",
})
