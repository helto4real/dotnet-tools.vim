local M = {}
-- Utility Functions

function M.generate_temp_dir_name()
    local timestamp = os.date("%Y%m%d%H%M%S")
    local random_number = math.random(1000, 9999)
    return M.config.temp_dir_prefix .. timestamp .. "_" .. random_number
end

function M.find_trx_files(directory)
    local handle = io.popen(string.format('find "%s" -type f -name "*.trx"', directory))
    if not handle then return nil end

    local files = {}
    for file in handle:lines() do
        table.insert(files, file)
    end
    handle:close()
    return files
end

function M.remove_temp_directory(directory)
    if directory:match('^' .. M.config.temp_dir_prefix) then
        os.execute("rm -r " .. directory)
        print("Removed temporary directory: " .. directory)
    end
end

function M.is_temp_directory(path)
    return path:match('^/tmp/') ~= nil
end

return M
