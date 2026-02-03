return {
  cmd = { "lua-languagee-server" },

  filetypes = { "lua" },

  root_markers = {
    ".git",
    { ".luarc.json", ".luarc.jsonc" },
  },

  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
}
