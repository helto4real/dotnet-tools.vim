local M = {}

local commands = require "dotnet-tools.commands"
local parser = require('dotnet-tools.parser')

-- Run dotnet test in a new Job and display the results in telescope
function M.dotnet_test(opts)
    if commands.job_is_running then
        print "Already running an command, please wait for it to finish"
        return
    end
    local path = vim.fn.expand(vim.fn.escape(opts.base_directory, '[]$'), true)
    commands.run_dotnet_command({ "test", path, "--logger", "trx;=LogFilePrefix=DT-", "--results-directory", parser.test_results_path })
end

-- Run dotnet build in a new Job and display the results in telescope
function M.dotnet_build(opts)
    if commands.job_is_running then
        print "Already running an command, please wait for it to finish"
        return
    end
    local path = vim.fn.expand(vim.fn.escape(opts.base_directory, '[]$'), true)
    commands.run_dotnet_command({ "build", path })
end

function M.dotnet_outdated(opts, upgrade)
    if commands.job_is_running then
        print "Already running an command, please wait for it to finish"
        return
    end
    local path = vim.fn.expand(vim.fn.escape(opts.base_directory, '[]$'), true)
    if upgrade then
        commands.run_command_in_terminal("dotnet outdated" .. " " .. path .. " --upgrade")
    else
        commands.run_command_in_terminal("dotnet outdated" .. " " .. path)
    end
end

-- run dotnet command in a new Job
return M;
