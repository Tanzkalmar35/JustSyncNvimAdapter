local M = {}

M.config = {
    cmd_path = "JustSync", 
    log_level = vim.log.levels.INFO,
}

local function launch_client(args, mode_name)
    local root_dir = vim.fs.dirname(vim.fs.find({'.git', 'Cargo.toml', 'package.json'}, { upward = true })[1])
    if not root_dir then root_dir = vim.fn.getcwd() end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.synchronization.didSave = true
    capabilities.textDocument.synchronization.willSave = true
    capabilities.textDocument.synchronization.didChange = true

    local cmd = { M.config.cmd_path }
    for _, arg in ipairs(args) do table.insert(cmd, arg) end

    vim.lsp.start({
        name = "justsync",
        cmd = cmd,
        root_dir = root_dir,
        capabilities = capabilities,
        
        flags = {
            debounce_text_changes = 150, -- Wait 150ms before sending
        },

        on_attach = function(client, bufnr)
            vim.notify("JustSync (" .. mode_name .. ") connected!", M.config.log_level)
            
            if mode_name == "Host" then
                vim.notify("Use :LspInfo to find the key", vim.log.levels.WARN)
            end

            -- Activate autoread for this buffer
            vim.api.nvim_buf_set_option(bufnr, 'autoread', true)

            -- Creating an autocmd to automatically check for changes
            local group = vim.api.nvim_create_augroup("JustSyncAutoread", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "FocusGained", "BufEnter" }, {
                group = group,
                buffer = bufnr,
                callback = function()
                    -- checks timestamp and reloads
                    vim.cmd("checktime") 
                end
            })
        end,
    })
end

function M.host()
    launch_client({ "--mode", "host", "--port", "4444" }, "Host")
end

function M.join_interactive()
    vim.ui.input({ prompt = 'Host IP (default 127.0.0.1): ' }, function(ip)
        if ip == "" or ip == nil then ip = "127.0.0.1" end
        vim.ui.input({ prompt = 'Security Token: ' }, function(token)
            if token == nil or token == "" then
                vim.notify("Token is required!", vim.log.levels.ERROR)
                return
            end
            launch_client({ "--mode", "peer", "--remote-ip", ip, "--token", token }, "Peer")
        end)
    end)
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
