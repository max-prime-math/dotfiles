" ====================================================================
" Neovim config (vim-plug)
" ====================================================================

" -----------------------------[ Basics ]------------------------------
set number                            " Absolute line numbers
set relativenumber                    " Relative numbers for faster motions
set tabstop=4                         " Render a <Tab> as 4 spaces
set shiftwidth=4                      " Indent width for >>, <<, =, etc.
set expandtab                         " Insert spaces when pressing <Tab>
set smartindent                       " Smarter auto-indenting on new lines
set clipboard=unnamedplus             " Use system clipboard by default
set mouse=a                           " Enable mouse support in all modes
set termguicolors                     " True-color (many UIs expect this)
set signcolumn=yes                    " Always show sign column (lint/git)
syntax on                             " Syntax highlighting

" ---------------------------[ Leader Key ]----------------------------
let mapleader = "\\"

" ----------------------------[ Keymaps ]------------------------------
" Core actions
nnoremap <Leader>w :w<CR>             " Save
nnoremap <Leader>q :q<CR>             " Quit
nnoremap <Leader>x :x<CR>             " Save & quit
nnoremap <Leader>h :nohlsearch<CR>    " Clear search highlight

" File tree & tools
nnoremap <Leader>t :NvimTreeToggle<CR>          " Toggle file explorer
nnoremap <Leader>b :TeXpresso %<CR>             " Run TeXpresso
nnoremap <Leader>l :VimtexCompile<CR>           " Compile LaTeX via VimTeX

" Telescope (fuzzy finder)
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Edit / reload this config
nnoremap <leader>E :edit $MYVIMRC<CR>
nnoremap <leader>V :source $MYVIMRC<CR>

" ----------------------[ Built-ins / Replacements ]-------------------
" Disable the built-in matchparen (we use the Lua plugin version below)
let g:loaded_matchparen = 1

" ----------------------[ Plugin Manager: vim-plug ]-------------------
" After cloning, install vim-plug then run :PlugInstall inside nvim.
" Install vim-plug: https://github.com/junegunn/vim-plug#neovim
call plug#begin('~/.config/nvim/plugged')

" --- Core / dependencies ---
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" --- UI / colors / visuals ---
Plug 'morhetz/gruvbox'
Plug 'sphamba/smear-cursor.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'romgrk/barbar.nvim'

" --- Editing ---
Plug 'mg979/vim-visual-multi'
Plug 'numToStr/Comment.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'monkoose/matchparen.nvim'

" --- Search / navigation ---
Plug 'nvim-telescope/telescope.nvim'

" --- Git ---
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'

" --- LaTeX / media ---
Plug 'lervag/vimtex'
Plug 'HakonHarnes/img-clip.nvim'
Plug 'chomosuke/typst-preview.nvim', {'tag': 'v1.*'}

" --- Claude ---
Plug 'greggh/claude-code.nvim'

call plug#end()

" -------------------------[ Colors / Theme ]--------------------------
colorscheme gruvbox

" -------------------------[ Plugin Settings ]-------------------------
lua << EOF

-- Treesitter (v1.x API)
require('nvim-treesitter').setup({
  ensure_installed = { "lua", "python", "latex", "typst", "vim" },
})

-- Comment.nvim — toggle with gc / gcc
require('Comment').setup()

-- nvim-autopairs
require('nvim-autopairs').setup({})

-- matchparen.nvim
require('matchparen').setup()

-- gitsigns
require('gitsigns').setup({})

-- img-clip
require('img-clip').setup({})

-- typst-preview
require('typst-preview').setup({
  invert_colors = '{"rest": .5,"image":.5}',
  follow_cursor = true,
})

-- Claude Code
require("claude-code").setup({
  window = {
    split_ratio = 0.3,
    position = "botright",
    enter_insert = true,
    hide_numbers = true,
    hide_signcolumn = true,
    float = {
      width = "80%",
      height = "80%",
      row = "center",
      col = "center",
      relative = "editor",
      border = "rounded",
    },
  },
  refresh = {
    enable = true,
    updatetime = 100,
    timer_interval = 1000,
    show_notifications = true,
  },
  git = {
    use_git_root = true,
  },
  shell = {
    separator = '&&',
    pushd_cmd = 'pushd',
    popd_cmd = 'popd',
  },
  command = "claude",
  command_variants = {
    continue = "--continue",
    resume = "--resume",
    verbose = "--verbose",
  },
  keymaps = {
    toggle = {
      normal = "<C-C>",
      terminal = "<C-C>",
      variants = {
        continue = "<leader>cC",
        verbose = "<leader>cV",
      },
    },
    window_navigation = true,
    scrolling = true,
  }
})

-- nvim-tree
local function on_attach(bufnr)
  local api = require("nvim-tree.api")
  api.config.mappings.default_on_attach(bufnr)
  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end
  local keymap = vim.keymap.set
  keymap("n", "t", api.node.open.tab,        opts("Open: New Tab"))
  keymap("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
  keymap("n", "v", api.node.open.vertical,   opts("Open: Vertical Split"))
end

require("nvim-tree").setup({
  on_attach = on_attach,
  git = { enable = false },
  filesystem_watchers = { enable = false },
  filters = {
    dotfiles = true,
    custom = { "*.aux","*.log","*.out","*.fls","*.gz","*.fdb_latexmk","*.dvi" },
  },
  view = { width = 30, side = "left" },
  renderer = { icons = { show = { file = true, folder = true, git = false } } },
})

-- When :q-ing the last real buffer, close the tree so nvim exits cleanly
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local real_wins = 0
    local tree_wins = 0
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
      if ft == "NvimTree" then
        tree_wins = tree_wins + 1
      else
        real_wins = real_wins + 1
      end
    end
    if real_wins == 1 and tree_wins >= 1 then
      require("nvim-tree.api").tree.close()
    end
  end,
})

EOF

" VimTeX
let g:vimtex_view_method = 'zathura'
let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_quickfix_open_on_warning = 0
let g:vimtex_quickfix_open_on_error   = 1

augroup quickfix_settings
  autocmd!
  autocmd FileType qf wincmd J | resize 5
augroup END

" Visual Multi
let g:VM_maps = {}
let g:VM_maps['Find Under'] = '<Leader><Leader>'

" ---------------------[ Convenience Functions ]-----------------------
let s:wrapenabled = 0
function! ToggleWrap()
  if s:wrapenabled
    set nowrap nolinebreak
    silent! unmap j | silent! unmap k | silent! unmap 0 | silent! unmap ^ | silent! unmap $
    silent! vunmap j | silent! vunmap k | silent! vunmap 0 | silent! vunmap ^ | silent! vunmap $
    let s:wrapenabled = 0
  else
    set wrap nolist linebreak
    set textwidth=50
    nnoremap j gj | nnoremap k gk | nnoremap 0 g0 | nnoremap ^ g^ | nnoremap $ g$
    vnoremap j gj | vnoremap k gk | vnoremap 0 g0 | vnoremap ^ g^ | vnoremap $ g$
    let s:wrapenabled = 1
  endif
endfunction
nnoremap <leader>W :call ToggleWrap()<CR>

" ------------------------[ Barbar (bufferline) ]----------------------
nnoremap <silent> <A-,>  <Cmd>BufferPrevious<CR>
nnoremap <silent> <A-.>  <Cmd>BufferNext<CR>
nnoremap <silent> <A-<>  <Cmd>BufferMovePrevious<CR>
nnoremap <silent> <A->>  <Cmd>BufferMoveNext<CR>
nnoremap <silent> <A-1>  <Cmd>BufferGoto 1<CR>
nnoremap <silent> <A-2>  <Cmd>BufferGoto 2<CR>
nnoremap <silent> <A-3>  <Cmd>BufferGoto 3<CR>
nnoremap <silent> <A-4>  <Cmd>BufferGoto 4<CR>
nnoremap <silent> <A-5>  <Cmd>BufferGoto 5<CR>
nnoremap <silent> <A-6>  <Cmd>BufferGoto 6<CR>
nnoremap <silent> <A-7>  <Cmd>BufferGoto 7<CR>
nnoremap <silent> <A-8>  <Cmd>BufferGoto 8<CR>
nnoremap <silent> <A-9>  <Cmd>BufferGoto 9<CR>
nnoremap <silent> <A-0>  <Cmd>BufferLast<CR>
nnoremap <silent> <A-p>  <Cmd>BufferPin<CR>
nnoremap <silent> <A-c>    <Cmd>BufferClose<CR>
nnoremap <silent> <A-s-c>  <Cmd>BufferRestore<CR>
nnoremap <silent> <C-p>    <Cmd>BufferPick<CR>
nnoremap <silent> <C-S-p>  <Cmd>BufferPickDelete<CR>
nnoremap <silent> <Leader>bb <Cmd>BufferOrderByBufferNumber<CR>
nnoremap <silent> <Leader>bn <Cmd>BufferOrderByName<CR>
nnoremap <silent> <Leader>bd <Cmd>BufferOrderByDirectory<CR>
nnoremap <silent> <Leader>bl <Cmd>BufferOrderByLanguage<CR>
nnoremap <silent> <Leader>bw <Cmd>BufferOrderByWindowNumber<CR>

lua << EOF
local function trim_and_drop_blank_lines(lines)
  local out = {}

  for _, line in ipairs(lines) do
    if line:match("%S") then
      local cleaned = line:gsub("^%s+", "")
      cleaned = cleaned:gsub("%s+$", "")
      table.insert(out, cleaned)
    end
  end

  return out
end

function _G.merge_questions_and_answers()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local blocks = {}
  local current = nil

  for _, line in ipairs(lines) do
    local n, text = line:match("^%s*(%d+)%.%s*(.*)$")
    if n then
      if current then
        table.insert(blocks, current)
      end
      current = {
        num = tonumber(n),
        lines = { text or "" },
      }
    else
      if current then
        table.insert(current.lines, line)
      end
    end
  end

  if current then
    table.insert(blocks, current)
  end

  if #blocks == 0 then
    vim.notify("No numbered items found.", vim.log.levels.WARN)
    return
  end

  local split_at = nil
  for i = 2, #blocks do
    if blocks[i].num == 1 then
      split_at = i
      break
    end
  end

  if not split_at then
    vim.notify("Could not find where answers begin.", vim.log.levels.ERROR)
    return
  end

  local questions = {}
  local answers = {}

  for i = 1, split_at - 1 do
    questions[blocks[i].num] = trim_and_drop_blank_lines(blocks[i].lines)
  end

  for i = split_at, #blocks do
    answers[blocks[i].num] = trim_and_drop_blank_lines(blocks[i].lines)
  end

  local max_num = 0
  for k, _ in pairs(questions) do
    if k > max_num then
      max_num = k
    end
  end

  local result = {}

  for i = 1, max_num do
    local q = questions[i] or { "[missing question]" }
    local a = answers[i] or { "[missing answer]" }

    table.insert(result, string.format("%d. %s", i, q[1] or ""))
    for j = 2, #q do
      table.insert(result, q[j])
    end

    table.insert(result, "[answer]")
    for _, line in ipairs(a) do
      table.insert(result, line)
    end

    if i < max_num then
      table.insert(result, "")
    end
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
end
EOF

command! MergeQA lua merge_questions_and_answers()
