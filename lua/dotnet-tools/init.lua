local M = {}
local dt = require('dotnet-tools.dotnet_command')

--- @class DotNetToolsOptions
--- @field base_directory string Base directory for the dotnet tools
--- @field highlight_group string Default highlight group for the plugin
M.config = {
        base_directory = vim.fn.getcwd(),  -- Default to current working directory
        highlight_group = 'DotNetTools_GreenText'
}

-- Constants
local HIGHLIGHT_DEFAULTS = {
    fg = 'Green',
    -- ctermfg = 'Green'
}

-- Private utility functions
local function setup_highlights()
    local success, err = pcall(function()
        vim.api.nvim_set_hl(0, M.config.highlight_group, HIGHLIGHT_DEFAULTS)
    end)
    if not success then
        vim.notify(string.format('Failed to set up highlights: %s', err), vim.log.levels.WARN)
    end
end

local function validate_options(opts)
    if not opts or type(opts) ~= 'table' then
        return false, 'Options must be a table'
    end
    if opts.base_directory and type(opts.base_directory) ~= 'string' then
        return false, 'base_directory must be a string'
    end
    return true
end

-- Public API
--- Setup the dotnet-tools plugin with custom options
--- @param opts DotNetToolsOptions|nil Configuration options
function M.setup(opts)
    local is_valid, err = validate_options(opts)
    if not is_valid then
        vim.notify(string.format('Invalid configuration: %s', err), vim.log.levels.ERROR)
        return
    end

    if opts and opts.base_directory then
        M.config.base_directory = opts.base_directory
        vim.notify(string.format('DotNetTools: Base directory set to %s', M.config.base_directory),
            vim.log.levels.INFO)
    end

    setup_highlights()
end

--- Execute dotnet test command
function M.dotnet_test()
    dt.dotnet_test(M.config)
end

--- Execute dotnet build command
function M.dotnet_build()
    dt.dotnet_build(M.config)
end

--- Execute dotnet outdated command
--- @param upgrade boolean Whether to upgrade outdated packages
function M.dotnet_outdated(upgrade)
    dt.dotnet_tool_outdated(M.config, upgrade == true)  -- Ensure boolean type
end

-- Command registration
local function register_commands()
    local commands = {
        {
            name = 'ClearDotnetToolsCache',
            fn = function()
                package.loaded['dotnet-tools'] = nil
                vim.notify('DotNetTools cache cleared', vim.log.levels.INFO)
            end,
            opts = {}
        },
        {name = 'DotNetToolsTest', fn = M.dotnet_test, opts = {}},
        {name = 'DotNetToolsBuild', fn = M.dotnet_build, opts = {}},
        {name = 'DotNetToolsOutdated', fn = function() M.dotnet_outdated(false) end, opts = {}},
        {name = 'DotNetToolsOutdatedUpgrade', fn = function() M.dotnet_outdated(true) end, opts = {}}
    }

    for _, cmd in ipairs(commands) do
        vim.api.nvim_create_user_command(cmd.name, cmd.fn, cmd.opts)
    end
end

-- Initialize module
do
    setup_highlights()
    register_commands()
end

return M
-- local dt = require('dotnet-tools.dotnet_command')
--
-- local M = {}
--
-- -- Set the highlight for the green text
-- vim.api.nvim_command('highlight DotNetTools_GreenText guifg=Green')
--
--
-- --- @class DotNetToolsOptions
-- --- @field base_directory string: Base directory for the dotnet tools
-- M.opts = {
--     base_directory = './'
-- }
--
-- --- @param opts DotNetToolsOptions : Set the options
-- function M.setup(opts)
--     if opts.base_directory then
--         print("Setting base directory to " .. opts.base_directory)
--         M.opts.base_directory = opts.base_directory
--     end
-- end
--
-- --- Execute the dotnet test command
-- function M.dotnet_test()
--     dt.dotnet_test(M.opts)
-- end
--
-- --- Execute the dotnet build command
-- function M.dotnet_build()
--     dt.dotnet_build(M.opts)
-- end
--
-- --- Execute the dotnet outdated command
-- function M.dotnet_outdated(upgrade)
--     dt.dotnet_tool_outdated(M.opts, upgrade)
-- end
--
-- -- testing purpose to clear the require cache
-- vim.api.nvim_create_user_command("ClearDotnetToolsCache",
--     function()
--         package.loaded["dotnet-tools"] = nil
--     end, {})
--
-- vim.api.nvim_create_user_command("DotNetToolsTest",
--     function()
--         M.dotnet_test()
--     end, {})
--
-- vim.api.nvim_create_user_command("DotNetToolsBuild",
--     function()
--         M.dotnet_build()
--     end, {})
--
-- vim.api.nvim_create_user_command("DotNetToolsOutdated",
--     function()
--         M.dotnet_outdated(false)
--     end, {})
--
-- vim.api.nvim_create_user_command("DotNetToolsOutdatedUpgrade",
--     function()
--         M.dotnet_outdated(true)
--     end, {})
--
-- return M
