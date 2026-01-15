local M = {}

M.config = {
    cmd_path = "justsync", 
    log_level = vim.log.levels.INFO,
}

M.autocmd_registered = false

local function setup_buffer_autocommands(bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'autoread', true)
    local group = vim.api.nvim_create_augroup("JustSyncAutoread-" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "FocusGained", "BufEnter" }, {
        group = group,
        buffer = bufnr,
        callback = function() 
            vim.cmd("checktime") 
        end
    })
end

local function launch_client(args, mode_name)
    local root_dir = vim.fs.dirname(vim.fs.find({'.git', 'Cargo.toml', 'package.json'}, { upward = true })[1])
    if not root_dir then root_dir = vim.fn.getcwd() end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.synchronization.didSave = true
    capabilities.textDocument.synchronization.willSave = true
    capabilities.textDocument.synchronization.didChange = true

    local cmd = { M.config.cmd_path }
    for _, arg in ipairs(args) do table.insert(cmd, arg) end

    local client_id = vim.lsp.start({
        name = "justsync",
        cmd = cmd,
        root_dir = root_dir,
        capabilities = capabilities,
        flags = { debounce_text_changes = 150 },
        on_attach = function(client, bufnr)
            setup_buffer_autocommands(bufnr)
            vim.notify("JustSync attached! (" .. mode_name .. ")", M.config.log_level)
            if mode_name == "Host" then
                vim.notify("Check :LspLog for Token", vim.log.levels.WARN)
            end
        end,
    })

    if not M.autocmd_registered then
        local grp = vim.api.nvim_create_augroup("JustSyncAutoAttach", { clear = true })
        
        vim.api.nvim_create_autocmd("BufEnter", {
            group = grp,
            pattern = "*",
            callback = function(ev)
                local clients = vim.lsp.get_clients({ name = "justsync" })
                
                if #clients > 0 then
                    local client = clients[1]
                    vim.lsp.buf_attach_client(ev.buf, client.id)
                    
                    setup_buffer_autocommands(ev.buf)
                end
            end
        })
        M.autocmd_registered = true
    end
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
