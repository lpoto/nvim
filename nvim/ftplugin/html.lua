--=============================================================================
-------------------------------------------------------------------------------
--                                                                         HTML
--[[===========================================================================
Loaded when a html file is opened
-----------------------------------------------------------------------------]]
Util.ftplugin()
  :new()
  :attach_formatter("prettier")
  :attach_language_server("html")
