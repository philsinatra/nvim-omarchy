return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- Helper function to find local binaries (from your macOS config)
    local function find_local_bin(bin_name)
      local project_root = vim.fn.getcwd() -- Consolidated single declaration

      if bin_name == "stylelint" then
        local node_bin = project_root .. "/node_modules/.bin/" .. bin_name
        if vim.fn.executable(node_bin) == 1 then
          return node_bin
        end
      end
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/" .. bin_name
      if vim.fn.executable(mason_bin) == 1 then
        return mason_bin
      end
      local vendor_bin = project_root .. "/vendor/bin/" .. bin_name
      if vim.fn.executable(vendor_bin) == 1 then
        return vendor_bin
      end
      local node_bin = project_root .. "/node_modules/.bin/" .. bin_name
      if vim.fn.executable(node_bin) == 1 then
        return node_bin
      end
      return bin_name
    end

    -- Function to detect project formatter preference
    local function get_formatters_for_ft(ft)
      local formatters = {}
      local project_root = vim.fn.getcwd()

      -- Check for Prettier config files
      local prettier_configs = {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.js",
        ".prettierrc.cjs",
        "prettier.config.js",
        "prettier.config.cjs",
      }

      local has_prettier_config = false
      for _, config in ipairs(prettier_configs) do
        if vim.fn.filereadable(project_root .. "/" .. config) == 1 then
          has_prettier_config = true
          break
        end
      end

      -- Check package.json for prettier config
      if not has_prettier_config then
        local package_json_path = project_root .. "/package.json"
        if vim.fn.filereadable(package_json_path) == 1 then
          local package_json = vim.fn.readfile(package_json_path)
          local package_content = table.concat(package_json, "\n")
          if package_content:match('"prettier"') then
            has_prettier_config = true
          end
        end
      end

      -- Check for Biome config
      local biome_configs = { "biome.json", "biome.jsonc" }
      local has_biome_config = false
      for _, config in ipairs(biome_configs) do
        if vim.fn.filereadable(project_root .. "/" .. config) == 1 then
          has_biome_config = true
          break
        end
      end

      -- Determine formatter based on project setup
      if ft == "javascript" or ft == "typescript" or ft == "svelte" or ft == "json" then
        if has_prettier_config and vim.fn.executable(find_local_bin("prettier")) == 1 then
          table.insert(formatters, "prettier")
        elseif has_biome_config and vim.fn.executable(find_local_bin("biome")) == 1 then
          table.insert(formatters, "biome")
        end
      end

      if ft == "php" then
        local phpcsfixer_bin = find_local_bin("php-cs-fixer")
        if vim.fn.executable(phpcsfixer_bin) == 1 then
          table.insert(formatters, "php_cs_fixer")
        elseif has_prettier_config and vim.fn.executable(find_local_bin("prettier")) == 1 then
          table.insert(formatters, "prettier") -- Fallback to prettier if configured for PHP
        end
      end

      -- CSS/HTML - prefer prettier if available, otherwise stylelint
      if ft == "css" or ft == "html" then
        if has_prettier_config and vim.fn.executable(find_local_bin("prettier")) == 1 then
          if ft == "css" then
            table.insert(formatters, "stylelint") -- CSS can use both
          end
          table.insert(formatters, "prettier")
        end
      end

      return formatters
    end

    -- Extend formatters_by_ft dynamically as functions (re-evaluate on each format)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.javascript = function()
      return get_formatters_for_ft("javascript")
    end
    opts.formatters_by_ft.typescript = function()
      return get_formatters_for_ft("typescript")
    end
    opts.formatters_by_ft.svelte = function()
      return get_formatters_for_ft("svelte")
    end
    opts.formatters_by_ft.svx = function()
      return get_formatters_for_ft("svelte")
    end
    opts.formatters_by_ft.json = function()
      return get_formatters_for_ft("json")
    end
    opts.formatters_by_ft.css = function()
      return get_formatters_for_ft("css")
    end
    opts.formatters_by_ft.html = function()
      return get_formatters_for_ft("html")
    end
    opts.formatters_by_ft.php = function()
      return get_formatters_for_ft("php")
    end

    -- Extend formatters with your macOS config
    opts.formatters = opts.formatters or {}

    -- Stylelint formatter
    opts.formatters.stylelint = {
      command = find_local_bin("stylelint"),
      args = {
        "--fix",
        "--stdin",
        "--stdin-filename",
        "$FILENAME",
      },
      stdin = true,
    }

    -- Prettier formatter
    opts.formatters.prettier = {
      command = find_local_bin("prettier"),
      args = { "--stdin-filepath", "$FILENAME" },
      stdin = true,
    }

    -- Biome formatter
    opts.formatters.biome = {
      command = find_local_bin("biome"),
      args = { "format", "--stdin-file-path", "$FILENAME" },
      stdin = true,
    }

    -- PHP CS Fixer formatter (fixed to work with file-based formatting)
    opts.formatters.php_cs_fixer = {
      command = find_local_bin("php-cs-fixer"),
      args = function(self, ctx)
        local args = {
          "fix",
          "$FILENAME",
          "--quiet",
          "--no-interaction",
          "--allow-risky=yes",
          "--using-cache=no",
        }

        -- Check for config files with multiple possible names
        local project_root = vim.fn.getcwd()
        local config_files = { ".php-cs-fixer.php", "_php-cs-fixer.php", ".php-cs-fixer.dist.php" }
        for _, config_file in ipairs(config_files) do
          local config_path = project_root .. "/" .. config_file
          if vim.fn.filereadable(config_path) == 1 then
            table.insert(args, "--config=" .. config_path)
            break
          end
        end

        return args
      end,
      stdin = false, -- PHP CS Fixer works better with files
    }

    -- Add stylelint config if found (from macOS)
    local stylelint_config_path = vim.fn.findfile(".stylelintrc.json", vim.fn.getcwd() .. ";")
    if stylelint_config_path ~= "" and vim.fn.filereadable(stylelint_config_path) == 1 then
      table.insert(opts.formatters.stylelint.args, 1, "--config")
      table.insert(opts.formatters.stylelint.args, 2, stylelint_config_path)
    end

    -- Enable format on save for Omarchy
    -- opts.format_on_save = {
    --   timeout_ms = 2000,
    --   lsp_fallback = true,
    -- }

    return opts
  end,
}
