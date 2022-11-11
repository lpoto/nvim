--=============================================================================
-------------------------------------------------------------------------------
--                                                                      PLUGINS
--=============================================================================
-- All plugins are required in this module's setup function.
-- The plugins are instealled with Packer.nvim:
-- https://github.com/wbthomason/packer.nvim
-- Most of them are lazily loaded and define ways to load them
-- dynamicly when needed.
--_____________________________________________________________________________

local plugins = {}

local ensure_packer

---Manually load the packer.nvim package and use it
---to load all the required plugins.
function plugins.setup()
  --NOTE: make sure the packer.nvim is available, if not, install it
  local packer = ensure_packer()

  --NOTE: add all the required plugins with the packer

  packer.startup(function(use)
    --------------------------------------------------------------- PACKER.NVIM
    -- add packer as it's own package, so it is in opt not start directory,
    -- otherwise it tried to remove itself
    use { "wbthomason/packer.nvim", opt = true }
    -- colorscheme
    use {
      "ellisonleao/gruvbox.nvim",
      config = function()
        require("plugins.gruvbox").setup()
      end,
    }

    use {
      "lpoto/actions.nvim",
      opt = true,
      cmd = require("plugins.actions").commands,
      config = function()
        require("plugins.actions").setup()
      end,
    }
    ----------------------------------------------------------- NVIM-TREESITTER
    -- provide a simple and easy way to use the interface for
    -- tree-sitter in Neovim and provide some basic functionality
    -- such as highlighting based on it
    use {
      "nvim-treesitter/nvim-treesitter",
      config = function()
        require "plugins.treesitter"
      end,
      run = { ":TSUpdate" },
    }
    -------------------------------------------------------------- LUALINE.NVIM
    -- An easy way to configure neovim's statusline.
    use {
      "nvim-lualine/lualine.nvim",
      config = function()
        require "plugins.lualine"
      end,
    }
    ----------------------------------------------------- INDENT-BLANKLINE.NVIM
    -- Display thin vertical lines at each indentation level
    -- for code indented with spaces.
    use {
      "lukas-reineke/indent-blankline.nvim",
      config = function()
        require "plugins.indentline"
      end,
    }
    ------------------------------------------------------------------ NVIM-DAP
    -- A Debug Adapter Protocol client implementation for Neovim.
    use {
      "mfussenegger/nvim-dap",
      opt = true,
      module_pattern = { "nvim-dap", "dapui", "nvim-dap-virtual-text" },
      config = function()
        require("plugins.dap").setup()
      end,
      requires = {
        -- A UI for nvim-dap which provides a good out of the box configuration
        -- A Neovim git wrapper
        {
          "rcarriga/nvim-dap-ui",
          module = "dapui",
        },
        {
          "theHamsta/nvim-dap-virtual-text", -- requires treesitter
          module = "nvim-dap-virtual-text",
        },
      },
    }

    use {
      "TimUntersberger/neogit",
      opt = true,
      cmd = require("plugins.neogit").commands,
      config = function()
        require("plugins.neogit").setup()
      end,
      --NOTE: this requires plenary.nvim
    }
    ------------------------------------------------------------ TELESCOPE.NVIM
    -- A highly extendable fuzzy finder over lists.
    use {
      "nvim-telescope/telescope.nvim",
      opt = true,
      keys = require("plugins.telescope").keymaps,
      config = function()
        require("plugins.telescope").setup()
      end,
      --NOTE: this requires plenary.nvim
    }
    ------------------------------------------------------------ FORMATTER.NVIM
    -- A format runner for Neovim.
    use {
      "mhartington/formatter.nvim",
      opt = true,
      cmd = require("plugins.formatter").commands,
      keys = require("plugins.formatter").keymaps,
      config = function()
        require("plugins.formatter").setup()
      end,
    }
    ------------------------------------------------------------ NVIM-LSPCONFIG
    -- Configs for the Nvim LSP client
    use {
      "neovim/nvim-lspconfig",
      opt = true,
      module_pattern = "lspconfig*",
      config = function()
        require("plugins.lspconfig").setup()
      end,
      requires = {
        -------------------------------------------------------------- NVIM-CMP
        {
          "hrsh7th/nvim-cmp",
          config = function()
            require("plugins.cmp").setup()
          end,
          requires = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            {
              "hrsh7th/cmp-vsnip",
              requires = {
                "hrsh7th/vim-vsnip",
              },
            },
            {
              "windwp/nvim-autopairs",
              module_pattern = { "cmp.*", "nvim-autopairs.*" },
            },
          },
        },
      },
    }
    -------------------------------------------------------------- PLENARY.NVIM
    -- used as dependency for some plugins
    use {
      "nvim-lua/plenary.nvim",
      opt = true,
      module_pattern = { "plenary.*" },
    }
  end)
end

---Ensure that packer.nvim package exists, if it does
---not, install it.
---@return packer
ensure_packer = function()
  vim.api.nvim_exec("packadd packer.nvim", false)

  local ok, packer = pcall(require, "packer")

  if ok == false then
    local install_path = vim.fn.stdpath "data"
      .. "/site/pack/packer/start/packer.nvim"
    vim.notify("Installing packer.nvim", vim.log.levels.INFO)
    local ok, e = pcall(vim.fn.system, {
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
    })
    if ok == false then
      vim.notify(e, vim.log.levels.ERROR)
      return
    end
    vim.api.nvim_exec("packadd packer.nvim", false)
  end
  return require "packer"
end

return plugins
