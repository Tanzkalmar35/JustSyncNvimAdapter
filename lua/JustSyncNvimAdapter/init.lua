local M = {}

-- Default configuration
M.config = {
    cmd_path = "JustSync", 
    log_level = vim.log.levels.INFO,
}

-- Internal: Launches the binary as an LSP
local function launch_client(args, mode_name)
    -- Root Directory finden (wichtig für LSP Initialisierung)
    local root_dir = vim.fs.dirname(vim.fs.find({'.git', 'Cargo.toml', 'package.json'}, { upward = true })[1])
    if not root_dir then
        root_dir = vim.fn.getcwd()
    end

    -- Build the command
    local cmd = { M.config.cmd_path }
    for _, arg in ipairs(args) do
        table.insert(cmd, arg)
    end

    -- Start as lsp
    local client_id = vim.lsp.start({
        name = "justsync",
        cmd = cmd,
        root_dir = root_dir,
        capabilities = vim.lsp.protocol.make_client_capabilities(),
        
        on_attach = function(client, bufnr)
            vim.notify("JustSync (" .. mode_name .. ") connected!", M.config.log_level)
            
            if mode_name == "Host" then
                vim.notify("Dein Token befindet sich im LSP Log.\nNutze :LspLog um ihn zu sehen/kopieren.", vim.log.levels.WARN)
            end
        end,
    })

    if not client_id then
        vim.notify("JustSync: Failed to start binary at " .. M.config.cmd_path, vim.log.levels.ERROR)
    else
        vim.notify("JustSync starting as " .. mode_name .. "...", M.config.log_level)
    end
end

-- Start host mode
function M.host()
    -- Rust Arguments: --mode host --port 4444
    launch_client({ "--mode", "host", "--port", "4444" }, "Host")
end

-- Public: Start peer (interactive)
function M.join_interactive()
    -- Ask for ip
    vim.ui.input({ prompt = 'Host IP (default 127.0.0.1): ' }, function(ip)
        if ip == "" or ip == nil then ip = "127.0.0.1" end
        
        -- Ask for token
        vim.ui.input({ prompt = 'Security Token: ' }, function(token)
            if token == nil or token == "" then
                vim.notify("Token is required!", vim.log.levels.ERROR)
                return
            end

            -- Rust Arguments: --mode peer --remote-ip <IP> --token <TOKEN>
            launch_client({ 
                "--mode", "peer", 
                "--remote-ip", ip, 
                "--token", token 
            }, "Peer")
        end)
    end)
end

-- Setup function for configuration
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
