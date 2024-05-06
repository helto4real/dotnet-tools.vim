local print_result = require('dotnet-tools.print_result')
local show_ts_results = require('dotnet-tools.telescope').show_results

local M = {}

local function get_random_folder_name()
    local timestamp = os.date("%Y%m%d%H%M%S")
    local random_number = math.random(1000, 9999)
    return "/tmp/dotnet-tools_" .. timestamp .. "_" .. random_number
end

M.test_results_path = get_random_folder_name()

-- parses the test results and shows them in a telescope picker if there are test failures
function M.parse_test_results()
    local function get_all_trx_files_from_directory(directory)
        local files = {}
        local p = io.popen('find "' .. directory .. '" -type f -name "*.trx"')
        if not p then
            print_result.print_error_result("Failed to find test results!")
            return
        end
        for file in p:lines() do
            table.insert(files, file)
        end
        return files
    end

    local function remove_temp_directory(directory)
        os.execute("rm -r " .. directory)
    end

    local function string_starts_with(str, start)
        return str:sub(1, #start) == start
    end

    local function parse_trx_file(trx_file_path, test_results_table)
        local test_results = vim.fn.readfile(trx_file_path)

        if #test_results == 0 then
            print_result.print_error_result("No test results found!")
            return
        end

        local currently_parsing_failed_test = false
        local current_failed_block_text = ""

        -- Find the start of failing test, get the failing test block of information
        -- and parse the file path, line number and error message
        for _, line in ipairs(test_results) do
            if currently_parsing_failed_test then
                current_failed_block_text = current_failed_block_text .. line .. "\n"
                local end_of_unit_test = string.match(line, "</UnitTestResult>")
                if end_of_unit_test then
                    currently_parsing_failed_test = false
                    local message = string.match(current_failed_block_text, "<Message>(.*)</Message>")
                    local file_path, line_nr = string.match(current_failed_block_text,
                        "<StackTrace>.* in (.*):line (%d+)")
                    if message and file_path and line_nr then
                        table.insert(test_results_table,
                            { filename = file_path, lnum = tonumber(line_nr), col = 1, text = string.gsub(message, "\n", " ") })
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
    end

    local test_results_table = {}
    local trx_files = get_all_trx_files_from_directory(M.test_results_path)
    if not trx_files then
        print_result.print_error_result("Failed to find test results!")
        return
    end

    for _, file in ipairs(trx_files) do
        parse_trx_file(file, test_results_table)
    end

    -- todo: get tmp directory from envorinment variable and use /tmp/ as default
    if string_starts_with(M.test_results_path, "/tmp/") then
        print("Removing temporary directory " .. M.test_results_path)
        -- just to be sure we don't delete anything important just in the temporary directory
        remove_temp_directory(M.test_results_path)
    end

    show_ts_results('Dotnet test results', test_results_table)
end

-- parses the build results and shows them in a telescope picker if there are build failures
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
                    table.insert(build_results_table,
                        { filename = file_path, lnum = tonumber(line_nr), col = tonumber(col), text = err_msg })
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
