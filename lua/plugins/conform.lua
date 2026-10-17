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

    -- Project-local html-beautify first, then one on PATH
    local function find_html_beautify()
      local node_bin = vim.fn.getcwd() .. "/node_modules/.bin/html-beautify"
      return vim.fn.executable(node_bin) == 1 and node_bin or "html-beautify"
    end

    -- A PHP file is a template when anything but whitespace follows a closing `?>`
    local function is_php_template(bufnr)
      local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
      return text:find("%?>%s*%S") ~= nil
    end

    -- Function to detect project formatter preference
    local function get_formatters_for_ft(ft, bufnr)
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
        local is_template = is_php_template(bufnr or 0)

        -- Format the HTML in PHP templates first (opt-in per project via .jsbeautifyrc)
        if
          is_template
          and vim.fn.filereadable(project_root .. "/.jsbeautifyrc") == 1
          and vim.fn.executable(find_html_beautify()) == 1
        then
          table.insert(formatters, "html_beautify")
        end

        local phpcsfixer_bin = find_local_bin("php-cs-fixer")
        if vim.fn.executable(phpcsfixer_bin) == 1 then
          -- php-cs-fixer can't indent PHP blocks embedded in HTML, so templates skip its
          -- statement_indentation and php_block_indent re-indents each block instead
          table.insert(formatters, is_template and "php_cs_fixer_template" or "php_cs_fixer")
          if is_template then
            table.insert(formatters, "php_block_indent")
          end
        elseif has_prettier_config and vim.fn.executable(find_local_bin("prettier")) == 1 then
          table.insert(formatters, "prettier") -- Fallback to prettier if configured for PHP
        end
      end

      -- CSS/HTML formatting
      if ft == "css" or ft == "html" then
        -- Check for stylelint config
        local stylelint_configs = {
          ".stylelintrc",
          ".stylelintrc.json",
          ".stylelintrc.yml",
          ".stylelintrc.yaml",
          ".stylelintrc.js",
          ".stylelintrc.cjs",
          "stylelint.config.js",
          "stylelint.config.cjs",
          "stylelint.config.mjs",
        }
        local has_stylelint_config = false
        for _, config in ipairs(stylelint_configs) do
          if vim.fn.filereadable(project_root .. "/" .. config) == 1 then
            has_stylelint_config = true
            break
          end
        end

        if ft == "css" and has_stylelint_config then
          -- When stylelint config exists, use stylelint only for CSS
          local stylelint_bin = find_local_bin("stylelint")
          if vim.fn.executable(stylelint_bin) == 1 then
            table.insert(formatters, "stylelint")
          end
        elseif has_prettier_config and vim.fn.executable(find_local_bin("prettier")) == 1 then
          if ft == "css" then
            table.insert(formatters, "stylelint") -- CSS can use both
          end
          table.insert(formatters, "prettier")
        end
      end

      local oxfmt_fts = {
        javascript = true,
        typescript = true,
        svelte = true,
        json = true,
        css = true,
        html = true,
      }
      if #formatters == 0 and oxfmt_fts[ft] then
        local local_bin = project_root .. "/node_modules/.bin/oxfmt"
        local bin = vim.fn.executable(local_bin) == 1 and local_bin or "oxfmt"
        if vim.fn.executable(bin) == 1 then
          table.insert(formatters, "oxfmt")
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
    opts.formatters_by_ft.php = function(bufnr)
      return get_formatters_for_ft("php", bufnr)
    end
    opts.formatters_by_ft.javascriptreact = get_formatters_for_ft("javascript")
    opts.formatters_by_ft.typescriptreact = get_formatters_for_ft("typescript")
    opts.formatters_by_ft.markdown = (function()
      local local_bin = vim.fn.getcwd() .. "/node_modules/.bin/oxfmt"
      local bin = vim.fn.executable(local_bin) == 1 and local_bin or "oxfmt"
      return vim.fn.executable(bin) == 1 and { "oxfmt" } or {}
    end)()

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

    -- Check for config files with multiple possible names
    local function find_php_cs_fixer_config()
      local project_root = vim.fn.getcwd()
      local config_files = { ".php-cs-fixer.php", "_php-cs-fixer.php", ".php-cs-fixer.dist.php" }
      for _, config_file in ipairs(config_files) do
        local config_path = project_root .. "/" .. config_file
        if vim.fn.filereadable(config_path) == 1 then
          return config_path
        end
      end
    end

    local php_cs_fixer_args = {
      "fix",
      "$FILENAME",
      "--quiet",
      "--no-interaction",
      "--allow-risky=yes",
      "--using-cache=no",
    }

    -- PHP CS Fixer formatter (fixed to work with file-based formatting)
    opts.formatters.php_cs_fixer = {
      command = find_local_bin("php-cs-fixer"),
      args = function()
        local args = vim.deepcopy(php_cs_fixer_args)
        local config_path = find_php_cs_fixer_config()
        if config_path then
          table.insert(args, "--config=" .. config_path)
        end
        return args
      end,
      stdin = false, -- PHP CS Fixer works better with files
    }

    -- php-cs-fixer for PHP templates: the project config with statement_indentation off, since that
    -- rule indents statements inside inline-HTML blocks from an unpredictable base column
    opts.formatters.php_cs_fixer_template = {
      command = find_local_bin("php-cs-fixer"),
      args = function()
        local args = vim.deepcopy(php_cs_fixer_args)
        local config_path = find_php_cs_fixer_config()
        if not config_path then
          table.insert(args, '--rules={"@PSR12":true,"statement_indentation":false}')
          return args
        end
        local quoted = "'" .. config_path:gsub("\\", "\\\\"):gsub("'", "\\'") .. "'"
        local wrapper = vim.fn.stdpath("cache") .. "/php-cs-fixer-template.php"
        vim.fn.writefile({
          "<?php",
          "$config = require " .. quoted .. ";",
          "return $config->setRules(array_merge($config->getRules(), ['statement_indentation' => false]));",
        }, wrapper)
        table.insert(args, "--config=" .. wrapper)
        return args
      end,
      stdin = false,
    }

    -- html-beautify with the project's .jsbeautifyrc
    opts.formatters.html_beautify = {
      command = function()
        return find_html_beautify()
      end,
      args = function()
        return { "--config", vim.fn.getcwd() .. "/.jsbeautifyrc", "--file", "-" }
      end,
      stdin = true,
    }

    -- Calls fn(open, close, indent) for each multi-line PHP block in a template, i.e. a `<?php`
    -- and a `?>` each alone on their line. Heredocs are skipped since re-indenting would change
    -- their contents.
    local function each_php_block(lines, fn)
      local i = 1
      while i <= #lines do
        local indent = lines[i]:match("^(%s*)<%?php%s*$")
        if indent then
          local close
          for j = i + 1, #lines do
            if lines[j]:match("^%s*%?>%s*$") then
              close = j
              break
            end
            if lines[j]:find("<%?") or lines[j]:find("?>", 1, true) or lines[j]:find("<<<", 1, true) then
              break
            end
          end
          if close then
            fn(i, close, indent)
            i = close
          end
        end
        i = i + 1
      end
    end

    local php_block_openers = { "if", "elseif", "else", "foreach", "for", "while", "switch" }
    local php_block_closers = { "elseif", "else", "endif", "endforeach", "endfor", "endwhile", "endswitch" }

    -- Whether a trimmed PHP line closes a level (outdenting itself) and opens one (indenting the
    -- lines after it). Alternative syntax like `if (...) :` ... `endif;` counts as a level.
    local function php_line_levels(line)
      local word = line:match("^%a+")
      local closes = line:match("^[}%)%]]") or vim.tbl_contains(php_block_closers, word)
      local opens = line:match("[{%(%[]$") or (line:match(":$") and vim.tbl_contains(php_block_openers, word))
      return closes, opens
    end

    -- Re-indent block contents by nesting depth, one level under the `<?php` line (a column-0
    -- `<?php` keeps its statements at column 0), and align `?>` with the tag
    opts.formatters.php_block_indent = {
      format = function(_, ctx, lines, callback)
        local out = vim.deepcopy(lines)
        local step = string.rep(" ", ctx.shiftwidth)
        each_php_block(out, function(open, close, indent)
          local base = indent == "" and "" or indent .. step
          local depth = 0
          for k = open + 1, close - 1 do
            local line = vim.trim(out[k])
            if line == "" then
              out[k] = ""
            else
              local closes, opens = php_line_levels(line)
              if closes then
                depth = math.max(depth - 1, 0)
              end
              -- Continuation lines of a /* */ or docblock comment sit one space in
              local pad = line:match("^%*") and " " or ""
              out[k] = base .. step:rep(depth) .. pad .. line
              if opens then
                depth = depth + 1
              end
            end
          end
          out[close] = indent .. "?>"
        end)
        callback(nil, out)
      end,
    }

    -- Oxfmt formatter
    opts.formatters.oxfmt = {
      command = function()
        local local_bin = vim.fn.getcwd() .. "/node_modules/.bin/oxfmt"
        if vim.fn.executable(local_bin) == 1 then
          return local_bin
        end
        return "oxfmt"
      end,
      args = { "--stdin-filepath", "$FILENAME" },
      stdin = true,
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
