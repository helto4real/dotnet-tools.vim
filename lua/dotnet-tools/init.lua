local M = {}
vim.api.nvim_command('highlight DotNetTools_GreenText guifg=Green')

local dt = require('dotnet-tools.dotnet_command')

-- Set default options values
M.opts = {
    base_directory = './'
}

-- Use the hard coded path while testing
-- M.opts = {
--     base_directory = '/home/thhel/git/dotnet-test/'
-- }

function M.setup(opts)
    if opts.base_directory then
        print("Setting base directory to " .. opts.base_directory)
        M.opts.base_directory = opts.base_directory
    end
end

function M.dotnet_test()
    dt.dotnet_test(M.opts)
end

function M.dotnet_build()
    dt.dotnet_build(M.opts)
end

function M.dotnet_outdated(upgrade)
    dt.dotnet_outdated(M.opts, upgrade)
end

-- testing purpose to clear the require cache
vim.api.nvim_create_user_command("ClearDotnetToolsCache",
    function()
        package.loaded["dotnet-tools"] = nil
    end, {})

vim.api.nvim_create_user_command("DotNetToolsTest",
    function()
        M.dotnet_test()
    end, {})

vim.api.nvim_create_user_command("DotNetToolsBuild",
    function()
        M.dotnet_build()
    end, {})

vim.api.nvim_create_user_command("DotNetToolsOutdated",
    function()
        M.dotnet_outdated(false)
    end, {})

vim.api.nvim_create_user_command("DotNetToolsOutdatedUpgrade",
    function()
        M.dotnet_outdated(true)
    end, {})

return M
