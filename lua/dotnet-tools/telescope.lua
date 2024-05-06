
local M = {}
local ts_finders = require("telescope.finders")
local ts_pickers = require("telescope.pickers")
local ts_make_entry = require "telescope.make_entry"
local ts_conf = require("telescope.config").values

function M.show_results(title, test_results_table)
    local opts = {}
    opts.bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
    opts.winnr = opts.winnr or vim.api.nvim_get_current_win()
    ts_pickers
      .new({}, {
        prompt_title = title,
        finder = ts_finders.new_table {
          results = test_results_table,
          entry_maker = ts_make_entry.gen_from_quickfix(opts),
        },
        previewer = ts_conf.qflist_previewer(opts),
        sorter = ts_conf.generic_sorter(opts),
        push_cursor_on_edit = true,
        push_tagstack_on_edit = true,
      })
      :find()
end

return M
