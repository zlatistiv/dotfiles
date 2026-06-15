return {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = { ".git", "compile_commands.json", "compile_flags.txt" },

  capabilities = vim.lsp.protocol.make_client_capabilities(),

  on_attach = function(client, bufnr)
    local bufmap = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    bufmap("n", "gd", _G.tracked_definition, "Go to definition")
    bufmap("n", "K", vim.lsp.buf.hover, "Hover documentation")
    bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  end,
}
