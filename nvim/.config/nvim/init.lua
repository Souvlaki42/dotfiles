kset = vim.keymap.set

vim.filetype.add({
  pattern = {},
  filename = {},
  content = function(_, content)
    local first_line = content[1]
    if first_line and first_line:match("^#!.*bash") then
      return "sh"
    end
    return nil
  end,
})

require("core.options")
require("core.keybinds")
require("core.lazy")
