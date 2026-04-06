return {
  'stevearc/oil.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false,
  keys = {
    { '<leader>e', '<cmd>Oil<cr>', desc = 'Open parent directory' },
  },
  opts = {
    -- Show hidden files
    view_options = {
      show_hidden = true,
    },
  },
}
