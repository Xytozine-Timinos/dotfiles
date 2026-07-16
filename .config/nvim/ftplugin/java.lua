local jdtls = require("jdtls")

local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
local jdtls_path = mason_path .. "/jdtls"
local java_debug_path = mason_path .. "/java-debug-adapter"
local java_test_path = mason_path .. "/java-test"

local bundles = {
	vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n"))

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- Safely get the launcher jar
local launcher_jar = vim.split(vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"), "\n")[1]

local config = {
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-jar",
		launcher_jar,
		"-configuration",
		jdtls_path .. "/config_linux",
		"-data",
		workspace_dir,
	},
	-- Added fallback to current working directory so single-folder projects work
	root_dir = require("jdtls.setup").find_root({ ".git", "pom.xml", "build.gradle" }) or vim.fn.getcwd(),
	settings = {
		java = {
			autobuild = { enabled = true }, -- Forces automatic compilation/indexing on save
			signatureHelp = { enabled = true },
			contentProvider = { preferred = "fernflower" },
			configuration = {
				updateBuildConfiguration = "interactive",
			},
		},
	},
	init_options = {
		bundles = bundles,
	},
}

jdtls.start_or_attach(config)
jdtls.setup_dap({ hotcodereplace = "auto" })
