return {
    cmd = { "zls" },

    filetypes = { "zig", "zir" },

    root_markers = {
      "zls.json",
      "build.zig",
      "build.zig.zon",
      ".git",
    },

    settings = {
      zls = {
        semantic_tokens = "partial",
      },
    },
  }

