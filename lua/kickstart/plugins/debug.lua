-- C# debugging with nvim-dap and Mason's netcoredbg adapter.

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
}

local dap = require 'dap'
local dapui = require 'dapui'

vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: Toggle UI' })
vim.keymap.set('n', '<F10>', dap.terminate, { desc = 'Debug: Terminate' })
vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Conditional Breakpoint' })

dapui.setup {
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

local netcoredbg = vim.fn.exepath 'netcoredbg'
if netcoredbg == '' then netcoredbg = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'bin', 'netcoredbg') end

dap.adapters.coreclr = {
  type = 'executable',
  command = netcoredbg,
  args = { '--interpreter=vscode' },
}

local last_dll
local function select_dll()
  local default = last_dll or vim.fs.joinpath(vim.fn.getcwd(), 'bin', 'Debug')
  local selected = vim.fn.input('Path to the C# DLL: ', default, 'file')
  if selected ~= '' then last_dll = selected end
  return selected
end

dap.configurations.cs = {
  {
    type = 'coreclr',
    name = 'Launch .NET DLL',
    request = 'launch',
    program = select_dll,
    cwd = function() return vim.fn.getcwd() end,
    stopAtEntry = false,
  },
  {
    type = 'coreclr',
    name = 'Attach to .NET process',
    request = 'attach',
    processId = require('dap.utils').pick_process,
  },
}
