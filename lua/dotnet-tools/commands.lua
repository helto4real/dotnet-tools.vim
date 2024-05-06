local Job = require 'plenary.job'
local print_result = require('dotnet-tools.print_result')
local parser = require('dotnet-tools.parser')

local M = {}

M.job_is_running = false
M.term_win = -1
M.term_buf = -1

-- Run a dotnet command in a new Job
function M.run_dotnet_command(args)
    M.job_is_running = true
    print_result.print_msg('dotnet ' .. args[1] .. ' is running')

    Job:new({
        command = "dotnet",
        args = args,
        on_exit = function(j, return_val)
            vim.schedule(function()
                if return_val == 0 then
                    print_result.print_success_result('dotnet ' .. args[1] .. ' ran successfully')
                else
                    print_result.print_error_result('dotnet  ' .. args[1] .. ' failed')
                    if args[1] == "test" then
                        parser.parse_test_results()
                    elseif args[1] == "build" then
                        local res = j:result()
                        parser.parse_build_results(res)
                    end
                end
                M.job_is_running = false
            end)
        end,
    }):start()
end

-- Run a command in a terminal buffer
function M.run_command_in_terminal(command)
    -- If the window exists, close it
    if M.term_win ~= -1 and vim.api.nvim_win_is_valid(M.term_win) then
        vim.api.nvim_win_close(M.term_win, true)
        M.term_win = -1
    end

    -- If the buffer exists, delete it
    if M.term_buf ~= -1 and vim.api.nvim_buf_is_valid(M.term_buf) then
        vim.api.nvim_buf_delete(M.term_buf, { force = true })
        M.term_buf = -1
    end

    local curr_win_width = vim.api.nvim_win_get_width(0)
    local new_win_width = math.floor(curr_win_width * 0.25)

    -- Split the window vertically
    vim.cmd("rightbelow vsplit")

    -- Open a new terminal
    vim.cmd("terminal")

    M.term_win = vim.api.nvim_get_current_win()
    M.term_buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_win_set_width(M.term_win, new_win_width)

    vim.fn.chansend(vim.api.nvim_get_option_value('channel', { buf = M.term_buf }), command .. "\n")
end

return M
