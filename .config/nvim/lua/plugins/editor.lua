return {
  {
    "nvim-telescope/telescope.nvim",
    name = "telescope",
    keys = function(_, keys)
      local actions = require('telescope.actions')
      local builtin = require("telescope.builtin")
      local find_files = {
        ";f",
        function() builtin.find_files({ hidden = true }) end,
        desc = "Lists files in your current working directory, respects .gitignore"
      }
      local goto_definition = {
        ";d",
        function() builtin.lsp_definitions() end,
        desc =
        "Goto the definition of the word under the cursor, if there's only one, otherwise show all options in Telescope"
      }
      local goto_type_definition = {
        ";t",
        function() builtin.lsp_type_definitions() end,
        desc =
        "Goto the type definition of the word under the cursor, if there's only one, otherwise show all options in Telescope"
      }
      local show_symbol = {
        "lk",
        function() builtin.lsp_document_symbols() end,
        desc = "Lists all symbols in the current buffer"
      }
      local goto_incoming_calls = {
        "lr",
        function() builtin.lsp_incoming_calls() end,
        desc = "Lists all references to the word under the cursor"
      }
      local jump_list = {
        ";j",
        function() builtin.jumplist() end,
        desc = "Lists the jumplist"
      }
      local goto_outgoing_calls = {
        "lu",
        function() builtin.lsp_outgoing_calls() end,
        desc = "Lists all references to the word under the cursor"
      }
      local find_open_files = {
        "<C-e>",
        function() builtin.buffers() end,
        desc = "Lists open buffers",
      }
      local find_variables = {
        "<C-f>",
        function() builtin.live_grep() end,
        desc =
        "Search for a string in your current working directory and get results live as you type, respects .gitignore",
      }
      local find_warnings = {
        "??",
        function() builtin.diagnostics({ bufnr = 0 }) end,
        desc = "Lists Diagnostics for all open buffers or a specific buffer",
      }
      local show_normal_key_map = {
        "sk",
        function() builtin.keymaps() end,
        desc = "Lists normal mode keymappings"
      }
      table.insert(keys, find_files)
      table.insert(keys, find_open_files)
      table.insert(keys, find_variables)
      table.insert(keys, find_warnings)
      table.insert(keys, goto_definition)
      table.insert(keys, goto_type_definition)
      table.insert(keys, goto_incoming_calls)
      table.insert(keys, goto_outgoing_calls)
      table.insert(keys, show_normal_key_map)
      table.insert(keys, jump_list)
      table.insert(keys, show_symbol)
    end,
    dependencies = {
      {
        "nvim-lua/plenary.nvim",
        name = "plenary"
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        name = "telescope-fzf-native",
        build = "make"
      },
    }
  },
  {
    "nvim-lualine/lualine.nvim",
    name = "lualine",
    dependencies = {
      {
        "nvim-tree/nvim-web-devicons",
        name = "nvim-web-devicons"
      },
      {
        'AndreM222/copilot-lualine',
        name = "copilot-lualine"
      }
    },
    config = function()
      local status, lualine = pcall(require, "lualine")
      local icon_loaded, icon = pcall(require, "nvim-web-devicons")
      if (not status) then return end
      if (not icon_loaded) then return end
      local colors = {
        active_fg = "#ffc773",
        active_bg = "#5D2099",
        fg        = "#808080",
        bg        = "transparent",
      }
      -- config
      local config = {
        options = {
          component_separators = '',
          section_separators = '',
          theme = {
            normal = { c = { fg = colors.fg, bg = colors.bg } },
            -- inactive = { c = { fg = colors.active_fg, bg = colors.active_bg } }
          },
        },
        sections = {
          -- these are to remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          -- These will be filled later
          lualine_c = {},
          lualine_x = {},
        },
        inactive_sections = {
          -- these are to remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      }

      local function insert(section, widget)
        table.insert(section, widget)
      end

      insert(config.sections.lualine_a, {
        'branch'
      })

      insert(config.sections.lualine_a, {
        'diff',
        colored = true
      })
      insert(config.sections.lualine_b, { 'diagnostics' })
      insert(config.sections.lualine_x, {
        'copilot',
        symbols = {
          status = {
            icons = {
              enabled = " ",
              sleep = " ", -- auto-trigger disabled
              disabled = " ",
              warning = " ",
              unknown = " "
            },
            hl = {
              enabled = "#50FA7B",
              sleep = "#AEB7D0",
              disabled = "#6272A4",
              warning = "#FFB86C",
              unknown = "#FF5555"
            }
          },
          spinners = require("copilot-lualine.spinners").dots,
          spinner_color = "#6272A4"
        },
        show_colors = false,
        show_loading = true
      })
      insert(config.sections.lualine_x, {
        'buffers',
        mode = 0,
        icons_enabled = false,
        buffers_color = {
          active = { fg = colors.active_fg, bg = colors.active_bg },
          normal = { fg = colors.fg, bg = colors.bg }
        }
      })

      insert(config.sections.lualine_x, {
        'filetype',
        colored = true,
        icon = { align = 'left' }
      })

      insert(config.sections.lualine_y, { 'progress' })

      insert(config.sections.lualine_z, { 'location' })
      lualine.setup(config)
    end
  },
  {
    "williamboman/mason.nvim",
    name = "mason",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    name = "mason-lspconfig",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "bashls",
          "cmake",
          "dockerls",
          "gopls",
          "html",
          "jsonls",
          "pyright",
          "rust_analyzer",
          "lua_ls",
          "tsserver",
          "vimls",
          "yamlls",
        },
      })
    end
  }
}
