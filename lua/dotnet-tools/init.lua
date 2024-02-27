local M = {}
vim.api.nvim_command('highlight DotNetTools_GreenText guifg=Green')

local dt = require('dotnet-tools.dotnet_test')

function M.setup(opts)
    print "Setting up dotnet-tools"
end

function M.dotnet_test()
    dt.dotnet_test()
end

-- testing purpose to clear the require cache
vim.api.nvim_create_user_command("ClearDotnetToolsCache",
    function()
        package.loaded["dotnet-tools"] = nil
    end, {})

return M
