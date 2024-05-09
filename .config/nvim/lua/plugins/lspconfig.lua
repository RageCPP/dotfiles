return {
  {
    "hrsh7th/nvim-cmp",
    name = "cmp",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-vsnip" },
      { "hrsh7th/vim-vsnip" },
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      {
        "neovim/nvim-lspconfig",
        name = "lspconfig",
        config = function(_, opts)
          local lspconfig_status, lspconfig = pcall(require, 'lspconfig')
          local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
          local status = lspconfig_status and cmp_nvim_lsp_status
          if (not status) then return end
          local api = vim.api
          local lsp_defaults = lspconfig.util.default_config
          lsp_defaults.capabilities = vim.tbl_deep_extend(
            'force',
            lsp_defaults.capabilities,
            cmp_nvim_lsp.default_capabilities()
          )
          -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
          local open_servers = { 'clangd', 'lua_ls', "neocmake", "rust_analyzer", "tsserver", "bashls", "postgres_lsp" }

          for _, lsp in ipairs(open_servers) do
            lspconfig[lsp].setup({})
          end
          lspconfig.postgres_lsp.setup = {
            name = 'postgres_lsp',
            cmd = { 'postgres_lsp' },
            filetypes = { 'sql' },
            single_file_support = true,
            root_dir = lspconfig.util.root_pattern 'root-file.txt'
          }
          -- clangd
          -- lspconfig.clangd.setup {
          --   init_options = {
          --     fallbackFlags = { "-x", "c" }, -- 设置只用c的标准，不是cpp或者object c的标准一起用
          --   },
          --   filetypes = { "c", "h"},
          --
          lspconfig.clangd.setup {
            filetypes = { "cpp", "objc", "objcpp", "cuda", "proto", "hpp" },
            cmd = {
              "clangd",
              "--all-scopes-completion=true",
              "--background-index",
              "--background-index-priority=normal",
              "--clang-tidy",
              "--completion-style=detailed",
              "--function-arg-placeholders=true",
              "--header-insertion=iwyu",
              "--header-insertion-decorators",
              "--import-insertions",
              "--enable-config",
              "-j=32",
              "--malloc-trim",
              "--pch-storage=memory",
              "--log=error",
              "--pretty",
            },
          }
          api.nvim_create_autocmd('LspAttach', {
            callback = function(args)
              local keybind = function(mode, lhs, rhs)
                vim.keymap.set(mode, lhs, rhs, { buffer = args.buf })
              end

              keybind('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')
              keybind('n', '``', '<cmd>lua vim.lsp.buf.format()<cr>')
              keybind('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
              keybind('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
              -- keybind('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')
            end
          })
        end,
      },
      {
        "onsails/lspkind.nvim",
        name = "lspkind",
        opts = {
          -- enables text annotations
          --
          -- default: true
          mode = 'symbol',

          -- default symbol map
          -- can be either 'default' (requires nerd-fonts font) or
          -- 'codicons' for codicon preset (requires vscode-codicons font)
          --
          -- default: 'default'
          preset = 'codicons',

          -- override preset symbols
          --
          -- default: {}
          symbol_map = {
            Text = "",
            Method = "󰡱",
            Function = "󰡱",
            Constructor = "",
            Field = "",
            Variable = "",
            Class = "",
            Interface = "",
            Module = "",
            Property = "",
            Unit = "󰹻",
            Value = "󱩡",
            Enum = "",
            Keyword = "",
            Snippet = "",
            Color = "󰉦",
            File = "",
            Reference = "",
            Folder = "",
            EnumMember = "",
            Constant = "",
            Struct = "",
            Event = "",
            Operator = "",
            TypeParameter = "",
            Copilot = "",
          },
        },
        config = function(_, opts)
          local status, lspkind = pcall(require, "lspkind")
          if (not status) then return end
          lspkind.init(opts)
        end
      },
    },
    config = function()
      local cmp_status, cmp = pcall(require, 'cmp')
      local lspkind_status, lspkind = pcall(require, 'lspkind')
      local status = cmp_status and lspkind_status
      if (not status) then return end

      local function formatForTailwindCSS(entry, vim_item)
        if vim_item.kind == 'Color' and entry.completion_item.documentation then
          local _, _, r, g, b = string.find(entry.completion_item.documentation, '^rgb%((%d+), (%d+), (%d+)')
          if r then
            local color = string.format('%02x', r) .. string.format('%02x', g) .. string.format('%02x', b)
            local group = 'Tw_' .. color
            if vim.fn.hlID(group) < 1 then
              vim.api.nvim_set_hl(0, group, { fg = '#' .. color })
            end
            vim_item.kind = "●"
            vim_item.kind_hl_group = group
            return vim_item
          end
        end
        vim_item.kind = lspkind.symbolic(vim_item.kind) and lspkind.symbolic(vim_item.kind) or vim_item.kind
        return vim_item
      end

      local has_words_before = function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
      end

      cmp.setup({
        sorting = {
          priority_weight = 2,
          comparators = {
            require("copilot_cmp.comparators").prioritize,

            -- Below is the default comparitor list and order for nvim-cmp
            cmp.config.compare.offset,
            -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        snippet = { expand = function(args) vim.fn["vsnip#anonymous"](args.body) end },
        sources = cmp.config.sources({
          { name = "copilot",  group_index = 2 },
          { name = 'nvim_lsp', group_index = 2 },
          { name = 'vsnip',    group_index = 2 }
        }, { { name = 'buffer' } }),
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
          }),
          ["<Tab>"] = vim.schedule_wrap(function(fallback)
            if cmp.visible() and has_words_before() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end),
        }),
        formatting = {
          format = lspkind.cmp_format({
            maxwidth = 50,
            before = function(entry, vim_item)
              vim_item = formatForTailwindCSS(entry, vim_item)
              return vim_item
            end
          })
        }
      })
      vim.cmd [[
        set completeopt=menuone,noinsert,noselect
        highlight! default link CmpItemKind CmpItemMenuDefault
      ]]
    end
  },
}
