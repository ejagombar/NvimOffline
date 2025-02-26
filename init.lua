require("config")

------------------ telescope ------------------

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

-- {
-- 	"nvim-telescope/telescope-fzf-native.nvim",
-- 	build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
-- },
-- { "nvim-telescope/telescope-ui-select.nvim" },
--
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

------------------ lualine ------------------

local lualine = require("lualine")

lualine.setup({
	options = {
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_c = {
			{
				"buffers",
			},
		},
	},
})

------------------ onedark ------------------

local onedark = require("onedark")

onedark.setup({ style = "darker" })
vim.cmd("colorscheme onedark")

------------------ nvim-tree ------------------

local nvimtree = require("nvim-tree")
local api = require("nvim-tree.api")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function my_on_attach(bufnr)
	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- custom mappings
	vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent)
	vim.keymap.set("n", "?", api.tree.toggle_help)
end

nvimtree.setup({
	on_attach = my_on_attach,
	git = {
		enable = false,
	},
})

vim.keymap.set("n", "<leader>ov", api.tree.open)

------------------ nvim-cmp ------------------

local cmp = require("cmp")

cmp.setup({
	completion = { completeopt = "menu,menuone,noinsert" },

	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<C-Space>"] = cmp.mapping.complete({}),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "path" },
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{
			name = "cmdline",
			option = {
				ignore_cmds = { "Man", "!" },
			},
		},
	}),
})

------------------ nvim-lspconfig ------------------

local lspconfig = require("lspconfig")

local diagnostic_signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
for type, icon in pairs(diagnostic_signs) do
	vim.fn.sign_define("DiagnosticSign" .. type, { text = icon, texthl = "DiagnosticSign" .. type })
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func)
			vim.keymap.set("n", keys, func, { buffer = event.buf })
		end

		map("gd", require("telescope.builtin").lsp_definitions)
		map("gr", require("telescope.builtin").lsp_references)
		map("gi", require("telescope.builtin").lsp_implementations)
		map("<leader>D", require("telescope.builtin").lsp_type_definitions)
		map("<leader>ds", require("telescope.builtin").lsp_document_symbols)
		map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols)
		map("<leader>rn", vim.lsp.buf.rename)
		map("<leader>ca", vim.lsp.buf.code_action)
		map("K", vim.lsp.buf.hover)
		map("gD", vim.lsp.buf.declaration)
	end,
})

local capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	require("cmp_nvim_lsp").default_capabilities()
)

-- Configure `clangd` for C++
lspconfig.clangd.setup({
	cmd = { "clangd" },
	init_options = {
		usePlaceholders = true,
		completeUnimported = true,
		clangdFileStatus = true,
		semanticHighlighting = true,
	},
	filetypes = { "cpp", "c", "hpp", "cc", "cxx", "hxx", "h" },
	capabilities = capabilities,
})

------------------ treesitter ------------------

local treesitter = require("nvim-treesitter.configs")

treesitter.setup({
	sync_install = false,
	auto_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = { enable = true },
})

------------------ undotree ------------------

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

------------------ harpoon ------------------

local harpoon = require("harpoon")

harpoon:setup({
	settings = {
		save_on_toggle = true,
		sync_on_ui_close = true,
	},
})

vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)
vim.keymap.set("n", "<leader>h", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<leader>j", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<leader>k", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<leader>l", function()
	harpoon:list():select(4)
end)
vim.keymap.set("n", "<C-n>", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<C-p>", function()
	harpoon:list():next()
end)

------------------ tmux ------------------

local tmux = require("tmux")

tmux.setup({
	copy_sync = {
		-- enables copy sync. by default, all registers are synchronized.
		-- to control which registers are synced, see the `sync_*` options.
		enable = false,
	},
	navigation = {
		-- cycles to opposite pane while navigating into the border
		cycle_navigation = false,

		-- enables default keybindings (C-hjkl) for normal mode
		enable_default_keybindings = true,

		-- prevents unzoom tmux when navigating beyond vim border
		persist_zoom = false,
	},
	resize = {
		-- enables default keybindings (A-hjkl) for normal mode
		enable_default_keybindings = true,

		resize_step_x = 5,
		resize_step_y = 5,
	},
})

--------- Define the path where the build directory is located
-- local build_dir = vim.fn.stdpath("data") .. "/site/pack/offline/start/telescope-fzf-native.nvim/build"
--
-- -- Function to check if the plugin is built
-- local function is_built()
-- 	-- Check if the build directory or binary exists
-- 	return vim.fn.isdirectory(build_dir) == 1
-- end
--
-- -- Function to build the plugin if it's not built yet
-- local function build_plugin()
-- 	-- Run the build command
-- 	local build_command = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
--
-- 	-- Set the current working directory to the plugin directory and run the build command
-- 	vim.fn.chdir(vim.fn.stdpath("data") .. "/pack/packer/start/telescope-fzf-native.nvim")
-- 	local result = vim.fn.system(build_command)
--
-- 	-- Check if the build was successful
-- 	if vim.v.shell_error == 0 then
-- 		print("Plugin built successfully!")
-- 	else
-- 		print("Error building plugin: " .. result)
-- 	end
-- end
--
-- -- On startup, check if the plugin is built, and if not, build it
-- if not is_built() then
-- 	print("Building telescope-fzf-native.nvim plugin...")
-- 	build_plugin()
-- else
-- 	print("telescope-fzf-native.nvim plugin is already built.")
-- end
--
-- require("telescope").load_extension("fzf")
