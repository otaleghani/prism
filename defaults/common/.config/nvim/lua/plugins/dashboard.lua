return {
	"folke/snacks.nvim",
	opts = {
		dashboard = {
			preset = {
				-- The ASCII Art Header
				header = [[
# # # # # # # # # # # # # # # # # # # # # #
#                                         #
#  '||''|, '||''|  ||  ('''' '||),,(|,    #
#   ||  ||  ||     ||   `'')  || || ||    #
#   ||..|' .||.   .||. `...' .||    ||.   #
#   ||                                    #
#  .||  # # # # # # # # # # # # # # # # # #
]],
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ section = "startup" },
			},
		},
	},
}
