return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- Helper function to find local binaries (from your macOS config)
    local function find_local_bin(bin_name)
      if bin_name == "stylelint" then
        local project_root = vim.fn.getcwd()
        local node_bin = project_root .. "/node_modules/.bin/" .. bin_name
        if vim.fn.executable(node_bin) == 1 then
          return node_bin
        end
      end
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/" .. bin_name
      if vim.fn.executable(mason_bin) == 1 then
        return mason_bin
      end
      local project_root = vim.fn.getcwd()
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

    -- Extend formatters_by_ft dynamically
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.javascript = get_formatters_for_ft("javascript")
    opts.formatters_by_ft.typescript = get_formatters_for_ft("typescript")
    opts.formatters_by_ft.svelte = get_formatters_for_ft("svelte")
    opts.formatters_by_ft.json = get_formatters_for_ft("json")
    opts.formatters_by_ft.css = get_formatters_for_ft("css")
    opts.formatters_by_ft.html = get_formatters_for_ft("html")

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

    -- Add stylelint config if found (from macOS)
    local config_path = vim.fn.findfile(".stylelintrc.json", vim.fn.getcwd() .. ";")
    if config_path ~= "" and vim.fn.filereadable(config_path) == 1 then
      table.insert(opts.formatters.stylelint.args, 1, "--config")
      table.insert(opts.formatters.stylelint.args, 2, config_path)
    end

    -- Since this is for Omarchy (not LazyVim), we need to ensure format_on_save is enabled
    -- Commented out since LazyVim formats on save automatically
    -- opts.format_on_save = opts.format_on_save or {
    --   timeout_ms = 500,
    --   lsp_fallback = true,
    -- }

    return opts
  end,
}
