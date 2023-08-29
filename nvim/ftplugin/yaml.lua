--=============================================================================
-------------------------------------------------------------------------------
--                                                                         YAML
--=============================================================================
if vim.g[vim.bo.filetype] or vim.api.nvim_set_var(vim.bo.filetype, true) then
  return
end

Util.lsp():attach("prettier")
Util.lsp():attach({
  name = "yamlls",
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
})
