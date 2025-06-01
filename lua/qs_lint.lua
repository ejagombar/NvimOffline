-- File: ~/.config/nvim/lua/qs-lint.lua
-- Enhanced QS Lint integration for Neovim

local M = {}

-- Configuration
M.config = {
	cmd = "qs_lint",
	filetypes = { "qs" },
	debounce_time = 500,
	use_json = true, -- Use JSON output for better parsing
	auto_save = true, -- Auto-save before linting
}

-- Parse JSON linter output
local function parse_json_output(output, bufnr)
	local ok, data = pcall(vim.json.decode, output)
	if not ok or not data.issues then
		return {}
	end

	local diagnostics = {}

	for _, issue in ipairs(data.issues) do
		local diagnostic_severity = vim.diagnostic.severity.INFO

		if issue.severity == "ERROR" then
			diagnostic_severity = vim.diagnostic.severity.ERROR
		elseif issue.severity == "WARNING" then
			diagnostic_severity = vim.diagnostic.severity.WARN
		elseif issue.severity == "INFO" then
			diagnostic_severity = vim.diagnostic.severity.INFO
		end

		local message = issue.message
		if issue.suggestion then
			message = message .. "\nSuggestion: " .. issue.suggestion
		end

		table.insert(diagnostics, {
			bufnr = bufnr,
			lnum = issue.line - 1,
			col = issue.column - 1,
			end_lnum = issue.endLine - 1,
			end_col = issue.endColumn - 1,
			severity = diagnostic_severity,
			message = message,
			source = "qs-lint",
			code = issue.rule,
			user_data = {
				rule = issue.rule,
				suggestion = issue.suggestion,
			},
		})
	end

	return diagnostics
end

-- Parse traditional text output (fallback)
local function parse_text_output(output, bufnr)
	local diagnostics = {}

	for line in output:gmatch("[^\r\n]+") do
		local severity, line_num, col_num, rule, message =
			line:match("%[(%w+)%] Line (%d+), Col (%d+) %(([^)]+)%): (.+)")

		if severity and line_num and col_num and message then
			local diagnostic_severity = vim.diagnostic.severity.INFO

			if severity == "ERROR" then
				diagnostic_severity = vim.diagnostic.severity.ERROR
			elseif severity == "WARNING" then
				diagnostic_severity = vim.diagnostic.severity.WARN
			end

			-- Extract suggestion if present
			local suggestion = message:match("%[Suggestion: (.+)%]$")
			if suggestion then
				message = message:gsub(" %[Suggestion: .+%]$", "")
				message = message .. "\nSuggestion: " .. suggestion
			end

			table.insert(diagnostics, {
				bufnr = bufnr,
				lnum = tonumber(line_num) - 1,
				col = tonumber(col_num) - 1,
				end_lnum = tonumber(line_num) - 1,
				end_col = tonumber(col_num),
				severity = diagnostic_severity,
				message = message,
				source = "qs-lint",
				code = rule,
				user_data = {
					rule = rule,
					suggestion = suggestion,
				},
			})
		end
	end

	return diagnostics
end

-- Run the linter on a buffer
local function run_linter(bufnr)
	local filepath = vim.api.nvim_buf_get_name(bufnr)

	if filepath == "" then
		return
	end

	-- Save buffer if it has unsaved changes and auto_save is enabled
	if M.config.auto_save and vim.bo[bufnr].modified then
		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd("silent write")
		end)
	end

	-- Build command with options
	local cmd = { M.config.cmd }
	if M.config.use_json then
		table.insert(cmd, "--json")
	end
	table.insert(cmd, "--quiet") -- Suppress status messages
	table.insert(cmd, filepath)

	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data and #data > 0 then
				local output = table.concat(data, "\n")
				local diagnostics

				if M.config.use_json then
					diagnostics = parse_json_output(output, bufnr)
				else
					diagnostics = parse_text_output(output, bufnr)
				end

				-- Set diagnostics for this buffer
				vim.diagnostic.set(vim.api.nvim_create_namespace("qs-lint"), bufnr, diagnostics, {
					virtual_text = {
						prefix = "●",
						source = true,
						spacing = 2,
					},
					signs = true,
					underline = true,
					update_in_insert = false,
					severity_sort = true,
				})
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 0 and data[1] ~= "" then
				local error_msg = table.concat(data, "\n")
				vim.notify("QS Lint error: " .. error_msg, vim.log.levels.ERROR)
			end
		end,
		on_exit = function(_, exit_code)
			-- Exit codes: 0 = no issues, 1 = warnings only, 2 = errors present, 3 = linter error
			if exit_code == 0 then
				-- Clear diagnostics when no issues
				vim.diagnostic.set(vim.api.nvim_create_namespace("qs-lint"), bufnr, {})
			elseif exit_code == 3 then
				vim.notify("QS Lint failed to run", vim.log.levels.ERROR)
			end
		end,
	})
end

-- Debounced linting function
local function debounced_lint(bufnr)
	-- Use vim.uv if available (newer versions), fallback to vim.loop
	local uv = vim.uv or vim.loop
	if not uv then
		-- Fallback: use vim.defer_fn if timers are not available
		vim.defer_fn(function()
			run_linter(bufnr)
		end, M.config.debounce_time)
		return
	end

	local timer = uv.new_timer()
	timer:start(
		M.config.debounce_time,
		0,
		vim.schedule_wrap(function()
			run_linter(bufnr)
			timer:close()
		end)
	)
end

-- Setup function
function M.setup(opts)
	opts = opts or {}
	M.config = vim.tbl_extend("force", M.config, opts)

	-- Create autocommands for supported filetypes
	local group = vim.api.nvim_create_augroup("QSLint", { clear = true })

	vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
		group = group,
		pattern = "*." .. table.concat(M.config.filetypes, ",*."),
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			run_linter(bufnr)
		end,
	})

	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		group = group,
		pattern = "*." .. table.concat(M.config.filetypes, ",*."),
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			debounced_lint(bufnr)
		end,
	})

	-- Command to manually run linter
	vim.api.nvim_create_user_command("QSLint", function()
		local bufnr = vim.api.nvim_get_current_buf()
		run_linter(bufnr)
	end, {})

	-- Define signs for diagnostics
	vim.fn.sign_define("DiagnosticSignError", { text = "●", texthl = "DiagnosticSignError" })
	vim.fn.sign_define("DiagnosticSignWarn", { text = "●", texthl = "DiagnosticSignWarn" })
	vim.fn.sign_define("DiagnosticSignInfo", { text = "●", texthl = "DiagnosticSignInfo" })
	vim.fn.sign_define("DiagnosticSignHint", { text = "●", texthl = "DiagnosticSignHint" })

	print("QS Lint integration loaded")
end

-- Manual linting function
function M.lint_current_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	run_linter(bufnr)
end

-- Clear diagnostics function
function M.clear_diagnostics()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.diagnostic.set(vim.api.nvim_create_namespace("qs-lint"), bufnr, {})
end

return M
