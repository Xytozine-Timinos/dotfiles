local jdtls = require("jdtls")

local mason_registry = require("mason-registry")
local jdtls_pkg = mason_registry.get_package("jdtls")
local jdtls_path = jdtls_pkg:get_install_path()

local java_debug_pkg = mason_registry.get_package("java-debug-adapter")
local java_debug_path = java_debug_pkg:get_install_path()

local java_test_pkg = mason_registry.get_package("java-test")
local java_test_path = java_test_pkg:get_install_path()

local bundles = {
	vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n"))

local root_dir = require("jdtls.setup").find_root({ "pom.xml", "build.gradle", ".git" })
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

local config = {
	cmd = { jdtls_path .. "/bin/jdtls", "-data", workspace_dir },
	root_dir = root_dir,
	init_options = {
		bundles = bundles,
	},
	on_attach = function(client, bufnr)
		jdtls.setup_dap({ hotcodereplace = "auto" })
		require("jdtls.dap").setup_dap_main_class_configs()

		vim.keymap.set("n", "<leader>df", jdtls.test_class, { buffer = bufnr, desc = "Debug: Test Class" })
		vim.keymap.set("n", "<leader>dn", jdtls.test_nearest_method, { buffer = bufnr, desc = "Debug: Test Nearest" })
	end,
}

jdtls.start_or_attach(config)
