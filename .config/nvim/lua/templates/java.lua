local M = {}

local function get_template(choice, class_name)
	if choice == "Main function with clrscr()" then
		return string.format(
			[[public class %s {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }

    // Clear terminal screen function
    static void clrscr() {
        System.out.print("\033[H\033[2J");
        System.out.flush();
    }
}]],
			class_name
		)
	elseif choice == "Class" then
		return string.format(
			[[public class %s {
    public %s() {
        // Constructor
    }
}]],
			class_name,
			class_name
		)
	elseif choice == "Interface" then
		return string.format(
			[[public interface %s {

}]],
			class_name
		)
	elseif choice == "Enum" then
		return string.format(
			[[public enum %s {
    // Enum constants here
}]],
			class_name
		)
	elseif choice == "Main method only" then
		return [[
public static void main(String[] args) {
    System.out.println("Hello, World!");
}]]
	end
end

function M.insert(template)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, "\n"))
end

function M.ask_and_insert()
	local filename = vim.fn.expand("%:t:r")
	if filename == "" then
		filename = "Main"
	end

	if filename == "Main" then
		local template = get_template("Main function with clrscr()", filename)
		vim.schedule(function()
			M.insert(template)
		end)
		return
	end

	local options = {
		"Main function with clrscr()",
		"Class",
		"Interface",
		"Enum",
		"Main method only",
	}

	vim.ui.select(options, {
		prompt = "Select a Java template to insert:",
	}, function(choice)
		if choice then
			local template = get_template(choice, filename)
			vim.schedule(function()
				M.insert(template)
			end)
		end
	end)
end

function M.setup()
	vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
		pattern = "*.java",
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
			if vim.api.nvim_buf_line_count(0) == 1 and lines[1] == "" then
				vim.schedule(function()
					M.ask_and_insert()
				end)
			end
		end,
	})
end

return M
