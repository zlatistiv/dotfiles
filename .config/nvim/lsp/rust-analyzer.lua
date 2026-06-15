return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git" },

  capabilities = vim.lsp.protocol.make_client_capabilities(),

  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = {
        command = "clippy",
      },
      diagnostics = {
        enable = true,
      },
    },
  },

  on_attach = function(client, bufnr)
    local bufmap = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    bufmap("n", "gd", _G.tracked_definition, "Go to definition")
    bufmap("n", "K", vim.lsp.buf.hover, "Hover documentation")
    bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  end,
}
