local M = {}

local running = false
local Job = require 'plenary.job'
local print_result = require('dotnet-tools.print_result')

local function run_dotnet_command(args)
    running = true
    print("Running dotnet " .. args[1] .. " command")
    Job:new({
        command = "dotnet",
        args = args,
        on_exit = function(j, return_val)
            vim.schedule(function()
                if return_val == 0 then
                    print_result.print_success_result('dotnet ' .. args[1] .. ' ran successfully')
                else
                    print_result.print_error_result('dotnet  ' .. args[1] .. ' failed')
                end
                running = false
            end)
        end,
        on_stdout = function(j, data)
            -- print("stdout: ", data)
        end,
        on_stderr = function(j, data)
            -- print("stderr: ", data)
        end
    }):start()
end
local terminal_buf_name = "dotnet-tools-terminal"
local terminal_win_name = "dotnet-tools-terminal-win"
-- The current terminal buffer
local term_buf = -1
-- The current terminal window
local function set_window_name(name)
    vim.api.nvim_win_set_var(0, "window-name", name) 
end

local function get_window_with_name(name)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local success, windowName = pcall(vim.api.nvim_win_get_var, win, 'window-name')
        if success and windowName == name then
            return win
        end
    end
    return -1
end

-- local function get_buffer_with_name(name)
--     for _, buf in ipairs(vim.api.nvim_list_bufs()) do
--         local bufferName = vim.api.nvim_buf_get_var(buf, name)
--         if bufferName == name then
--             return buf
--         end
--     end
--     return -1
-- end

local function run_command_in_terminal(command)
    local term_win = get_window_with_name(terminal_win_name)

    if term_win ~= -1 then
        if vim.api.nvim_win_is_valid(term_win) then
            -- Focus the existing window
            vim.api.nvim_set_current_win(term_win)
            if vim.api.nvim_get_current_buf() ~= term_buf then
                if vim.api.nvim_buf_is_valid(term_buf) then
                    vim.api.nvim_set_current_buf(term_buf)
                else
                    -- The buffer is not valid, so we need to create a new one
                    -- Close the old buffer
                    vim.api.nvim_buf_delete(term_buf, { force = true })
                    -- create a new terminal buffer
                    vim.cmd("terminal")
                    term_buf = vim.api.nvim_get_current_buf()
                end
            end
            vim.fn.chansend(vim.api.nvim_buf_get_option(term_buf, 'channel'), command .. "\n")
            return
        else
            -- The window is not valid, so we need to create a new one
            -- Close the old window and clean things up
            vim.api.nvim_win_close(term_win, true)
            vim.api.nvim_buf_delete(term_buf, { force = true })
            term_buf = -1
            term_buf = -1
        end
    end

    local curr_win_width = vim.api.nvim_win_get_width(0)
    local new_win_width = math.floor(curr_win_width * 0.25)
    -- Split the window vertically
    vim.cmd("rightbelow vsplit")
    -- Open a new terminal
    vim.cmd("terminal")
    vim.api.nvim_win_set_width(0, new_win_width)
    -- Run the command
    -- Name the terminal buffer for future reference
    term_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(term_buf, terminal_buf_name)
    -- Set the window name for future reference
    set_window_name(terminal_win_name)
    -- trick to get the full name to compare correctly
    terminal_buf_name = vim.api.nvim_buf_get_name(term_buf)
    --vim.fn.chansend(job, "ls\n")
    vim.fn.chansend(vim.api.nvim_buf_get_option(term_buf, 'channel'), command .. "\n")
end


function M.dotnet_test(opts)
    if running then
        print "Already running a test, please wait for it to finish"
        return
    end
    local path = vim.fn.expand(vim.fn.escape(opts.base_directory, '[]$'), true)
    run_dotnet_command({ "test", path })
end

function M.dotnet_build(opts)
    if running then
        print "Already running a test, please wait for it to finish"
        return
    end
    local path = vim.fn.expand(vim.fn.escape(opts.base_directory, '[]$'), true)
    run_dotnet_command({ "build", path })
end

function M.dotnet_outdated(opts, upgrade)
    if running then
        print "Already running a process, please wait for it to finish"
        return
    end
    local path = vim.fn.expand(vim.fn.escape(opts.base_directory, '[]$'), true)
    if upgrade then
        run_command_in_terminal("dotnet outdated" .. " " .. path .. " --upgrade")
    else
        run_command_in_terminal("dotnet outdated" .. " " .. path)
    end
end

-- run dotnet command in a new Job
return M;
