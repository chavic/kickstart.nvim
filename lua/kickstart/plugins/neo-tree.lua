-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '3' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

require('neo-tree').setup {
  -- Trouble owns diagnostics and Gitsigns owns change indicators. Keeping
  -- those jobs out of the tree prevents expensive redraws in large solutions.
  enable_diagnostics = false,
  enable_git_status = false,
  filesystem = {
    -- `auto` scans synchronously when invoked by `:Neotree reveal`; `always`
    -- keeps the UI responsive while a large repository is being discovered.
    async_directory_scan = 'always',
    filtered_items = {
      -- Generated .NET trees can contain thousands of files and are never
      -- useful in the project explorer.
      never_show = { '.git', 'bin', 'obj' },
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
