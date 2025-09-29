return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    -- Custom function to parse Emmet-like syntax
    local function parse_emmet_tags(input)
      -- Handle nested tags like "div.container>section>article"
      local tags = {}
      for tag in input:gmatch("[^>]+") do
        -- Extract tag name and classes/ids
        local tag_name = tag:match("([^.#]+)")
        local classes = {}
        local id = tag:match("#([^.#]+)")

        for class in tag:gmatch("%.([^.#]+)") do
          table.insert(classes, class)
        end

        -- Build the opening tag
        local opening = "<" .. tag_name
        if id then
          opening = opening .. ' id="' .. id .. '"'
        end
        if #classes > 0 then
          opening = opening .. ' class="' .. table.concat(classes, " ") .. '"'
        end
        opening = opening .. ">"

        table.insert(tags, {
          name = tag_name,
          opening = opening,
          closing = "</" .. tag_name .. ">",
        })
      end
      return tags
    end

    require("nvim-surround").setup({
      keymaps = {
        visual = "<leader>w",
      },
      surrounds = {
        ["h"] = { -- Use 'h' for HTML
          add = function()
            local input = require("nvim-surround.config").get_input("HTML (e.g., div.container>section): ")
            if input == "" then
              return nil
            end

            local tags = parse_emmet_tags(input)
            if #tags == 0 then
              return nil
            end

            local openings = {}
            local closings = {}

            for _, tag in ipairs(tags) do
              table.insert(openings, tag.opening)
            end

            for i = #tags, 1, -1 do
              table.insert(closings, tags[i].closing)
            end

            return { openings, closings }
          end,
        },
      },
    })
  end,
}
