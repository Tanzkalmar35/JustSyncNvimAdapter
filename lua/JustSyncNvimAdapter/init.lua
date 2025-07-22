local M = {}

function M.on_save(file_path, opts)
	local url = opts.url
	if not url then
		vim.notify("JustSyncNvimAdapter: URL not configured", vim.log.levels.ERROR)
		return
	end

	local body = vim.fn.json_encode({ file_path = file_path })

	local cmd = {
		"curl",
		"-X",
		opts.method or "POST",
		"-H",
		"Content-Type: application/json",
		"-d",
		body,
		url,
	}

	vim.fn.jobstart(cmd, {
		on_exit = function(_, code)
			if code == 0 then
				vim.notify("JustSyncNvimAdapter: Request sent for " .. file_path, vim.log.levels.INFO)
			else
				vim.notify("JustSyncNvimAdapter: Request failed for " .. file_path .. " with code " .. code, vim.log.levels.ERROR)
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 1 and data[1] ~= "" then
				vim.notify("JustSyncNvimAdapter: Error sending request: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
			end
		end,
	})
end

function M.setup(opts)
	local group = vim.api.nvim_create_augroup("MyHttpOnSave", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = opts.pattern or "*",
		callback = function(args)
			M.on_save(vim.api.nvim_buf_get_name(args.buf), opts)
		end,
		desc = "HTTP call on save",
	})
end

return M
