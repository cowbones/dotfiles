-- =========================================
-- Neovim configuration
-- =========================================

-- Some display config
vim.o.termguicolors = true
vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"

-- Bootstrap lazy.nvim if not installed
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

-- =========================
-- General settings
-- =========================
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

-- Clipboard
vim.opt.clipboard:append("unnamedplus")

-- Enable Vimscript plugins' filetype detection
vim.cmd("filetype plugin indent on")

-- Colorscheme
vim.cmd("syntax on")

-- =========================
-- Filetype detection
-- =========================
-- Detect Caddyfile syntax
vim.filetype.add({
  filename = {
    ['Caddyfile'] = 'caddyfile',
    ['caddyfile'] = 'caddyfile',
  },
  pattern = {
    ['%.Caddyfile'] = 'caddyfile',
    ['Caddyfile.*'] = 'caddyfile',
  },
})

-- .yml -> yaml
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.yml",
  callback = function()
    vim.bo.filetype = "yaml"
  end,
})

-- =========================
-- Plugins
-- =========================
require("lazy").setup({
  -- Plugin manager
  "folke/lazy.nvim",

  -- Optional search highlight clearing
  "romainl/vim-cool",

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash", "c", "caddy", "csv", "dockerfile", "gitignore",
          "go", "html", "ini", "json", "lua", "make", "markdown",
          "markdown_inline", "python", "query", "regex", "requirements",
          "rust", "ssh_config", "toml", "vim", "vimdoc", "xml", "yaml"
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Endwise (depends on Treesitter)
  {
    "RRethy/nvim-treesitter-endwise",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter.configs").setup({
        endwise = { enable = true },
      })
    end,
  },

  -- Auto-close brackets/quotes
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup{}
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup{
        options = { theme = "vscode" },
      }
    end,
  },

  -- NvimTree icons
  {
    "nvim-tree/nvim-web-devicons",
    opts = {}
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup{
        git = { enable = true },
        view = { width = 30 },
      }
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup{}
    end,
  },

  -- Surround text objects
  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup{}
    end,
  },

  -- Repeat plugin commands (optional)
  "tpope/vim-repeat",

  -- Leap.nvim for motions
  {
    "ggandor/leap.nvim",
    config = function()
      local leap = require('leap')

      leap.setup({
        highlight_unlabeled_phase_one_targets = true,
      })

      -- Reduce visual noise with preview filter
      -- Excludes whitespace and middle of alphabetic words
      leap.opts.preview_filter = function (ch0, ch1, ch2)
        return not (
          ch1:match('%s') or
          ch0:match('%a') and ch1:match('%a') and ch2:match('%a')
        )
      end

      -- Equivalence classes for brackets, quotes, and whitespace
      leap.opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }

      -- Use traversal keys to repeat previous motion
      require('leap.user').set_repeat_keys('<enter>', '<backspace>')

      -- Set up keybindings
      vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
      vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },

  -- Caddyfile syntax highlighting
  {
    "isobit/vim-caddyfile",
    ft = "caddyfile",
  },

  -- VSCode Dark theme
  {
    "Mofiqul/vscode.nvim",
    config = function()
      require('vscode').setup({
        style = 'dark',
        transparent = false,
        italic_comments = true,
      })
      vim.cmd("colorscheme vscode")
    end,
  },

  -- coc.nvim for LSP and autocompletion
  {
    "neoclide/coc.nvim",
    branch = "release",
    build = "npm ci",
    config = function()
      -- Auto-install coc extensions
      vim.g.coc_global_extensions = {
        '@yaegassy/coc-ansible', 
        'coc-docker',
        -- 'coc-copilot',
        'coc-fzf-preview',
        'coc-go',
        'coc-json',
        'coc-highlight',
        'coc-lua',
        'coc-prettier',
        'coc-pyright',
        'coc-rust-analyzer',
        'coc-sh',
        'coc-yaml',
      }

      -- Some servers have issues with backup files
      vim.opt.backup = false
      vim.opt.writebackup = false

      -- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
      -- delays and poor user experience
      vim.opt.updatetime = 300

      -- Always show the signcolumn, otherwise it would shift the text each time
      -- diagnostics appeared/became resolved
      vim.opt.signcolumn = "yes"

      local keyset = vim.keymap.set

      -- Autocomplete keybindings
      local completion_opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
      
      -- Helper function to check if cursor has whitespace behind it
      function _G.check_back_space()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
      end

      -- Need to use ctrl plus arrow keys to nagivate the autocomplete window
      keyset("i", "<Down>", 'coc#pum#visible() ? "<Down>" : "<Down>"', completion_opts)
      keyset("i", "<Up>", 'coc#pum#visible() ? "<Up>" : "<Up>"', completion_opts)
      keyset("i", "<C-Down>", 'coc#pum#visible() ? coc#pum#next(1) : "<C-Down>"', completion_opts)
      keyset("i", "<C-Up>", 'coc#pum#visible() ? coc#pum#prev(1) : "<C-Up>"', completion_opts)
      
      -- Use Tab to navigate completion menu OR insert tab if no completion
      keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#confirm() : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', completion_opts)
      keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], completion_opts)
      
      -- Use Ctrl+Y to accept coc.nvim completion (traditional Vim way)
      keyset("i", "<C-y>", [[coc#pum#v<S-Tab>isible() ? coc#pum#confirm() : "\<C-y>"]], completion_opts)

      -- Make Enter accept completion OR add newline if nothing selected
      keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], completion_opts)

      -- Use <c-space> to trigger completion
      keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})

      -- Use <c-j> to trigger snippets
      keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")

      -- Note: Tab navigates completion menu; Copilot uses Ctrl+Tab

      -- Diagnostic navigation
      keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {silent = true})
      keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {silent = true})

      -- GoTo code navigation
      keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
      keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
      keyset("n", "gi", "<Plug>(coc-implementation)", {silent = true})
      keyset("n", "gr", "<Plug>(coc-references)", {silent = true})

      -- Use K to show documentation in preview window
      function _G.show_docs()
        local cw = vim.fn.expand('<cword>')
        if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
          vim.api.nvim_command('h ' .. cw)
        elseif vim.api.nvim_eval('coc#rpc#ready()') then
          vim.fn.CocActionAsync('doHover')
        else
          vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
        end
      end
      keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})

      -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
      vim.api.nvim_create_augroup("CocGroup", {})
      vim.api.nvim_create_autocmd("CursorHold", {
        group = "CocGroup",
        command = "silent call CocActionAsync('highlight')",
        desc = "Highlight symbol under cursor on CursorHold"
      })

      -- Symbol renaming
      keyset("n", "<leader>rn", "<Plug>(coc-rename)", {silent = true})

      -- Formatting selected code
      keyset("x", "<leader>f", "<Plug>(coc-format-selected)", {silent = true})
      keyset("n", "<leader>f", "<Plug>(coc-format-selected)", {silent = true})

      -- Setup formatexpr specified filetype(s)
      vim.api.nvim_create_autocmd("FileType", {
        group = "CocGroup",
        pattern = "typescript,json",
        command = "setl formatexpr=CocAction('formatSelected')",
        desc = "Setup formatexpr specified filetype(s)."
      })

      -- Update signature help on jump placeholder
      vim.api.nvim_create_autocmd("User", {
        group = "CocGroup",
        pattern = "CocJumpPlaceholder",
        command = "call CocActionAsync('showSignatureHelp')",
        desc = "Update signature help on jump placeholder"
      })

      -- Code actions
      local action_opts = {silent = true, nowait = true}
      keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", action_opts)
      keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", action_opts)
      keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", action_opts)
      keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", action_opts)
      keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", action_opts)

      -- Refactor code actions
      keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", {silent = true})
      keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", {silent = true})
      keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", {silent = true})

      -- Run the Code Lens actions on the current line
      keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", action_opts)

      -- Map function and class text objects
      -- NOTE: Requires 'textDocument.documentSymbol' support from the language server
      keyset("x", "if", "<Plug>(coc-funcobj-i)", action_opts)
      keyset("o", "if", "<Plug>(coc-funcobj-i)", action_opts)
      keyset("x", "af", "<Plug>(coc-funcobj-a)", action_opts)
      keyset("o", "af", "<Plug>(coc-funcobj-a)", action_opts)
      keyset("x", "ic", "<Plug>(coc-classobj-i)", action_opts)
      keyset("o", "ic", "<Plug>(coc-classobj-i)", action_opts)
      keyset("x", "ac", "<Plug>(coc-classobj-a)", action_opts)
      keyset("o", "ac", "<Plug>(coc-classobj-a)", action_opts)

      -- Remap <C-f> and <C-b> to scroll float windows/popups
      local scroll_opts = {silent = true, nowait = true, expr = true}
      keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', scroll_opts)
      keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', scroll_opts)
      keyset("i", "<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', scroll_opts)
      keyset("i", "<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', scroll_opts)
      keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', scroll_opts)
      keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', scroll_opts)

      -- Use CTRL-E for selection ranges (remapped from CTRL-S to avoid conflict with Leap)
      -- Requires 'textDocument/selectionRange' support of language server
      keyset("n", "<C-e>", "<Plug>(coc-range-select)", {silent = true})
      keyset("x", "<C-e>", "<Plug>(coc-range-select)", {silent = true})

      -- Add `:Format` command to format current buffer
      vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

      -- Add `:Fold` command to fold current buffer
      vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {nargs = '?'})

      -- Add `:OR` command for organize imports of the current buffer
      vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

      -- Add (Neo)Vim's native statusline support
      vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

      -- Mappings for CoCList
      local list_opts = {silent = true, nowait = true}
      keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", list_opts)
      keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", list_opts)
      keyset("n", "<space>c", ":<C-u>CocList commands<cr>", list_opts)
      keyset("n", "<space>o", ":<C-u>CocList outline<cr>", list_opts)
      keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", list_opts)
      keyset("n", "<space>j", ":<C-u>CocNext<cr>", list_opts)
      keyset("n", "<space>k", ":<C-u>CocPrev<cr>", list_opts)
      keyset("n", "<space>p", ":<C-u>CocListResume<cr>", list_opts)
    end,
  },

  {
  "hat0uma/csvview.nvim",
    ---@module "csvview"
    ---@type CsvView.Options
    opts = {
      parser = { comments = { "#", "//" } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
      jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
  },
  
  -- GitHub Copilot
  --{
  --  "github/copilot.vim",
  --  config = function()
  --    vim.keymap.set('i', '<C-CR>', 'copilot#Accept("\\<CR>")', {
  --      expr = true,
  --      replace_keycodes = false,
  --      silent = true
  --    })
  --  end,
  --},
})

-- =========================
-- Keybindings
-- =========================
-- NvimTree toggle
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Clipboard operations
vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true })
vim.keymap.set("n", "<C-c>", '"+yy', { noremap = true, silent = true })
vim.keymap.set("n", "<C-v>", '"+p', { noremap = true, silent = true })
vim.keymap.set("i", "<C-v>", '<C-r>+', { noremap = true, silent = true })
vim.keymap.set("v", "<C-v>", '"+p', { noremap = true, silent = true })

-- Leap: Jump to search matches with Ctrl+S (forward) and Ctrl+Q (backward)
do
  local function leap_search (key, is_reverse)
    local cmdline_mode = vim.fn.mode(true):match('^c')
    if cmdline_mode then
      vim.api.nvim_feedkeys(vim.keycode('<enter>'), 't', false)
    end
    if vim.fn.searchcount().total < 1 then
      return
    end
    vim.go.hlsearch = vim.go.hlsearch
    vim.schedule(function ()
      require('leap').leap {
        pattern = vim.fn.getreg('/'),
        backward = (is_reverse and vim.v.searchforward == 1)
                   or (not is_reverse and vim.v.searchforward == 0),
        opts = require('leap.user').with_traversal_keys(key, nil, {
          safe_labels = (cmdline_mode and not vim.o.incsearch) and ''
                        or require('leap').opts.safe_labels:gsub('[nN]', '')
        })
      }
    end)
  end

  vim.keymap.set({'n', 'x', 'o', 'c'}, '<c-s>', function ()
    leap_search('<c-s>', false)
  end, { desc = 'Leap to search matches' })

  vim.keymap.set({'n', 'x', 'o', 'c'}, '<c-q>', function ()
    leap_search('<c-q>', true)
  end, { desc = 'Leap to search matches (reverse)' })
end

-- =========================
-- Autocmds
-- =========================
-- Open NvimTree on startup if no files specified
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("NvimTreeOpen")
    end
  end,
})

-- Close Neovim if NvimTree is the last window
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.fn.tabpagenr("$") == 1 and vim.fn.winnr("$") == 1 then
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname:match("NvimTree_") then
        vim.cmd("quit")
      end
    end
  end,
})

-- Leap: Auto-label search results after / or ?
vim.api.nvim_create_autocmd('CmdlineLeave', {
  group = vim.api.nvim_create_augroup('LeapOnSearch', {}),
  callback = function ()
    local ev = vim.v.event
    local is_search_cmd = (ev.cmdtype == '/') or (ev.cmdtype == '?')
    local cnt = vim.fn.searchcount().total
    if is_search_cmd and (not ev.abort) and (cnt > 1) then
      vim.schedule(function ()
        local labels = require('leap').opts.safe_labels:gsub('[nN]', '')
        local vim_opts = { ['wo.conceallevel'] = vim.wo.conceallevel }
        require('leap').leap {
          pattern = vim.fn.getreg('/'),
          windows = { vim.fn.win_getid() },
          opts = { safe_labels = '', labels = labels, vim_opts = vim_opts, }
        }
      end)
    end
  end,
})
