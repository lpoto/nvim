--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-LSPCONFIG
--[[===========================================================================
https://github.com/neovim/nvim-lspconfig
https://github.com/creativenull/efmls-configs-nvim

Collection of configurations for built-in LSP client in Neovim.
Collection of configurations for formatters and linters that may
be attached as a language server with the efm language server.

Keymaps:
  - "K"         -  Show the definition of symbol under the cursor
  - "<C-k>"     -  Show the diagnostics of the line under the cursor
  - "<leader>r" -  Rename symbol under cursor

  - "<leader>f" - format the current buffer or visual selection
-----------------------------------------------------------------------------]]
local M = {
  "neovim/nvim-lspconfig",
  cmd = { "LspStart", "LspInfo", "LspLog" },
  dependencies = {
    "creativenull/efmls-configs-nvim",
  },
}

local open_diagnostic_float
local format

function M.config()
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      vim.schedule(function()
        local opts = { buffer = args.buf }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", open_diagnostic_float, opts)
        -- NOTE: the lsp definitions and references are used with telescope.nvim
        -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        -- vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
      end)
    end,
  })
end

function M.init()
  vim.keymap.set("n", "<leader>f", format)
  vim.keymap.set("v", "<leader>f", function() format(true) end)

  local border = "single"
  vim.lsp.handlers["textDocument/hover"] =
    vim.lsp.with(vim.lsp.handlers.hover, {
      border = border,
    })

  vim.lsp.handlers["textDocument/signatureHelp"] =
    vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = border,
    })
  vim.diagnostic.config({
    float = { border = border },
    virtual_text = true,
    underline = { severity = "Error" },
    severity_sort = true,
  })
end

function open_diagnostic_float()
  local n, _ = vim.diagnostic.open_float()
  if not n then Util.log("LSP"):warn("No diagnostics found") end
end

local attach_language_server
local update_efm_server

---This overrides the Util.__lsp().__attach function,
---that is internally used in the Util.lsp().attach function.
---
---It determined whether the provided language server is
---a native language server or a linger/formatter supported
---by the efm language server, then it attaches the server.
---(Either the native language server or the efm language server with
---the provided formatters and linters' configs.)
---
---@param filetype string The filetype to attach the language server to
---@param opts table The options to attach the language server with
---@return boolean? _ Whether the server was attached or not
---@diagnostic disable-next-line: duplicate-set-field
Util.__lsp().__attach = function(opts, filetype)
  local lspconfig = Util.require("lspconfig")
  if not lspconfig then return end
  local c =
    Util.require("lspconfig.server_configurations." .. opts.name, nil, true)
  local name = opts.name
  if c == nil then
    opts.name = "efm"
    opts.languages = {
      [filetype] = { name },
    }
    return update_efm_server(lspconfig, opts)
  end
  return attach_language_server(lspconfig, opts)
end

---Attach the language server from the lspconfig repo.
---@param lspconfig table The lspconfig plugin module
---@param server table The server to attach
---@return boolean? _ Whether the server was attached or not
function attach_language_server(lspconfig, server)
  local lsp = lspconfig[server.name]
  if lsp == nil then
    Util.log("LSP"):warn("Language server not found:", server.name)
    return false
  end

  server = vim.tbl_deep_extend(
    "force",
    server or {},
    vim.g[server.name .. "_config"] or {}
  )
  server.autostart = true
  lsp.setup(server)
  vim.api.nvim_exec2("LspStart", {})
  return true
end

local efm_languages = {}
local formatters = {}

---Start or update the running efm language server.
---The efm language server can attach formatters and linters
---as if they were native language servers.
---NOTE: the provided languages in the options' settings
---should be a table of tables, where the key is the
---filetype and the value is a table of formatters and linters' names.
---These names should have existing configs in the efmls-configs-nvim repo.
---@param lspconfig table The lspconfig plugin module
---@param opts table The options to start/update the efm language server with
---@return boolean? _ Whether the server was attached/updated or not
function update_efm_server(lspconfig, opts)
  if not lspconfig then return end

  if type(opts.settings) ~= "table" then opts.settings = {} end

  --NOTE: ensure the languages configs were provided
  --in the efm config.
  local languages = opts.settings.languages
  if type(languages) ~= "table" then
    languages = opts.languages
    if type(languages) ~= "table" then
      Util.log("LSP"):warn("Invalid config for efm:", opts)
      return false
    end
  end

  --NOTE: Expand the formatters and linters' names from
  --the configs in the efmls-configs-nvim repo.
  for k, v in pairs(languages) do
    if type(v) ~= "table" then
      Util.log("LSP"):warn("Invalid config for efm:", opts)
      return false
    end
    for k2, v2 in pairs(v) do
      if type(v2) ~= "string" then
        Util.log("LSP"):warn("Invalid config for efm:", opts)
        return false
      end
      local m = Util.require("efmls-configs.formatters." .. v2, nil, true)
      if not m then
        m = Util.require("efmls-configs.linters." .. v2, nil, true)
      else
        if formatters[k] ~= nil then
          Util.log("LSP"):warn("Formatter already exists for", k)
          return
        end
        formatters[k] = v2
      end
      if not m then
        Util.log("LSP")
          :warn("No matching formatters and linters found for:", v2)
        return false
      end
      m.name = v2
      v[k2] = m
    end
  end

  --NOTE: store the configs, so they can be reused when updating the server.
  for k, l in pairs(languages) do
    for _, v in pairs(l) do
      efm_languages[k] = efm_languages[k] or {}
      table.insert(efm_languages[k], v)
    end
  end

  opts.settings.languages = languages
  for k, v in pairs(efm_languages) do
    if opts.settings.languages[k] == nil then
      opts.settings.languages[k] = {}
    end
    for _, v2 in pairs(v) do
      table.insert(opts.settings.languages[k], v2)
    end
  end

  if type(opts.root_patterns) == "table" then
    if type(opts.settings.rootMarkers) ~= "table" then
      opts.settings.rootMarkers = opts.root_patterns
    end
  elseif type(opts.settings.rootMarkers) ~= "table" then
    opts.settings.rootMarkers = { ".git/" }
  end
  opts.filetypes = vim.tbl_keys(opts.settings.languages)
  opts.init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
    documentSymbol = true,
    codeAction = true,
    hover = true,
    completion = true,
  }
  opts.capabilities = nil
  opts.autostart = true
  opts.single_file_support = true
  opts.name = "efm"
  opts.autostart = true
  opts.root_patterns = nil
  opts.root_dir = nil

  lspconfig.efm.setup(opts)
  vim.api.nvim_exec2("LspStart efm", {})
  return true
end

---Format the current buffer. If visual is true, then
---format the selected text.
---@param visual boolean
function format(visual)
  local filter = function(client)
    if client.name ~= "efm" then
      return false or type(client.config) ~= "table"
    end
    local c = client.config
    if
      type(c.languages) ~= "table"
      or type(c.languages[vim.bo.filetype]) ~= "table"
    then
      return false
    end
    local available = formatters[vim.bo.filetype]
    if type(available) ~= "string" then return end
    for _, v in pairs(c.languages[vim.bo.filetype]) do
      if v.name == available then
        Util.log("LSP"):debug("Formatting with:", available)
        return true
      end
    end
    return false
  end

  local range = nil
  if visual then
    local start_row, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
    local end_row, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))
    range = {
      ["start"] = { start_row, 0 },
      ["end"] = { end_row, 0 },
    }
  end
  vim.lsp.buf.format({
    async = false,
    range = range,
    filter = filter,
  })
end

return M
