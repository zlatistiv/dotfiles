vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

--vim.keymap.set('n', 'gr', vim.lsp.buf.references)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = true })
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = true })

local tb = require('telescope.builtin')
vim.keymap.set('n', '<leader>ws', tb.lsp_dynamic_workspace_symbols)
vim.keymap.set('n', '<leader>ds', tb.lsp_document_symbols)
vim.keymap.set('n', 'gr', tb.lsp_references)  -- nicer than the quickfix version

-- Grep text inside a specific directory
vim.keymap.set('n', '<leader>fd', function()
	local dir = vim.fn.input('Dir: ', '', 'dir')
	if dir == '' then dir = '.' end
	tb.live_grep({ search_dirs = { dir } })
end)

vim.g.mapleader = " "

-- telescope
vim.keymap.set("n", "<leader>fs", ":Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fp", ":Telescope git_files<cr>")
vim.keymap.set("n", "<leader>fz", ":Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fo", ":Telescope oldfiles<cr>")

-- filetree
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<cr>")

-- Move to next/previous buffer
vim.keymap.set("n", "<S-l>", "<cmd>bn<cr>")
vim.keymap.set("n", "<S-h>", "<cmd>bp<cr>")

-- yank to clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])

-- Errors
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)

-- close the current buffer and go to the last one
-- vim.keymap.set("n", "<leader>bd", "<cmd>buffer # | bdelete #<CR>")
vim.keymap.set("n", "<leader>bd", function()
  local current = vim.api.nvim_get_current_buf()
  local alt = vim.fn.bufnr("#")

  if alt > 0 and vim.fn.buflisted(alt) == 1 then
    vim.cmd("buffer " .. alt)
  else
    vim.cmd("bnext")
  end

  if vim.api.nvim_buf_is_valid(current) then
    vim.cmd("bdelete " .. current)
  end
end, { desc = "Close buffer and switch to previous" })


_G.pre_jump_buffers = _G.pre_jump_buffers or {}

function _G.tracked_definition()
  local origin = vim.api.nvim_get_current_buf()
  local open = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      open[buf] = true
    end
  end

  vim.lsp.buf.definition()

  -- Check after the async jump lands
  local timer = vim.uv.new_timer()
  timer:start(50, 0, vim.schedule_wrap(function()
    timer:close()
    if vim.api.nvim_get_current_buf() ~= origin then
      table.insert(_G.pre_jump_buffers, open)
    end
  end))
end

vim.keymap.set("n", "<C-o>", function()
  local current_buf = vim.api.nvim_get_current_buf()

  local snapshot, snapshot_idx
  for i = #_G.pre_jump_buffers, 1, -1 do
    if not _G.pre_jump_buffers[i][current_buf] then
      snapshot = _G.pre_jump_buffers[i]
      snapshot_idx = i
      break
    end
  end

  vim.cmd("normal! \15")

  if snapshot then
    for i = #_G.pre_jump_buffers, snapshot_idx, -1 do
      table.remove(_G.pre_jump_buffers, i)
    end
    if not snapshot[current_buf] and vim.api.nvim_get_current_buf() ~= current_buf then
      vim.api.nvim_buf_delete(current_buf, { force = false })
    end
  end
end, { desc = "Jump back (close transient buffers)" })
