require("zlatistiv.remap")
vim.opt.relativenumber = true
vim.opt.number = true
--vim.cmd.colorscheme("koehler")
vim.opt.hlsearch = false

vim.opt.tabstop = 8
vim.opt.shiftwidth = 8
vim.opt.softtabstop = 0


-- Remember cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
