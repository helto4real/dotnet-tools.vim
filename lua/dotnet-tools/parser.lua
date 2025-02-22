local print_result = require('dotnet-tools.print_result')
local show_ts_results = require('dotnet-tools.snacks').show_results
local utils = require('dotnet-tools.utils')

local M = {
    config = {
        temp_dir_prefix = '/tmp/dotnet-tools_'
    }
}

-- Test Results Parser
local TestParser = {}

function TestParser.parse_trx_file(trx_file_path)
    local test_results = vim.fn.readfile(trx_file_path)
    if vim.tbl_isempty(test_results) then
        print_result.print_error_result("No test results found in " .. trx_file_path)
        return {}
    end

    local results = {}
    local in_failed_test = false
    local failed_block = ""

    for i, line in ipairs(test_results) do
        if in_failed_test then
            failed_block = failed_block .. line .. "\n"
            if line:match("</UnitTestResult>") then
                in_failed_test = false
                local message = failed_block:match("<Message>(.*)</Message>")
                local file_path, line_nr = failed_block:match("<StackTrace>.* in (.*):line (%d+)")

                if message and file_path and line_nr then
                    table.insert(results, {
                        idx = i,
                        file = file_path,
                        pos = {tonumber(line_nr), 1},
                        line = message:gsub("\n", " ")
                    })
                else
                    print_result.print_error_result("Failed to parse test result in " .. trx_file_path)
                end
            end
        elseif line:match('<UnitTestResult') then
            local outcome = line:match('outcome="([a-zA-Z]+)"')
            if outcome == "Failed" then
                in_failed_test = true
                failed_block = line
            end
        end
    end
    return results
end

-- Build Results Parser
local BuildParser = {}

function BuildParser.parse_build_results(build_results)
    local results = {}
    local in_failure_section = false

    for i, line in ipairs(build_results) do
        if in_failure_section then
            if line:match("Error.s.$") then
                in_failure_section = false
            else
                local file_path, line_nr, col, err_msg = line:match("(.*)%((%d+),(%d+)%): (.*)%[")
                if file_path and line_nr and col and err_msg then
                    table.insert(results, {
                        idx = i,
                        file = file_path,
                        pos = {tonumber(line_nr), tonumber(col) - 1},
                        line = err_msg
                    })
                end
            end
        elseif line:match("Build FAILED") then
            in_failure_section = true
        end
    end
    return results
end

M.test_results_path = utils.generate_temp_dir_name(M.config.temp_dir_prefix)

--- Parse test results from trx files
function M.parse_test_results()
    local success, trx_files = pcall(utils.find_trx_files, M.test_results_path)
    if not success or not trx_files then
        print_result.print_error_result("Failed to find test results!")
        return
    end

    local all_results = {}
    for _, file in ipairs(trx_files) do
        local file_results = TestParser.parse_trx_file(file)
        vim.list_extend(all_results, file_results)
    end

    if utils.is_temp_directory(M.test_results_path) then
        utils.remove_temp_directory(M.test_results_path)
    end

    show_ts_results('Dotnet test results', all_results)
end

function M.parse_build_results(build_results)
    if not build_results then
        print_result.print_error_result("No build results provided!")
        return
    end

    local results = BuildParser.parse_build_results(build_results)
    show_ts_results('Dotnet build results', results)
end

return M
