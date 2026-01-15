if vim.g.loaded_justsync_nvim_adapter then
  return
end
vim.g.loaded_justsync_nvim_adapter = 1

local adapter = require("JustSyncNvimAdapter")

-- Command: :JustSyncHost
vim.api.nvim_create_user_command("JustSyncHost", function()
    adapter.host()
end, { desc = "Start JustSync in Host mode" })

-- Command: :JustSyncJoin
-- Starts the interactive mode (asking for ip and token)
vim.api.nvim_create_user_command("JustSyncJoin", function()
    adapter.join_interactive()
end, { 
    desc = "Join a JustSync session (Interactive)" 
})

-- Helper for opening the lsp log, if :LspLog doesn't do the job
vim.api.nvim_create_user_command("JustSyncLog", function()
    vim.cmd("LspLog")
end, { desc = "Show JustSync logs (to find the Token)" })
