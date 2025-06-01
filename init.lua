-- =================================== Neovim Keybinds ===================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Centers the cursor when going ctrl + u or d
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Dont put deleted items into buffer when using x
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("v", "x", '"_x')

-- Remove search highlighting by pressing enter
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- Replace the currently highlighted text with the string in your default copy buffer
vim.keymap.set("x", "<leader>p", [["_dP]])

-- =================================== Neovim Settings ===================================
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = false

vim.opt.scrolloff = 10

vim.opt.updatetime = 50

vim.opt.timeoutlen = 300

vim.opt.signcolumn = "yes"

vim.o.cursorline = true

vim.opt.swapfile = false

vim.opt.clipboard = "unnamedplus"

vim.g.loaded_perl_provider = false -- disable warning in :checkhealth

vim.opt.inccommand = "split"

vim.opt.textwidth = 0

vim.cmd("autocmd BufEnter * set formatoptions-=cro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")

vim.cmd([[
augroup CursorLineNrHighlight
  autocmd!
  autocmd VimEnter * highlight CursorLineNr guibg=bg guifg=#CCCCCC
  autocmd VimEnter * highlight CursorLine ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
augroup END
]])

vim.filetype.add({
	extension = {
		module = "module",
		library = "library",
		script = "script",
	},
})

-- Run pfile on the current file. Mnemonic: Helix Edit
vim.keymap.set("n", "<leader>he", function()
	local filepath = vim.fn.expand("%")
	if filepath == "" then
		vim.notify("No file in buffer to pfile!", vim.log.levels.WARN)
		return
	end

	local cmd = { "bash", "-c", ". /tsl/devtools/profile/paliases && pfile " .. vim.fn.shellescape(filepath) }
	vim.notify(vim.fn.system(cmd))
end)

-- =================================== Plugin Settings ===================================

vim.opt.packpath:append("/tsl/devtools/nvim/nvim-plugins") -- Do not delete!

------------------ telescope ------------------

local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
	defaults = {
		file_ignore_patterns = {
			"node_modules",
			"build",
			".git/",
			"venv",
			".venv",
			"__pycache__",
			"compile_commands.json",
			".eml",
		},
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

------------------ lualine ------------------

local lualine = require("lualine")

lualine.setup({
	options = {
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_b = { "diagnostics" },
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

-- Comment these out to re-enable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.nvim_tree_respect_buf_cwd = 1

local function my_on_attach(bufnr)
	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- custom mappings
	vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent)
	vim.keymap.set("n", "?", api.tree.toggle_help)
end

local HEIGHT_RATIO = 0.8
local WIDTH_RATIO = 0.75

nvimtree.setup({
	disable_netrw = true,
	hijack_netrw = true,
	sync_root_with_cwd = true,
	update_cwd = true,
	update_focused_file = {
		enable = true,
		update_cwd = true,
	},
	view = {
		relativenumber = true,
		float = {
			enable = true,
			open_win_config = function()
				local screen_w = vim.opt.columns:get()
				local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
				local window_w = screen_w * WIDTH_RATIO
				local window_h = screen_h * HEIGHT_RATIO
				local window_w_int = math.floor(window_w)
				local window_h_int = math.floor(window_h)
				local center_x = (screen_w - window_w) / 2
				local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
				return {
					border = "rounded",
					relative = "editor",
					row = center_y,
					col = center_x,
					width = window_w_int,
					height = window_h_int,
				}
			end,
		},
		width = function()
			return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
		end,
	},

	on_attach = my_on_attach,
	git = {
		enable = false,
	},
	renderer = { icons = { show = { file = false, folder = false, folder_arrow = false } } },
	filters = {
		custom = { "*.o", "*.lo" },
	},
})

vim.keymap.set("n", "<leader>ov", api.tree.open)

------------------ nvim-cmp ------------------

local cmp = require("cmp")

cmp.setup({
	completion = { completeopt = "menu,menuone,noinsert" },

	mapping = cmp.mapping.preset.insert({
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		-- ["<C-y>"] = cmp.mapping.confirm({ select = true }),
		-- ["<C-n>"] = cmp.mapping.select_next_item(),
		-- ["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete({}),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "path" },
	},
})

------------------ nvim-lspconfig ------------------

local lspconfig = require("lspconfig")

-- local diagnostic_signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" } -- Use this if you do not have a font that symbols
local diagnostic_signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }

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
	on_attach = function(client, bufnr)
		-- client.server_capabilities.semanticTokensProvider = nil -- Disable lsp highlighting outright. Will do this once we have the cpp treesitter parser installed. The C one does not work great.
	end,
})

------------------ nvim-treesitter ------------------

local filetypes = { "c", "cpp", "library", "module", "script", "hpp" }
vim.treesitter.language.register("c", filetypes)

local ts_aug = vim.api.nvim_create_augroup("AutoTSStart", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = ts_aug,
	pattern = filetypes,
	callback = function(args)
		local parser = (args.match == "cpp") and "cpp" or "c"
		vim.treesitter.start(args.buf, "c")
	end,
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

------------------ Other Setup ------------------

require("telescope").load_extension("fzf")
