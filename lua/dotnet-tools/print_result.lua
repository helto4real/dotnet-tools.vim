local M = {}

function M.print_msg(text)
    vim.api.nvim_echo({ {"Message: ", "DotNetTools_GreenText"}, { text, "Normal" } }, false, {})
end

function M.print_success_result(text)
    vim.api.nvim_echo({ {"Success: ", "DotNetTools_GreenText"}, { text, "Normal" } }, false, {})
end

function M.print_error_result(text)
    vim.api.nvim_echo({ {"Error: ", "Error"}, { text, "Normal" } }, false, {})
end

return M
