-- Pilih language server TypeScript berdasarkan versi typescript di project:
--   TS >= 7  -> server native (tsc --lsp) milik project
--   TS <= 6  -> ts_ls (dibutuhkan Vue/Svelte/Astro yang masih bergantung TS 6)

local function find_root(bufnr)
  return vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
end

-- Baca major version dari node_modules/typescript/package.json
local function ts_major(root)
  if not root then return nil end
  local pkg_path = root .. "/node_modules/typescript/package.json"
  if not vim.uv.fs_stat(pkg_path) then return nil end
  local ok, pkg = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg_path), "\n"))
  if not ok or not pkg.version then return nil end
  return tonumber(pkg.version:match("^(%d+)"))
end

local filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

-- Server native TypeScript 7
vim.lsp.config("ts7", {
  filetypes = filetypes,
  root_dir = function(bufnr, on_dir)
    local root = find_root(bufnr)
    local major = ts_major(root)
    if major and major >= 7 then on_dir(root) end
  end,
  cmd = function(dispatchers, config)
    local bin = config.root_dir .. "/node_modules/.bin/tsc"
    return vim.lsp.rpc.start({ bin, "--lsp", "--stdio" }, dispatchers, { cwd = config.root_dir })
  end,
})
vim.lsp.enable("ts7")

-- ts_ls hanya untuk project dengan TS <= 6 atau tanpa typescript
vim.lsp.config("ts_ls", {
  root_dir = function(bufnr, on_dir)
    local root = find_root(bufnr)
    local major = ts_major(root)
    if not major or major < 7 then on_dir(root) end
  end,
})
