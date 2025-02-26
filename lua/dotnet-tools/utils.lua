---@brief Utility functions for the dotnet-tools plugin
---@module 'dotnet-tools.utils'
local M = {}

-- Default configuration
M.config = M.config or {
    temp_dir_prefix = "/tmp/dotnet-tools-"
}

---@brief Generate a unique temporary directory name
---@param tmp_dir_prefix string The prefix for the temporary directory (optional)
---@return string The unique temporary directory name
function M.generate_temp_dir_name(tmp_dir_prefix)
    -- Use provided prefix or default from config
    local prefix = tmp_dir_prefix or M.config.temp_dir_prefix or "/tmp/dotnet-tools-"
    -- Create unique suffix with timestamp and random number
    local timestamp = os.date("%Y%m%d%H%M%S")
    local random_number = math.random(1000, 9999)
    return prefix .. timestamp .. "_" .. random_number
end

---@brief Find all .trx test result files in the given directory
---@param directory string The directory to search in
---@return table|nil List of found .trx files or nil if error
function M.find_trx_files(directory)
    -- Validate directory parameter
    if not directory or directory == "" then
        vim.notify("Invalid directory for finding .trx files", vim.log.levels.ERROR)
        return nil
    end

    -- Escape directory path for shell command
    local escaped_dir = directory:gsub('"', '\\"')

    -- Execute find command to locate .trx files
    local handle = io.popen(string.format('find "%s" -type f -name "*.trx"', escaped_dir))
    if not handle then
        vim.notify("Failed to search for .trx files", vim.log.levels.ERROR)
        return nil
    end

    -- Collect found files
    local files = {}
    for file in handle:lines() do
        table.insert(files, file)
    end

    -- Close handle and return results
    local success = handle:close()
    if not success then
        vim.notify("Warning: find command may have encountered issues", vim.log.levels.WARN)
    end

    return files
end

---@brief Check if a path is a temporary directory
---@param path string The path to check
---@return boolean True if the path is a temporary directory
function M.is_temp_directory(path)
    if not path or type(path) ~= "string" then
        return false
    end
    -- Check if the path starts with /tmp/
    return path:match('^/tmp/') ~= nil
end

---@brief Safely remove a temporary directory
---@param directory string The directory to remove
---@return boolean Success status
function M.remove_temp_directory(directory)
    -- Validate input and safety checks
    if not directory or type(directory) ~= "string" or directory == "" then
        vim.notify("Invalid directory provided for removal", vim.log.levels.ERROR)
        return false
    end

    -- Only remove if it's actually a temp directory (safety check)
    if not M.is_temp_directory(directory) then
        vim.notify("Refusing to remove non-temporary directory: " .. directory, vim.log.levels.WARN)
        return false
    end

    -- Additional safety check using configured prefix
    local prefix = M.config.temp_dir_prefix or "/tmp/dotnet-tools-"
    if not directory:match('^' .. vim.pesc(prefix)) then
        vim.notify("Directory does not match expected temp prefix: " .. directory, vim.log.levels.WARN)
        return false
    end

    -- Escape directory path for shell command
    local escaped_dir = directory:gsub('"', '\\"')

    -- Execute removal command
    local success = os.execute('rm -rf "' .. escaped_dir .. '"')

    if success then
        vim.notify("Removed temporary directory: " .. directory, vim.log.levels.INFO)
        return true
    else
        vim.notify("Failed to remove directory: " .. directory, vim.log.levels.ERROR)
        return false
    end
end

return M
