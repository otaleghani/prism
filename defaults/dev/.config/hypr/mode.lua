-- Profile-specific bindings.
local main_mod = require("programs").main_mod

hl.bind(main_mod .. " + CONTROL + 1", hl.dsp.exec_cmd("prism-tui prism-project-open"), { description = "prism-tui prism-project-open" })
hl.bind(main_mod .. " + CONTROL + 2", hl.dsp.exec_cmd("prism-tui prism-project-new"), { description = "prism-tui prism-project-new" })
hl.bind(main_mod .. " + CONTROL + 3", hl.dsp.exec_cmd("prism-tui prism-api-test"), { description = "prism-tui prism-api-test" })
