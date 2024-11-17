vim.keymap.set("n", "<Space>", "", {noremap = true, silent = true})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Please refer to 
-- * Lua-guide - Mappings
-- https://neovim.io/doc/user/lua-guide.html#_mappings
-- * Map - Mapping and modes
-- https://neovim.io/doc/user/map.html#%3Amap-modes
--
--
-- set("n", ...)      -> n[nore]map - No recursive mapping
-- set("v", ...)      -> v[nore]map - Visual and select mode


-- noremap <Space>h  ^
require("lib/key_map")

