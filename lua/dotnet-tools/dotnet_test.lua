local M = {}

local running = false
local Job = require 'plenary.job'
local print_result = require('dotnet-tools.print_result')

function M.dotnet_test()
    if running then
        print "Already running a test, please wait for it to finish"
        return
    end
    running = true
    local path = vim.fn.expand(vim.fn.escape("~/test/", "[]$"), true)
    print("Running dotnet test in path: " .. path)
    Job:new({
        command = "dotnet",
        args = { "test", path },
        on_exit = function(j, return_val)
            vim.schedule(function()
                if return_val == 0 then
                    print_result.print_success_result("dotnet test ran successfully")
                else
                    print_result.print_error_result("dotnet test failed")
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

return M;
