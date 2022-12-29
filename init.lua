--=============================================================================
-------------------------------------------------------------------------------
--                                                                    INIT NVIM
--=============================================================================
--NOTE: all filetype specific configs are defined in file in ftplugin/

----------------------------------------------------------------------- OPTIONS
-- Load the default options defined in lua/config/options.lua

require "config.options"

----------------------------------------------------------------------- PLUGINS
-- Load all the plugins defined in lua/plugins/ with lazy.nvim

require "config.lazy"

-------------------------------------------Lazy load mappings and local configs

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    --require("util.version").ensure()
    require "config.remappings"
    require("config.local_config").enable()
    require("config.sessions").config()
  end,
})
