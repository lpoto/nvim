--=============================================================================
-------------------------------------------------------------------------------
--                                                                          CSS
--[[===========================================================================
Loaded when a css file is opened
-----------------------------------------------------------------------------]]
Util.ftplugin()
  :new()
  :attach_language_server("cssls")
  :attach_formatter("prettier")
