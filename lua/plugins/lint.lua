return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")
    -- Helper function to find local binaries (from macOS config)
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

    -- Dynamically determine linters based on available binaries (adapted from macOS)
    local function get_linters_for_ft(ft)
      local linters = {}
      local eslint_bin = find_local_bin("eslint")
      local biome_bin = find_local_bin("biome")
      if ft == "javascript" or ft == "typescript" or ft == "svelte" then
        if vim.fn.executable(eslint_bin) == 1 then
          table.insert(linters, "eslint_d")
        elseif vim.fn.executable(biome_bin) == 1 then
          table.insert(linters, "biome")
        end
      end
      if ft == "php" then
        local phpcs_bin = find_local_bin("phpcs")
        if vim.fn.executable(phpcs_bin) == 1 then
          table.insert(linters, "phpcs")
        end
        local phpstan_bin = find_local_bin("phpstan")
        if vim.fn.executable(phpstan_bin) == 1 then
          table.insert(linters, "phpstan")
        end
      end
      if ft == "svelte" or ft == "css" then
        table.insert(linters, "stylelint")
      end
      if ft == "html" then
        -- Only add htmlhint if .htmlhintrc exists in project root
        local htmlhint_bin = find_local_bin("htmlhint")
        local htmlhintrc_path = vim.fn.getcwd() .. "/.htmlhintrc"
        if vim.fn.executable(htmlhint_bin) == 1 and vim.fn.filereadable(htmlhintrc_path) == 1 then
          table.insert(linters, "htmlhint")
        end
      end
      return linters
    end

    lint.linters_by_ft = {
      javascript = get_linters_for_ft("javascript"),
      typescript = get_linters_for_ft("typescript"),
      svelte = get_linters_for_ft("svelte"),
      html = get_linters_for_ft("html"),
      css = get_linters_for_ft("css"),
      php = get_linters_for_ft("php"),
    }

    -- Configure linters (from macOS)
    lint.linters.eslint_d.cmd = find_local_bin("eslint_d")
    lint.linters.biome = {
      cmd = find_local_bin("biome"),
      name = "biome",
      args = { "lint", "--stdin-file-path", vim.fn.expand("%:p") },
      stdin = true,
      stream = "stdout",
      parser = function(output, bufnr)
        local diagnostics = {}
        if output == "" then
          return diagnostics
        end
        local ok, decoded = pcall(vim.json.decode, output)
        if not ok or not decoded.diagnostics then
          return diagnostics
        end
        for _, diag in ipairs(decoded.diagnostics) do
          table.insert(diagnostics, {
            bufnr = bufnr,
            lnum = (diag.location.line or 1) - 1,
            col = diag.location.column or 0,
            end_lnum = (diag.location.line or 1) - 1,
            end_col = diag.location.column or 0,
            message = diag.message or "Unknown Biome error",
            severity = vim.diagnostic.severity[diag.severity and diag.severity:upper() or "ERROR"]
              or vim.diagnostic.severity.ERROR,
            source = "biome",
          })
        end
        return diagnostics
      end,
    }
    lint.linters.htmlhint.cmd = find_local_bin("htmlhint")
    lint.linters.stylelint.cmd = find_local_bin("stylelint")
    lint.linters.stylelint.args = {
      "--formatter",
      "json",
      "--stdin",
      "--stdin-filename",
      function()
        return vim.fn.expand("%:p")
      end,
    }
    lint.linters.phpcs = {
      cmd = find_local_bin("phpcs"),
      name = "phpcs",
      stdin = true,
      args = {
        "--standard=phpcs.xml",
        "--report=json",
        "--stdin-path=%filepath",
        "-",
      },
      ignore_exitcode = true,
      parser = function(output, bufnr)
        local diagnostics = {}
        if output == "" then
          return diagnostics
        end
        local ok, result = pcall(vim.json.decode, output)
        if not ok or not result.files then
          return diagnostics
        end
        for _, file in pairs(result.files) do
          for _, message in ipairs(file.messages or {}) do
            table.insert(diagnostics, {
              bufnr = bufnr,
              lnum = (message.line or 1) - 1,
              col = (message.column or 1) - 1,
              end_lnum = (message.line or 1) - 1,
              end_col = (message.column or 1),
              message = message.message,
              severity = vim.diagnostic.severity[message.type:upper()] or vim.diagnostic.severity.ERROR,
              source = "phpcs",
            })
          end
        end
        return diagnostics
      end,
    }
    lint.linters.phpstan = {
      cmd = find_local_bin("phpstan"),
      name = "phpstan",
      stdin = false,
      args = {
        "analyse",
        "--error-format=json",
        "--no-progress",
        "%filepath",
      },
      ignore_exitcode = true,
      parser = function(output, bufnr)
        local diagnostics = {}
        if output == "" then
          return diagnostics
        end
        local ok, result = pcall(vim.json.decode, output)
        if not ok or not result.files then
          return diagnostics
        end
        for _, file in pairs(result.files) do
          for _, message in ipairs(file.messages or {}) do
            table.insert(diagnostics, {
              bufnr = bufnr,
              lnum = (message.line or 1) - 1,
              col = (message.column or 1) - 1,
              end_lnum = (message.line or 1) - 1,
              end_col = (message.column or 1),
              message = message.message,
              severity = vim.diagnostic.severity[message.type:upper()] or vim.diagnostic.severity.ERROR,
              source = "phpstan",
            })
          end
        end
        return diagnostics
      end,
    }

    -- Add stylelint config if found (from macOS)
    local config_path = vim.fn.findfile(".stylelintrc.json", vim.fn.getcwd() .. ";")
    if config_path ~= "" and vim.fn.filereadable(config_path) == 1 then
      table.insert(lint.linters.stylelint.args, "--config")
      table.insert(lint.linters.stylelint.args, config_path)
      -- else
      --   vim.notify("Stylelint: No valid .stylelintrc.json found", vim.log.levels.WARN)
    end

    -- Custom parser for Stylelint JSON output (from macOS)
    lint.linters.stylelint.parser = function(output, bufnr)
      local diagnostics = {}
      if output == "" then
        return diagnostics
      end
      local ok, decoded = pcall(vim.json.decode, output)
      if not ok or not decoded then
        return diagnostics
      end
      for _, result in ipairs(decoded) do
        if result.warnings and #result.warnings > 0 then
          for _, warning in ipairs(result.warnings) do
            table.insert(diagnostics, {
              bufnr = bufnr,
              lnum = (warning.line or 1) - 1,
              col = (warning.column or 1) - 1,
              end_lnum = (warning.line or 1) - 1,
              end_col = warning.column or 1,
              message = warning.text or "Unknown Stylelint error",
              severity = vim.diagnostic.severity[warning.severity and warning.severity:upper() or "ERROR"]
                or vim.diagnostic.severity.ERROR,
              source = "stylelint",
            })
          end
        end
      end
      return diagnostics
    end

    -- Trigger linting (from macOS, aligns with LazyVim defaults)
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      callback = function()
        local ft = vim.bo.filetype
        local linters = get_linters_for_ft(ft)
        for _, linter in ipairs(linters) do
          local cmd = lint.linters[linter].cmd
          if cmd and vim.fn.executable(cmd) == 1 then
            lint.try_lint(linter)
          else
            vim.notify("Linter " .. linter .. " not executable: " .. cmd, vim.log.levels.ERROR)
          end
        end
      end,
    })
  end,
}
