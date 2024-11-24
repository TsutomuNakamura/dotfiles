-- Setting options of nvim
--
-- Lua-guide/Options/vim.opt,vim.o
-- https://neovim.io/doc/user/lua-guide.html#lua-guide-options
--
vim.o.encoding = "utf-8"
vim.o.number = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.showmatch = true
vim.o.wrapscan = true
vim.o.ignorecase = true
vim.o.hidden = true
vim.g.history = 10240
vim.o.whichwrap = "h,l"
vim.o.ruler = true
vim.o.clipboard = "unnamedplus"
vim.o.list = true
vim.o.listchars = "tab:^\\ ,trail:･,nbsp:%,extends:>,precedes:<"
vim.o.autoindent = true
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.helplang = "en"
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.virtualedit = "block"
vim.o.mouse = "a"
vim.o.autoread = true
vim.o.conceallevel = 0

-- Key mappings
--
-- * Lua-guide/Mappings
--   https://neovim.io/doc/user/lua-guide.html#_mappings
-- * Map/Key mapping
--   https://neovim.io/doc/user/map.html#_1.-key-mapping
-- * Map/MAPPING AND MODES
--   https://neovim.io/doc/user/map.html#%3Amap-modes
-- * Map/map-table
--   https://neovim.io/doc/user/map.html#map-table
--
-- Mode           | Norm | Ins | Cmd | Vis | Sel | Opr | Term | Lang |
-- Command        +------+-----+-----+-----+-----+-----+------+------+
-- [nore]map      | yes  |  -  |  -  | yes | yes | yes |  -   |  -   |
-- n[nore]map     | yes  |  -  |  -  |  -  |  -  |  -  |  -   |  -   |
-- [nore]map!     |  -   | yes | yes |  -  |  -  |  -  |  -   |  -   |
-- i[nore]map     |  -   | yes |  -  |  -  |  -  |  -  |  -   |  -   |
-- c[nore]map     |  -   |  -  | yes |  -  |  -  |  -  |  -   |  -   |
-- v[nore]map     |  -   |  -  |  -  | yes | yes |  -  |  -   |  -   |
-- x[nore]map     |  -   |  -  |  -  | yes |  -  |  -  |  -   |  -   |
-- s[nore]map     |  -   |  -  |  -  |  -  | yes |  -  |  -   |  -   |
-- o[nore]map     |  -   |  -  |  -  |  -  |  -  | yes |  -   |  -   |
-- t[nore]map     |  -   |  -  |  -  |  -  |  -  |  -  | yes  |  -   |
-- l[nore]map     |  -   | yes | yes |  -  |  -  |  -  |  -   | yes  |
--
local vscode = require('vscode')
function get_vscode_function(ftype, operation)
  if ftype == "action" then
    return function()
      vscode.action(operation)
    end
  end
  error("Unknown ftype \"" .. tostring(ftype) .. "\" (with operation" .. tostring(operation) .. "). Supported ftype are \"action\".")
end

function get_vscode_action(name)
  return get_vscode_function("action", name)
end


vim.keymap.set({"n", "v"}, "<leader>w", get_vscode_action('workbench.action.files.save'),               {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "<leader>q", get_vscode_action('workbench.action.closeActiveEditor'),        {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "<leader>t", get_vscode_action('workbench.action.terminal.toggleTerminal'),  {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "<leader>b", get_vscode_action('editor.debug.action.toggleBreakpoint'),      {noremap = true, silent = true})


vim.keymap.set({"n", "v"}, "<leader>d",  get_vscode_action('editor.action.showHover'),          {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "<leader>i",  get_vscode_action('editor.action.quickFix'),           {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "<leader>sp", get_vscode_action('workbench.actions.view.problems'),  {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "<leader>cn", get_vscode_action('notifications.clearAll'),           {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "<leader>ff", get_vscode_action('workbench.action.quickOpen'),       {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "<leader>cp", get_vscode_action('workbench.action.showCommands'),    {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "<leader>pr", get_vscode_action('code-runner.run'),                  {noremap = true, silent = true})    -- Is it existed?
vim.keymap.set({"n", "v"}, "<leader>fd", get_vscode_action('editor.action.formatDocument'),     {noremap = true, silent = true})


vim.keymap.set({"n", "v"}, "s|", get_vscode_action('workbench.action.splitEditor'),      {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "s-", get_vscode_action('workbench.action.splitEditorDown'),  {noremap = true, silent = true})
-- Jump another editors splitted
vim.keymap.set({"n", "v"}, "sh", get_vscode_action('workbench.action.navigateLeft'),      {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "sl", get_vscode_action('workbench.action.navigateRight'),      {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "sk", get_vscode_action('workbench.action.navigateUp'),      {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "sj", get_vscode_action('workbench.action.navigateDown'),      {noremap = true, silent = true})


vim.keymap.set({"n", "v"}, "<leader>a",  "ggVG", {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "<leader>h", "0",     {noremap = true, silent = true})
vim.keymap.set({"n", "v"}, "<leader>l", "$",     {noremap = true, silent = true})


-- better indent handling
vim.keymap.set({"v"}, "<", "<gv", {noremap = true, silent = true})
vim.keymap.set({"v"}, ">", ">gv", {noremap = true, silent = true})

-- move text up and down
vim.keymap.set({"v"}, "J", ":m .+1<CR>==",          {noremap = true, silent = true})
vim.keymap.set({"v"}, "K", ":m .+1<CR>==",          {noremap = true, silent = true})
vim.keymap.set({"x"}, "J", ":move '>+1<CR>gv-gv",   {noremap = true, silent = true})
vim.keymap.set({"x"}, "K", ":move '<-2<CR>gv-gv",   {noremap = true, silent = true})

-- paste preserves primal yanked piece
vim.keymap.set({"v"}, "p", '"_dP', {noremap = true, silent = true})

-- removes highlighting after escaping vim search
vim.keymap.set({"n"}, "<Esc>", "<Esc>:noh<CR>",     {noremap = true, silent = true})


-- Set indent of each file types.
--
-- * Change width of tab only in specific files.
-- https://qiita.com/321shoot/items/bf25a5312cd98e3bfe4f
local file_type_properties = {
    html            = {expandtab=true,  tabstop=2, shiftwidth=2, softtabstop=2},
    markdown        = {expandtab=true,  tabstop=2, shiftwidth=2, softtabstop=2},
    javascript      = {expandtab=true,  tabstop=2, shiftwidth=2, softtabstop=2},
    typescript      = {expandtab=true,  tabstop=2, shiftwidth=2, softtabstop=2},
    typescriptreact = {expandtab=true,  tabstop=2, shiftwidth=2, softtabstop=2}
}
local user_file_type_config = vim.api.nvim_create_augroup("UserFileTypeConfig", { clear = true})
vim.api.nvim_create_autocmd("FileType", {
    -- pattern = "html",
    group = user_file_type_config,
    callback = function(args)
        local property = file_type_properties[args.match]
        if property then
            local e = property["expandtab"]
            if e then
                vim.g.expandtab = e
            end
            local ts  = property["tabstop"]
            if ts then
                vim.bo.tabstop = ts
            end
            local sw = property["shiftwidth"]
            if sw then
                vim.bo.shiftwidth = sw
            end
            local st = property["softtabstop"]
            if st then
                vim.bo.softtabstop = st
            end
        end
    end,
})


vim.opt.diffopt:prepend {
    'filler',
    'context:1000000'
}

