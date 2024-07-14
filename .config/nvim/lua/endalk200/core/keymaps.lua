-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- use jk to exit insert mode
-- keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>") -- increment
keymap.set("n", "<leader>-", "<C-x>") -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split windows vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split windows horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close the current split window" }) -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab
keymap.set("n", "L", "<Cmd>BufferLineCycleNext<CR>", { desc = "Cycle through open buffers with bufferline" })
keymap.set("n", "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", { desc = "Delete other buffers" })
keymap.set("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "Toggle buffer pin" })
----------------------
-- Plugin Keybinds
----------------------

-- telescope
-- keymap.set("n", "<leader><leader>", builtin.find_files, {})
-- keymap.set("n", "<leader>ff", builtin.git_files, {})
-- keymap.set("n", "<leader>fb", builtin.buffers, {})
-- keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find string in cwd" })
-- keymap.set("n", "<leader>fG", builtin.grep_string, { desc = "Find string under cursor in cwd" })
--
-- keymap.set("n", "<leader>fh", builtin.help_tags, {})
-- keymap.set("n", "<leader>fr", builtin.registers, {})
-- keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, {})
-- keymap.set("n", "<leader>fo", builtin.oldfiles, {})
-- keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, {})

-- telescope git commands (not on youtube nvim video)
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
keymap.set("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]

-- restart lsp server (not on youtube nvim video)
-- keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary
