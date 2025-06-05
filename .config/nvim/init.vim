" --- Basics ---
set nocompatible          " Be Vim, not vi
set number                " Show line numbers
set relativenumber        " Relative line numbers (better motions)
set tabstop=4             " Tab = 4 spaces
set shiftwidth=4          " Auto-indent = 4 spaces
set expandtab             " Tabs are spaces
set smartindent           " Smart autoindenting
set clipboard=unnamedplus " System clipboard support
set mouse=a               " Enable mouse support
syntax on                 " Syntax highlighting

let g:vimtex_enabled = 1

" --- Leader key ---
" let mapleader = ","

" --- Basic keymaps ---
nnoremap <Leader>w :w<CR>    " Save file
nnoremap <Leader>q :q<CR>    " Quit
nnoremap <Leader>x :x<CR>    " Save and quit
nnoremap <Leader>h :nohlsearch<CR> " Clear search highlight
nnoremap <Leader>t :NvimTreeToggle<CR> " Toggle NvimTree

" --- Plugin Manager (vim-plug) ---
call plug#begin('~/.config/nvim/plugged')

" Essentials
Plug 'nvim-telescope/telescope.nvim' " Fuzzy finder
Plug 'nvim-lua/plenary.nvim' " Dependency for telescope
Plug 'mg979/vim-visual-multi' " Multi-cursor editing
Plug 'morhetz/gruvbox' " Nice colorscheme
Plug 'lervag/vimtex' " LaTeX in nvim
Plug 'nvim-tree/nvim-tree.lua' " File explorer
Plug 'romgrk/barbar.nvim' " Statusbar
Plug 'nvim-tree/nvim-web-devicons' " optional: for icons
Plug 'nvim-treesitter/nvim-treesitter' "improved syntax
Plug 'mfussenegger/nvim-lint' " linter
Plug 'windwp/nvim-autopairs' " autopairs
Plug 'HakonHarnes/img-clip.nvim' " paste images
Plug 'sphamba/smear-cursor.nvim' " animated cursor
Plug 'tpope/vim-fugitive' "
Plug 'lewis6991/gitsigns.nvim'
Plug 'folke/snacks.nvim'
Plug 'numToStr/Comment.nvim'
call plug#end()

" --- Plugin Settings ---
colorscheme gruvbox
let g:VM_maps = {}
let g:VM_maps['Find Under'] = '<Leader>'  " Safer keybinding
lua require('Comment').setup()

" --- VimTeX & Sumatra ---
let g:vimtex_view_general_viewer = 'SumatraPDF'
let g:vimtex_view_general_options
      \ = '-reuse-instance -forward-search @tex @line @pdf'
" let g:vimtex_view_general_options_latexmk = '-reuse-instance'
let g:vimtex_compiler_method = 'latexmk'

lua << EOF
local function on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  local keymap = vim.keymap.set
  keymap("n", "t", api.node.open.tab, opts("Open: New Tab"))
  keymap("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
  keymap("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
end

require("nvim-tree").setup({
  filters = {
    dotfiles = true,
    custom = {
      "*.aux",
      "*.log",
      "*.out",
      "*.fls",
      "*.gz",
      "*latexmk"
    },
  },
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        git = false,
      },
    },
  },
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-tree.api").tree.open()
  end
})
EOF

let s:wrapenabled = 0
function! ToggleWrap()
  set wrap nolist
  if s:wrapenabled
    set nolinebreak
    unmap j
    unmap k
    unmap 0
    unmap ^
    unmap $
    let s:wrapenabled = 0
  else
    set linebreak
    set textwidth=50
    nnoremap j gj
    nnoremap k gk
    nnoremap 0 g0
    nnoremap ^ g^
    nnoremap $ g$
    vnoremap j gj
    vnoremap k gk
    vnoremap 0 g0
    vnoremap ^ g^
    vnoremap $ g$
    let s:wrapenabled = 1
  endif
endfunction
map <leader>w :call ToggleWrap()<CR>

" Move to previous/next
nnoremap <silent>    <A-,> <Cmd>BufferPrevious<CR>
nnoremap <silent>    <A-.> <Cmd>BufferNext<CR>

" Re-order to previous/next
nnoremap <silent>    <A-<> <Cmd>BufferMovePrevious<CR>
nnoremap <silent>    <A->> <Cmd>BufferMoveNext<CR>

" Goto buffer in position...
nnoremap <silent>    <A-1> <Cmd>BufferGoto 1<CR>
nnoremap <silent>    <A-2> <Cmd>BufferGoto 2<CR>
nnoremap <silent>    <A-3> <Cmd>BufferGoto 3<CR>
nnoremap <silent>    <A-4> <Cmd>BufferGoto 4<CR>
nnoremap <silent>    <A-5> <Cmd>BufferGoto 5<CR>
nnoremap <silent>    <A-6> <Cmd>BufferGoto 6<CR>
nnoremap <silent>    <A-7> <Cmd>BufferGoto 7<CR>
nnoremap <silent>    <A-8> <Cmd>BufferGoto 8<CR>
nnoremap <silent>    <A-9> <Cmd>BufferGoto 9<CR>
nnoremap <silent>    <A-0> <Cmd>BufferLast<CR>

" Pin/unpin buffer
nnoremap <silent>    <A-p> <Cmd>BufferPin<CR>

" Goto pinned/unpinned buffer
"                          :BufferGotoPinned
"                          :BufferGotoUnpinned

" Close buffer
nnoremap <silent>    <A-c> <Cmd>BufferClose<CR>
" Restore buffer
nnoremap <silent>    <A-s-c> <Cmd>BufferRestore<CR>

" Wipeout buffer
"                          :BufferWipeout
" Close commands
"                          :BufferCloseAllButCurrent
"                          :BufferCloseAllButVisible
"                          :BufferCloseAllButPinned
"                          :BufferCloseAllButCurrentOrPinned
"                          :BufferCloseBuffersLeft
"                          :BufferCloseBuffersRight

" Magic buffer-picking mode
nnoremap <silent> <C-p>    <Cmd>BufferPick<CR>
nnoremap <silent> <C-s-p>  <Cmd>BufferPickDelete<CR>

" Sort automatically by...
nnoremap <silent> <Space>bb <Cmd>BufferOrderByBufferNumber<CR>
nnoremap <silent> <Space>bn <Cmd>BufferOrderByName<CR>
nnoremap <silent> <Space>bd <Cmd>BufferOrderByDirectory<CR>
nnoremap <silent> <Space>bl <Cmd>BufferOrderByLanguage<CR>
nnoremap <silent> <Space>bw <Cmd>BufferOrderByWindowNumber<CR>

" Other:
" :BarbarEnable - enables barbar (enabled by default)
" :BarbarDisable - very bad command, should never be used
