---@brief Dotnet command module for running dotnet commands
---@module 'dotnet-tools.dotnet_command'
local M = {}

local commands = require "dotnet-tools.commands"
local parser = require('dotnet-tools.parser')

---@brief Check if another command is currently running
---@return boolean
local function is_command_running()
    if commands.state.job_is_running then
        print "Already running a command, please wait for it to finish"
        return true
    end
    return false
end

---@brief Get the expanded and escaped path from options
---@param opts table Options table containing base_directory
---@return string Expanded path
local function get_expanded_path(opts)
    if not opts or not opts.base_directory then
        return "." -- Default to current directory if not specified
    end
    return vim.fn.expand(vim.fn.escape(opts.base_directory, '[]$'), true)
end

---@brief Run dotnet test in a new Job and display the results in telescope
---@param opts table Options containing base_directory
function M.dotnet_test(opts)
    if is_command_running() then return end

    local path = get_expanded_path(opts)

    -- Run test with trx logger for structured output parsing
    commands.run_dotnet_command({
        "test",
        path,
        "--logger",
        "trx;=LogFilePrefix=DT-",
        "--results-directory",
        parser.test_results_path
    })
end

---@brief Run dotnet build in a new Job and display the results in telescope
---@param opts table Options containing base_directory
function M.dotnet_build(opts)
    if is_command_running() then return end

    local path = get_expanded_path(opts)
    commands.run_dotnet_command({ "build", path })
end

---@brief Run dotnet outdated tool to check for outdated packages
---@param opts table Options containing base_directory
---@param upgrade boolean Whether to upgrade outdated packages
function M.dotnet_tool_outdated(opts, upgrade)
    if is_command_running() then return end

    local path = get_expanded_path(opts)
    local command = "dotnet outdated " .. path

    -- Add upgrade flag if requested
    if upgrade then
        command = command .. " --upgrade"
    end

    commands.run_command_in_terminal(command)
end

return M
