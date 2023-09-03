--=============================================================================
-------------------------------------------------------------------------------
--                                                                         YAML
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

Lsp:attach("prettier")
Lsp:attach({
  name = "yamlls",
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
})
