-- VSCode Neovim Configuration

local function split(direction, file)
  vim.fn.VSCodeCall(direction == 'h' and 'workbench.action.splitEditorDown' or 'workbench.action.splitEditorRight')
  if file ~= '' then
    vim.fn.VSCodeExtensionNotify('open-file', vim.fn.expand(file), 'all')
  end
end

local function splitNew(direction, file)
  split(direction, file == '' and '__vscode_new__' or file)
end

local function closeOtherEditors()
  vim.fn.VSCodeNotify 'workbench.action.closeEditorsInOtherGroups'
  vim.fn.VSCodeNotify 'workbench.action.closeOtherEditors'
end

local function manageEditorSize(count, to)
  for _ = 1, count or 1 do
    vim.fn.VSCodeNotify(to == 'increase' and 'workbench.action.increaseViewSize' or 'workbench.action.decreaseViewSize')
  end
end

vim.api.nvim_create_user_command('Split', function(opts)
  split('h', opts.args)
end, { nargs = '?', complete = 'file' })
vim.api.nvim_create_user_command('Vsplit', function(opts)
  split('v', opts.args)
end, { nargs = '?', complete = 'file' })
vim.api.nvim_create_user_command('New', function(opts)
  split('h', '__vscode_new__')
end, { nargs = '?', complete = 'file' })
vim.api.nvim_create_user_command('Vnew', function(opts)
  split('v', '__vscode_new__')
end, { nargs = '?', complete = 'file' })
vim.api.nvim_create_user_command('Only', function(opts)
  if opts.bang then
    closeOtherEditors()
  else
    vim.fn.VSCodeNotify 'workbench.action.joinAllGroups'
  end
end, { bang = true })

-- Key mappings
vim.keymap.set('n', '<C-w>s', function()
  split('h', '')
end, { desc = 'Split window horizontally' })
vim.keymap.set('x', '<C-w>s', function()
  split('h', '')
end, { desc = 'Split window horizontally' })
vim.keymap.set('n', '<C-w>v', function()
  split('v', '')
end, { desc = 'Split window vertically' })
vim.keymap.set('x', '<C-w>v', function()
  split('v', '')
end, { desc = 'Split window vertically' })
vim.keymap.set('n', '<C-w>n', function()
  splitNew('h', '__vscode_new__')
end, { desc = 'New horizontal split' })
vim.keymap.set('x', '<C-w>n', function()
  splitNew('h', '__vscode_new__')
end, { desc = 'New horizontal split' })
vim.keymap.set('n', '<C-w>=', function()
  vim.fn.VSCodeNotify 'workbench.action.evenEditorWidths'
end, { desc = 'Even editor widths' })
vim.keymap.set('x', '<C-w>=', function()
  vim.fn.VSCodeNotify 'workbench.action.evenEditorWidths'
end, { desc = 'Even editor widths' })
vim.keymap.set('n', '<C-w>>', function()
  manageEditorSize(vim.v.count, 'increase')
end, { desc = 'Increase editor width' })
vim.keymap.set('x', '<C-w>>', function()
  manageEditorSize(vim.v.count, 'increase')
end, { desc = 'Increase editor width' })
vim.keymap.set('n', '<C-w>+', function()
  manageEditorSize(vim.v.count, 'increase')
end, { desc = 'Increase editor height' })
vim.keymap.set('x', '<C-w>+', function()
  manageEditorSize(vim.v.count, 'increase')
end, { desc = 'Increase editor height' })
vim.keymap.set('n', '<C-w><', function()
  manageEditorSize(vim.v.count, 'decrease')
end, { desc = 'Decrease editor width' })
vim.keymap.set('x', '<C-w><', function()
  manageEditorSize(vim.v.count, 'decrease')
end, { desc = 'Decrease editor width' })
vim.keymap.set('n', '<C-w>-', function()
  manageEditorSize(vim.v.count, 'decrease')
end, { desc = 'Decrease editor height' })
vim.keymap.set('x', '<C-w>-', function()
  manageEditorSize(vim.v.count, 'decrease')
end, { desc = 'Decrease editor height' })

-- Better Navigation
vim.keymap.set('n', '<C-j>', function()
  vim.fn.VSCodeNotify 'workbench.action.navigateDown'
end, { desc = 'Navigate down' })
vim.keymap.set('x', '<C-j>', function()
  vim.fn.VSCodeNotify 'workbench.action.navigateDown'
end, { desc = 'Navigate down' })
vim.keymap.set('n', '<C-k>', function()
  vim.fn.VSCodeNotify 'workbench.action.navigateUp'
end, { desc = 'Navigate up' })
vim.keymap.set('x', '<C-k>', function()
  vim.fn.VSCodeNotify 'workbench.action.navigateUp'
end, { desc = 'Navigate up' })
vim.keymap.set('n', '<C-h>', function()
  vim.fn.VSCodeNotify 'workbench.action.navigateLeft'
end, { desc = 'Navigate left' })
vim.keymap.set('x', '<C-h>', function()
  vim.fn.VSCodeNotify 'workbench.action.navigateLeft'
end, { desc = 'Navigate left' })
vim.keymap.set('n', '<C-l>', function()
  vim.fn.VSCodeNotify 'workbench.action.navigateRight'
end, { desc = 'Navigate right' })
vim.keymap.set('x', '<C-l>', function()
  vim.fn.VSCodeNotify 'workbench.action.navigateRight'
end, { desc = 'Navigate right' })

-- Commentary
vim.keymap.set('x', '<C-/>', function()
  vim.fn.Comment()
end, { desc = 'Toggle comment' })
vim.keymap.set('n', '<C-/>', function()
  vim.fn.Comment()
end, { desc = 'Toggle comment' })

vim.keymap.set('n', '<C-w>_', function()
  vim.fn.VSCodeNotify 'workbench.action.toggleEditorWidths'
end, { desc = 'Toggle editor widths' })
vim.keymap.set('n', '<Space>', function()
  vim.fn.VSCodeNotify 'whichkey.show'
end, { desc = 'Show which-key' })
vim.keymap.set('x', '<Space>', function()
  vim.fn.VSCodeNotify 'whichkey.show'
end, { desc = 'Show which-key' })
