local M = {}

local print_result = require('dotnet-tools.print_result')
local test_results_path = "/tmp/dotnet-tools-test-results.trx"
local show_ts_results = require('dotnet-tools.telescope').show_results

M.test_results_path = test_results_path

-- parses the test results and shows them in a telescope picker if there are test failures
function M.parse_test_results()
    local test_results = vim.fn.readfile(test_results_path)

    if #test_results == 0 then
        print_result.print_error_result("No test results found!")
        return
    end

    local test_results_table = {}
    local currently_parsing_failed_test = false
    local current_failed_block_text = ""

    for _, line in ipairs(test_results) do
        if currently_parsing_failed_test then
            current_failed_block_text = current_failed_block_text .. line .. "\n"
            local end_of_unit_test = string.match(line, "</UnitTestResult>")
            if end_of_unit_test then
                currently_parsing_failed_test = false
                local message = string.match(current_failed_block_text, "<Message>(.*)</Message>")
                local file_path, line_nr = string.match(current_failed_block_text, "<StackTrace>.* in (.*):line (%d+)")
                if message and file_path and line_nr then
                    table.insert(test_results_table, { filename = file_path, lnum = tonumber(line_nr), col = 1, text = message })
                else
                     print_result.print_error_result('Failed to parse test result!')
                end
            end
        else
            local ut_result = string.match(line, '<UnitTestResult.* outcome="([a-zA-Z]+)"')
            if ut_result then
                if ut_result == "Failed" then
                    currently_parsing_failed_test = true
                    current_failed_block_text = line
                end
            end
        end
    end
    show_ts_results('Dotnet test results', test_results_table)
end

function M.parse_build_results(build_results)
    local build_results_table = {}
    local currently_parsing_build_failures = false
    for _, line in ipairs(build_results) do
        if currently_parsing_build_failures then
            if string.match(line, "Error.s.$") then
               currently_parsing_build_failures = false
            else
                local file_path, line_nr, col, err_msg = string.match(line, "(.*)%((%d+),(%d+)%): (.*)%[")
                if file_path and line_nr and col and err_msg then
                    table.insert(build_results_table, { filename = file_path, lnum = tonumber(line_nr), col = tonumber(col), text = err_msg })
                end
            end
        else
            if string.match(line, "Build FAILED") then
               currently_parsing_build_failures = true
            end
        end
    end
    show_ts_results('Dotnet test results', build_results_table)
end
return M
