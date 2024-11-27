if vim.g.vscode then
    vim.keymap.set("n", "<Space>", "", {noremap = true, silent = true})
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    require("lib/key_map")
else
    function script_path()
       local str = debug.getinfo(2, "S").source:sub(2)
       return str:match("(.*/)")
    end
    local path = tostring(script_path()) .. "init_non_vscode.vim"
    vim.cmd("source " .. path)
end
