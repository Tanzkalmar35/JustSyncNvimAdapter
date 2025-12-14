local M = {}

-- Default configuration
M.config = {
    -- Default to assuming 'JustSync' is in your PATH. 
    -- Users can change this in setup() to point to target/debug/justsync
    cmd_path = "JustSync", 
    log_level = vim.log.levels.INFO,
}

-- Internal: Launches the binary as an LSP
local function launch_client(args)
    -- 1. Find the project root (The binary needs this for the handshake)
    -- We look for git, Cargo.toml, or package.json. Fallback to current dir.
    local root_dir = vim.fs.dirname(vim.fs.find({'.git', 'Cargo.toml', 'package.json'}, { upward = true })[1])
    if not root_dir then
        root_dir = vim.fn.getcwd()
    end

    -- 2. Build the command: e.g. ["justsync", "--host"]
    local cmd = { M.config.cmd_path }
    for _, arg in ipairs(args) do
        table.insert(cmd, arg)
    end

    -- 3. Start the LSP Client
    local client_id = vim.lsp.start({
        name = "justsync",
        cmd = cmd,
        root_dir = root_dir,
        -- Standard capabilities (supports incremental sync)
        capabilities = vim.lsp.protocol.make_client_capabilities(),
        
        -- Optional: Hook to confirm it started
        on_attach = function(client, bufnr)
            vim.notify("JustSync Attached (" .. args[1] .. ")", M.config.log_level)
        end,
    })

    if not client_id then
        vim.notify("JustSync: Failed to start binary at " .. M.config.cmd_path, vim.log.levels.ERROR)
    end
end

-- Public: Start Hosting
function M.host()
    launch_client({ "--host" })
end

-- Public: Join a session
function M.join(ip)
    if not ip or ip == "" then
        vim.notify("JustSync: IP address required to join.", vim.log.levels.ERROR)
        return
    end
    launch_client({ "--join", ip })
end

-- Setup function for configuration
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
