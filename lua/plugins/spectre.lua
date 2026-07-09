return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Spectre",
  keys = {
    {
      "<leader>Sr",
      function()
        require("spectre").toggle()
      end,
      desc = "Toggle Spectre (search/replace)",
    },
    {
      "<leader>Sw",
      function()
        require("spectre").open_visual({ select_word = true })
      end,
      desc = "Search current word",
    },
    {
      "<leader>Sw",
      function()
        require("spectre").open_visual()
      end,
      mode = "v",
      desc = "Search current selection",
    },
    {
      "<leader>Sp",
      function()
        require("spectre").open_file_search({ select_word = true })
      end,
      desc = "Search/replace in current file",
    },
  },
}
