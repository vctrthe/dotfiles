-- Accessing through SSH: use OSC 52 for copying to SSH Client clipboard,
-- and paste from internal registries (i.e. Terminal.app, Terminal.app can't response to paste action from OSC 52)
-- Set g:clipboard also avoid Neovim from sending terminal query (+q4D73).
if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52 (SSH)",
    copy  = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
