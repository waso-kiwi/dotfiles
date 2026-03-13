return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#151311',
				base01 = '#151311',
				base02 = '#8b8680',
				base03 = '#8b8680',
				base04 = '#e0dbd3',
				base05 = '#fffcf8',
				base06 = '#fffcf8',
				base07 = '#fffcf8',
				base08 = '#ffa69f',
				base09 = '#ffa69f',
				base0A = '#ebdac2',
				base0B = '#b3ffa5',
				base0C = '#fff5e7',
				base0D = '#ebdac2',
				base0E = '#ffefda',
				base0F = '#ffefda',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#8b8680',
				fg = '#fffcf8',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#ebdac2',
				fg = '#151311',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#8b8680' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#fff5e7', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#ffefda',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#ebdac2',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#ebdac2',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#fff5e7',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#b3ffa5',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#e0dbd3' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#e0dbd3' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#8b8680',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
