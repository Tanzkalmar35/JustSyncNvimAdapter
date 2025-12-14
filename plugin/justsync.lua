if vim.g.loaded_justsync_nvim_adapter then
  return
end
vim.g.loaded_justsync_nvim_adapter = 1

local adapter = require("JustSyncNvimAdapter")

-- Command: :JustSyncHost
vim.api.nvim_create_user_command("JustSyncHost", function()
    adapter.host()
end, { desc = "Start JustSync in Host mode" })

-- Command: :JustSyncJoin <IP>
vim.api.nvim_create_user_command("JustSyncJoin", function(opts)
    adapter.join(opts.args)
end, { 
    nargs = 1, 
    desc = "Join a JustSync session. Usage: :JustSyncJoin 127.0.0.1" 
})
