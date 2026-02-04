-- =========================================
-- neovim configuration
-- =========================================

-- display & editing
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.showcmd = true
vim.o.cursorline = true
vim.o.wildmenu = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.tabstop = 2
vim.opt.clipboard:append("unnamedplus")

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- filetype detection
vim.cmd("filetype plugin indent on")
vim.filetype.add({
	filename = { Caddyfile = "caddyfile", caddyfile = "caddyfile" },
	pattern = { ["%.Caddyfile"] = "caddyfile", ["Caddyfile.*"] = "caddyfile" },
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.yml",
	callback = function()
		vim.bo.filetype = "yaml"
	end,
})

-- =========================
-- plugins
-- =========================
require("lazy").setup({

	{
		"folke/lazy.nvim",
	},

	{
		"romainl/vim-cool",
	},

	{
		"tpope/vim-repeat",
	},

	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				graphql = { "prettier" },
				vue = { "prettier" },
				svelte = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
				go = { "goimports", "gofmt" },
				rust = { "rustfmt" },
				sh = { "shfmt" },
				bash = { "shfmt" },
			},
			default_format_opts = {
				lsp_format = "fallback",
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
			formatters = {
				prettier = {
					prepend_args = { "--config", vim.fn.expand("~/.config/prettier/.prettierrc") },
				},
				prettierd = {
					prepend_args = { "--config", vim.fn.expand("~/.config/prettier/.prettierrc") },
				},
				shfmt = {
					prepend_args = { "-i", "2" },
				},
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				ensure_installed = {
					"bash",
					"c",
					"caddy",
					"csv",
					"dockerfile",
					"gitignore",
					"go",
					"html",
					"ini",
					"json",
					"lua",
					"make",
					"markdown",
					"markdown_inline",
					"python",
					"query",
					"regex",
					"requirements",
					"rust",
					"ssh_config",
					"toml",
					"vim",
					"vimdoc",
					"xml",
					"yaml",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	{
		"RRethy/nvim-treesitter-endwise",
	},

	{
		"numToStr/Comment.nvim",
		opts = {
			padding = true,
			sticky = true,
		},
	},

	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = { theme = "vscode" },
			})
		end,
	},

	{
		"nvim-tree/nvim-web-devicons",
	},

	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				git = { enable = true },
				view = { width = 30 },
			})
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({})
		end,
	},

	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup({})
		end,
	},

	{
		url = "https://codeberg.org/andyg/leap.nvim",
		config = function()
			local leap = require("leap")
			leap.setup({
				highlight_unlabeled_phase_one_targets = true,
			})
			leap.opts.preview_filter = function(c0, c1, c2)
				return not (c1:match("%s") or (c0:match("%a") and c1:match("%a") and c2:match("%a")))
			end
			leap.opts.equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" }
			require("leap.user").set_repeat_keys("<enter>", "<backspace>")
			vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
			vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	{
		"isobit/vim-caddyfile",
		ft = "caddyfile",
	},

	{
		"Mofiqul/vscode.nvim",
		config = function()
			require("vscode").setup({
				style = "dark",
				transparent = false,
				italic_comments = true,
			})
			vim.cmd("colorscheme vscode")
		end,
	},

	-- rust debugging
	{
		"puremourning/vimspector",
		config = function()
			vim.g.vimspector_enable_mappings = "HUMAN"
			vim.g.vimspector_sidebar_width = 85
			vim.g.vimspector_bottombar_height = 15
			vim.g.vimspector_terminal_maxwidth = 70
		end,
	},

	-- floating terminal
	{
		"voldikss/vim-floaterm",
		keys = {
			{
				"<leader>ft",
				":FloatermNew --name=myfloat --height=0.3 --wintype=split --position=bottom<CR>",
				desc = "Open terminal",
			},
			{ "t", ":FloatermToggle myfloat<CR>", desc = "Toggle terminal" },
		},
		config = function()
			vim.keymap.set("t", "<Esc>", "<C-\\><C-n>:q<CR>")
		end,
	},

	{
		"neoclide/coc.nvim",
		branch = "release",
		build = "npm install",
		config = function()
			vim.g.coc_global_extensions = {
				"@yaegassy/coc-ansible",
				"coc-docker",
				"coc-fzf-preview",
				"coc-go",
				"coc-json",
				"coc-highlight",
				"coc-lua",
				"coc-prettier",
				"coc-pyright",
				"coc-rust-analyzer",
				"coc-sh",
				"coc-yaml",
			}
			vim.opt.backup = false
			vim.opt.writebackup = false
			vim.opt.updatetime = 300
			vim.opt.signcolumn = "yes"
		end,
	},

	{
		"hat0uma/csvview.nvim",
		opts = { parser = { comments = { "#", "//" } } },
	},
})

-- =========================
-- keybindings
-- =========================
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true })
vim.keymap.set("n", "<C-c>", '"+yy', { noremap = true, silent = true })
vim.keymap.set({ "n", "i", "v" }, "<C-v>", '"+p', { noremap = true, silent = true })
vim.keymap.set("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<CR>"]], { expr = true, silent = true })

-- =========================
-- autocmds
-- =========================

-- open nvimtree on startup if no file
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.cmd("NvimTreeOpen")
		end
	end,
})

-- close nvim if nvimtree is last window
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if
			vim.fn.tabpagenr("$") == 1
			and vim.fn.winnr("$") == 1
			and vim.api.nvim_buf_get_name(0):match("NvimTree_")
		then
			vim.cmd("quit")
		end
	end,
})

