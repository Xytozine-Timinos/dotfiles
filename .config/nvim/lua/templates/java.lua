local M = {}

function M.get_template()
	local filename = vim.fn.expand("%:t:r")
	return string.format(
[[public class %s {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
//Clear terminal screen function
static void clrscr() {
    System.out.print("\033[H\033[2J");
    System.out.flush();
    }
}]],
		filename,
		filename
	)
end

function M.insert()
	local template = M.get_template()
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, "\n"))
end

function M.ask_and_insert()
	local ans = vim.fn.input("Insert Java template? [y/N]: ")
	if ans:lower() == "y" then
		M.insert()
	end
end

function M.setup()
	vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
		pattern = "*.java",
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
			if vim.api.nvim_buf_line_count(0) == 1 and lines[1] == "" then
				M.ask_and_insert()
			end
		end,
	})
end

return M
