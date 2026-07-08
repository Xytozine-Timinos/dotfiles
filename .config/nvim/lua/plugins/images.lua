return {
	{
		"3rd/image.nvim",
		dependencies = { "luarocks.nvim" },
		config = function()
			local group = vim.api.nvim_create_augroup("ImageHoverPreview", { clear = true })
			local preview_win, preview_img

			-- tune this per your terminal/font: lower = shorter preview for the same width
			local cell_aspect = 0.45

			local function close_preview()
				if preview_img then
					preview_img:clear()
					preview_img = nil
				end
				if preview_win and vim.api.nvim_win_is_valid(preview_win) then
					vim.api.nvim_win_close(preview_win, true)
				end
				preview_win = nil
			end

			-- Returns { w = pixel_width, h = pixel_height } or nil
			local function get_image_size(path)
				local out = vim.fn.system({ "identify", "-format", "%w %h", path })
				if vim.v.shell_error ~= 0 then
					return nil
				end
				local w, h = out:match("(%d+)%s+(%d+)")
				if not w or not h then
					return nil
				end
				return { w = tonumber(w), h = tonumber(h) }
			end

			local function show_preview()
				close_preview()

				local cfile = vim.fn.expand("<cfile>")
				if cfile == "" then
					return
				end

				local path = vim.fn.expand(cfile)
				if not path:match("^/") then
					path = vim.fn.expand("%:p:h") .. "/" .. path
				end

				if vim.fn.filereadable(path) == 0 then
					return
				end
				if
					not path:lower():match("%.png$")
					and not path:lower():match("%.jpe?g$")
					and not path:lower():match("%.gif$")
					and not path:lower():match("%.webp$")
				then
					return
				end

				local max_width, max_height = 50, 25 -- cap in terminal cells
				local width, height = 40, 20 -- fallback if `identify` isn't available

				local size = get_image_size(path)
				if size then
					local aspect = (size.h / size.w) * cell_aspect
					width = max_width
					height = math.floor(width * aspect)
					if height > max_height then
						height = max_height
						width = math.floor(height / aspect)
					end
				end

				local buf = vim.api.nvim_create_buf(false, true)
				preview_win = vim.api.nvim_open_win(buf, false, {
					relative = "cursor",
					row = 1,
					col = 0,
					width = width,
					height = height,
					style = "minimal",
					border = "none",
					focusable = false,
				})

				vim.api.nvim_set_option_value("winhighlight", "Normal:Normal,NormalNC:Normal", { win = preview_win })

				preview_img = require("image").from_file(path, {
					window = preview_win,
					buffer = buf,
					x = 0,
					y = 0,
					width = width,
					height = height,
				})
				preview_img:render()
			end

			vim.api.nvim_create_autocmd("CursorHold", {
				group = group,
				callback = show_preview,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" }, {
				group = group,
				callback = close_preview,
			})

			require("image").setup({
				processor = "magick_cli",
				backend = "kitty",
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = true,
						only_render_image_at_cursor = true,
					},
				},
				max_width_window_percentage = 50,
				max_height_window_percentage = 50,
				hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
			})
		end,
	},
}
