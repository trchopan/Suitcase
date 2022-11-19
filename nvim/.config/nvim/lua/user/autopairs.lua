local status_ok, npairs = pcall(require, "nvim-autopairs")
if not status_ok then
    return
end

-- change default fast_wrap
npairs.setup({})
