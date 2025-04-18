return {
  {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim',
    },
    config = function()
      require('flutter-tools').setup {
        ui = {
          border = 'rounded',
          notification_style = 'native',
        },
        decorations = {
          statusline = {
            app_version = true,
            device = true,
          },
        },
        widget_guides = {
          enabled = true,
        },
        lsp = {
          color = {
            enabled = true,
            background = true,
            foreground = false,
            virtual_text = true,
            virtual_text_str = '■',
          },
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = 'prompt',
            enableSnippets = true,
          },
        },
        debugger = {
          enabled = false,
          run_via_dap = false,
        },
        dev_log = {
          enabled = true,
          open_cmd = 'tabedit',
        },
      }
    end,
  },
  { 'dart-lang/dart-vim-plugin' },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'dart' })
      end
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    opts = function()
      require('telescope').load_extension 'flutter'
    end,
  },
}
