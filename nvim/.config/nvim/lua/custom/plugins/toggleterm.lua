vim.pack.add {
  { src = 'https://github.com/akinsho/toggleterm.nvim', version = vim.version.range '*' },
}

require('toggleterm').setup {
  size = 15,
  open_mapping = [[<C-\>]],
  direction = 'horizontal',
  shade_terminals = true,
  persist_size = true,
  start_in_insert = true,
}

vim.keymap.set('n', '<leader>tf', '<Cmd>ToggleTerm direction=float<CR>', { desc = '[T]erminal [F]loat' })

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*toggleterm#*',
  callback = function()
    local o = { buffer = 0 }
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], o)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], o)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], o)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], o)
  end,
})

local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new {
  cmd = 'lazygit',
  direction = 'float',
  hidden = true,
  float_opts = { border = 'curved' },
}
vim.keymap.set('n', '<leader>gg', function() lazygit:toggle() end, { desc = 'Lazy[G]it' })
