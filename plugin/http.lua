local adapter = require("JustSyncNvimAdapter")

adapter.setup({
	url = "http://localhost:3000/endpoint",
	method = "POST",
})

vim.api.nvim_create_user_command("JustSyncStart", adapter.start, {})
vim.api.nvim_create_user_command("JustSyncStop", adapter.stop, {})
