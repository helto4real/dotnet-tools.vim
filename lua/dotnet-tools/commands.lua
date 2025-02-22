local Job = require 'plenary.job'
local print_result = require('dotnet-tools.print_result')
local parser = require('dotnet-tools.parser')

local M = {
    state = {
        job_is_running = false,
        term_win = -1,
        term_buf = -1
    }
}

-- Constants
local WINDOW_WIDTH_RATIO = 0.25

-- Helper functions
local function handle_job_completion(args, job, return_val)
    vim.schedule(function()
        local command_name = args[1]
        if return_val == 0 then
            print_result.print_success_result(string.format('dotnet %s ran successfully', command_name))
        else
            print_result.print_error_result(string.format('dotnet %s failed', command_name))
            M.handle_command_failure(command_name, job)
        end
        M.state.job_is_running = false
    end)
end

function M.handle_command_failure(command_name, job)
    if command_name == "test" then
        parser.parse_test_results()
    elseif command_name == "build" then
        local results = job:result()
        parser.parse_build_results(results)
    end
end

-- Main functions
function M.run_dotnet_command(args)
    if not args or not args[1] then
        print_result.print_error_result('No command arguments provided')
        return
    end

    M.state.job_is_running = true
    print_result.print_msg(string.format('dotnet %s is running', args[1]))

    local ok, job = pcall(Job.new, Job, {
        command = "dotnet",
        args = args,
        on_exit = function(j, return_val)
            handle_job_completion(args, j, return_val)
        end,
    })

    if ok and job then
        job:start()
    else
        print_result.print_error_result('Failed to create dotnet job')
        M.state.job_is_running = false
    end
end

function M.run_command_in_terminal(command)
    if not command then
        print_result.print_error_result('No command provided for terminal')
        return
    end

    M.cleanup_terminal()

    local success, error = pcall(function()
        local curr_win_width = vim.api.nvim_win_get_width(0)
        local new_win_width = math.floor(curr_win_width * WINDOW_WIDTH_RATIO)

        vim.cmd("rightbelow vsplit")
        vim.cmd("terminal")

        M.state.term_win = vim.api.nvim_get_current_win()
        M.state.term_buf = vim.api.nvim_get_current_buf()

        vim.api.nvim_win_set_width(M.state.term_win, new_win_width)

        local channel = vim.api.nvim_get_option_value('channel', { buf = M.state.term_buf })
        vim.fn.chansend(channel, command .. "\n")
    end)

    if not success then
        print_result.print_error_result('Failed to setup terminal: ' .. tostring(error))
        M.cleanup_terminal()
    end
end

function M.cleanup_terminal()
    if M.state.term_win ~= -1 and vim.api.nvim_win_is_valid(M.state.term_win) then
        pcall(vim.api.nvim_win_close, M.state.term_win, true)
        M.state.term_win = -1
    end

    if M.state.term_buf ~= -1 and vim.api.nvim_buf_is_valid(M.state.term_buf) then
        pcall(vim.api.nvim_buf_delete, M.state.term_buf, { force = true })
        M.state.term_buf = -1
    end
end

-- Public interface
M.is_job_running = function()
    return M.state.job_is_running
end

M.get_terminal_window = function()
    return M.state.term_win
end

M.get_terminal_buffer = function()
    return M.state.term_buf
end

return M
