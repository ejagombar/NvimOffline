vim.cmd("packadd telescope.nvim")

local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
	defaults = {
		file_ignore_patterns = { "node_modules", "build", ".git/", "venv", ".venv", "__pycache__" },
	},
	pickers = {
		find_files = { hidden = true },
	},
})

vim.keymap.set("n", "<leader>oh", builtin.help_tags)
vim.keymap.set("n", "<leader>of", builtin.find_files)
vim.keymap.set("n", "<leader>ow", builtin.grep_string)
vim.keymap.set("n", "<leader>os", builtin.live_grep)
vim.keymap.set("n", "<leader>od", builtin.diagnostics)
vim.keymap.set("n", "<leader>or", builtin.resume)
vim.keymap.set("n", "<leader>ob", builtin.buffers)
vim.keymap.set("n", "<leader>og", builtin.git_files)
vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols)
vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols)

vim.keymap.set("n", "<leader>vh", function()
	builtin.help_tags()
end)

-- 			"nvim-lua/plenary.nvim",
-- 				"nvim-telescope/telescope-fzf-native.nvim",
-- 				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
-- 			{ "nvim-telescope/telescope-ui-select.nvim" },
-- 			{ "nvim-tree/nvim-web-devicons", enabled = true },
