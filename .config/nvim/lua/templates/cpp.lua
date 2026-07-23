local M = {}

M.template = [[
#include <iostream>
using namespace std;

int main() {
    cout << "Hello, World!" << endl;
    return 0;
}
]]

function M.insert()
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(M.template, "\n"))
end

function M.ask_and_insert()
	local ans = vim.fn.input("Insert C++ template? [y/N]: ")
	if ans:lower() == "y" then
		M.insert()
	end
end

function M.setup()
	vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
		pattern = { "*.cpp", "*.cc", "*.cxx", "*.hpp", "*.hh" },
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
			if vim.api.nvim_buf_line_count(0) == 1 and lines[1] == "" then
				M.ask_and_insert()
			end
		end,
	})
end

return M
