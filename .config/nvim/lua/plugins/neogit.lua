--=============================================================================
--                                          https://github.com/NeogitOrg/neogit
--=============================================================================

local util = {}
local M = {
  "NeogitOrg/neogit",
  dependencies = {
    "sindrets/diffview.nvim"
  },
  cmd = { "G", "Git", "Neogit" },
  keys = {
    { "<leader>g", function() util.open() end }
  }
}

function M.config()
  require "neogit".setup {
    disable_signs = true,
    kind = "tab",
    mappings = {
      finder = {
        ["<tab>"] = "Next",
        ["<s-tab>"] = "Previous",
      }
    },
    commit_editor = {
      kind = "tab",
      show_staged_diff = false
    },
    commit_view = {
      kind = "tab",
      verify_commit = false,
    },
    commit_popup = {
      kind = "tab",
    },
    commit_select_view = {
      kind = "tab",
    },
    log_view = {
      kind = "tab",
    },
    reflog_view = {
      kind = "tab",
    },
    popup = {
      kind = "tab",
    },
    rebase_editor = {
      kind = "tab",
    },
    merge_editor = {
      kind = "tab",
    },
    tag_editor = {
      kind = "tab",
    },
  }
end

function M.init()
  util.create_user_command()
end

function util.create_user_command()
  for _, key in pairs { "Git", "G" } do
    vim.api.nvim_create_user_command(key, function(o)
      util.open(o)
    end, {
      nargs = "*",
      desc = "Open Neogit",
      complete = function(arglead)
        return require "neogit".complete(arglead)
      end,
    })
  end
end

function util.open(o)
  vim.cmd(":keepjumps Neogit " .. (((o or {}).args) or ""))
  util.create_user_command()
end

return M
