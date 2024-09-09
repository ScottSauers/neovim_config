-- Tell the linter that 'vim' is a global variable
---@diagnostic disable: undefined-global

-- Basic Settings
vim.opt.number = true                -- Show line numbers
vim.opt.tabstop = 4                  -- Number of spaces tabs count for
vim.opt.shiftwidth = 2               -- Size of an indent
vim.opt.expandtab = true             -- Use spaces instead of tabs
vim.opt.smartindent = true           -- Insert indents automatically
vim.opt.termguicolors = true         -- True color support
vim.opt.scrolloff = 8                -- Lines of context
vim.opt.sidescrolloff = 8            -- Columns of context
vim.opt.clipboard = "unnamedplus"    -- Use system clipboard
vim.opt.virtualedit = "block"        -- Allow cursor to move where there is no text in visual block mode
vim.opt.mouse = "a"                  -- Enable mouse support
vim.opt.signcolumn = "yes"           -- Always show the signcolumn
vim.opt.shortmess:append("I")        -- Turn off the intro message
vim.g.rustfmt_autosave = 1
vim.opt.guifont = "DejaVuSansMono Nerd Font:h12"
vim.g.have_nerd_font = true

-- Plugin Manager (Lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({

  -- Language-specific plugins
  { "rhysd/vim-clang-format", ft = { "c", "cpp" } },
  { "alaviss/nim.nvim" },
  { "wlangstroth/vim-racket" },
  { "adimit/prolog.vim" },
  { "krischik/vim-ada" },

  -- Color scheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        background = { light = "latte", dark = "mocha" },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
        },
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "lua", "vim", "vimdoc", "query",
        "rust", "python",
        "javascript", "typescript", "tsx",
        "html", "css", "json",
        "bash", "markdown", "markdown_inline",
        "c"
      },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      })
    end,
  },

  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
  },

  -- Telescope (Fuzzy Finder)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Formatting and Linting
  { "stevearc/conform.nvim" },
  { "mfussenegger/nvim-lint" },

  -- Comments
  { "numToStr/Comment.nvim", opts = {} },

  -- Auto Pairs
  { "windwp/nvim-autopairs", opts = {} },

  -- Status Line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Configure icons
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require('nvim-web-devicons').setup {
        default = true,
        strict = true,
      }
    end
  },

    -- Debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      require("dapui").setup()
      require("nvim-dap-virtual-text").setup()
    end,
  },

  -- Diagnostics
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup {}
      vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Toggle Trouble" })
    end,
  },

  -- Git integration
  { "lewis6991/gitsigns.nvim" },

  -- Indent guides
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
})

-- Provider setup
local function set_python3_host_prog()
  local function is_valid_python(path)
    if vim.fn.executable(path) == 1 then
      local version = vim.fn.system(path .. " --version")
      return version:match("Python 3")
    end
    return false
  end

  local possible_python_paths = {
    vim.fn.exepath("python3"),
    vim.fn.exepath("python"),
    "/usr/bin/python3",
    "/usr/local/bin/python3",
    "/opt/homebrew/bin/python3",
    vim.fn.expand("~/.pyenv/shims/python3"),
    vim.fn.expand("~/.asdf/shims/python3"),
    vim.fn.expand("~/.config/nvim/env/bin/python")
  }

  for _, path in ipairs(possible_python_paths) do
    if is_valid_python(path) then
      vim.g.python3_host_prog = path
      return
    end
  end

  print("Warning: No suitable Python 3 executable found for Neovim provider")
end

set_python3_host_prog()

vim.g.loaded_ruby_provider = 0

-- Clipboard setup
vim.opt.clipboard:append("unnamedplus")

-- LSP Setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "rust_analyzer", "pyright", "tsserver", "cssls", "bashls", "eslint" },
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = { "lua_ls", "rust_analyzer", "pyright", "tsserver", "cssls", "bashls", "clangd" }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    capabilities = capabilities,
  })
end

lspconfig.tsserver.setup({
  capabilities = capabilities,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = lspconfig.util.root_pattern("package.json"),
  settings = {
    javascript = {
      implicitProjectConfig = {
        checkJs = true  -- Enable type checking for JavaScript files
      }
    }
  }
})

lspconfig.eslint.setup({
  capabilities = capabilities,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  settings = {
    workingDirectory = { mode = "auto" },
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = "separateLine"
      },
      showDocumentation = {
        enable = true
      }
    }
  }
})

lspconfig.rust_analyzer.setup({
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = true,
        experimental = { enable = true },
      },
    },
  },
})

-- Autocompletion Setup
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
})

-- Telescope Setup
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Find buffers" })

-- File Explorer Setup
require("nvim-tree").setup()
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Formatting Setup
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "black" },
    javascript = { "prettier", "eslint" },
    typescript = { "prettier", "eslint" },
    javascriptreact = { "prettier", "eslint" },
    typescriptreact = { "prettier", "eslint" },
    css = { "prettier" },
    c = { "clang-format" },
    cpp = { "clang-format" },
  },
})

vim.keymap.set("n", "<leader>f", function() require("conform").format() end, { desc = "Format file" })

-- Linting Setup
local lint = require("lint")

lint.linters_by_ft = {
  python = { "pylint", "flake8" },
  javascript = { "eslint" },
  typescript = { "eslint" },
  javascriptreact = { "eslint" },
  typescriptreact = { "eslint" },
}

lint.linters.pylint.cmd = "pylint"
lint.linters.pylint.stdin = true
lint.linters.pylint.args = {
  "-f", "json",
  "--from-stdin",
  "--max-line-length=120",
  "--disable=C0103,C0111,C0301,C0325,C0411,C0412,W0611,E1101",
  function()
    return vim.fn.expand("%:p")
  end
}
lint.linters.pylint.stream = "stdout"
lint.linters.pylint.ignore_exitcode = true

lint.linters.flake8.args = {
  "--max-line-length=120",
  "--ignore=E203,E266,E501,W503",
  "--max-complexity=18",
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    lint.try_lint()
  end,
})

-- Status Line Setup
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = false,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

-- Git Signs Setup
require('gitsigns').setup()

-- Check if running on macOS
local is_mac = vim.fn.has("macunix") == 1

if is_mac then
  -- Use macOS clipboard for unnamed register
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 0,
  }
end

-- Custom Keymaps
vim.g.mapleader = " "  -- Set leader key to space
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })
vim.keymap.set("n", "<leader>t", ":terminal<CR>", { desc = "Open terminal" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set('n', '<leader>rc', ':!gcc % && ./a.out<CR>', { noremap = true, silent = false })
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true, silent = true })
vim.keymap.set('n', '<C-v>', '"+p', { noremap = true, silent = true })
vim.keymap.set('i', '<C-v>', '<C-r>+', { noremap = true, silent = true })
vim.keymap.set({'n', 'v', 'i'}, '<C-a>', '<Esc>ggVG', { noremap = true, silent = true })  -- Ctrl+A for select all

-- Copy all
vim.keymap.set('n', 'Y', function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local text = table.concat(lines, "\n")
    vim.fn.setreg('+', text)
    vim.notify("All text copied to clipboard", vim.log.levels.INFO, { timeout = 100 })
end, { noremap = true, silent = false, desc = "Copy all text to clipboard" })

-- Open terminal
vim.keymap.set('n', 'T', function()
    local term_bufs = vim.tbl_filter(function(buf)
        return vim.bo[buf].buftype == 'terminal'
    end, vim.api.nvim_list_bufs())
    
    if #term_bufs > 0 then
        for _, buf in ipairs(term_bufs) do
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
    vim.cmd('bot term')
end, { noremap = true, silent = true, desc = "Toggle bottom terminal" })

-- Function to open terminal and run last command
vim.keymap.set('n', 'F', function()
    -- Find and close existing terminal if any
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
            break
        end
    end
    
    -- Open a new terminal at the bottom
    vim.cmd('botright split term://bash')  -- or 'zsh', or whatever shell you use

    -- Give the terminal some time to initialize, then send keys
    vim.defer_fn(function()
        -- Enter terminal mode
        vim.cmd('normal a')

        -- Send 'Up' to get the last command, then 'Enter' to run it
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Up><CR>', true, false, true), 'n', false)
    end, 50) -- Adjust the delay if necessary
end, { noremap = true, silent = true, desc = "Open terminal and run last command" })

-- Terminal path autocompletion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest,list,full"
vim.opt.wildoptions = "pum"
vim.api.nvim_set_keymap('t', '<Tab>', [[wildmenumode() ? "\<C-N>" : "\<Tab>"]], {expr = true, noremap = true})
vim.api.nvim_set_keymap('t', '<S-Tab>', [[wildmenumode() ? "\<C-P>" : "\<S-Tab>"]], {expr = true, noremap = true})

-- Auto Commands
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank() end,
})

-- LSP keybindings
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})
