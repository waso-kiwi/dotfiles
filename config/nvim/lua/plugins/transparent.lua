local function clear_bg()
  local groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "SignColumn",
    "LineNr",
    "CursorLineNr",
    "EndOfBuffer",
    "MsgArea",
    "FloatBorder",
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "TelescopeNormal",
    "TelescopeBorder",
    "WhichKeyFloat",
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  callback = clear_bg,
})

-- Deferred call to catch anything that loads after VimEnter
vim.defer_fn(clear_bg, 100)

return {}
