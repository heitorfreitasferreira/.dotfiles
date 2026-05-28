vim.pack.add({ "https://github.com/mfussenegger/nvim-jdtls" })

local function java_compile()
	if vim.fn.executable("mvn") ~= 1 then
		vim.notify("mvn executable not found", vim.log.levels.ERROR)
		return
	end

	local dir = vim.fn.expand("%:p:h")
	local pom = vim.fn.findfile("pom.xml", dir .. ";")
	if pom == "" then
		vim.notify("No pom.xml found for this Java file", vim.log.levels.WARN)
		return
	end

	vim.notify("Running mvn compile...", vim.log.levels.INFO)
	vim.system({ "mvn", "-f", pom, "compile", "-q" }, { text = true }, function(result)
		vim.schedule(function()
			if result.code == 0 then
				vim.notify("mvn compile completed", vim.log.levels.INFO)
				return
			end

			local stderr = result.stderr or ""
			local stdout = result.stdout or ""
			local output = stderr ~= "" and stderr or stdout
			vim.notify("mvn compile failed:\n" .. output, vim.log.levels.ERROR)
		end)
	end)
end

vim.api.nvim_create_user_command("JavaCompile", java_compile, { desc = "Run mvn compile for the current Java project" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function(args)
		local jdtls = require("jdtls")
		local root_markers = { "gradlew", "mvnw", "pom.xml", "build.gradle", "settings.gradle", ".git" }
		local root_dir = vim.fs.root(args.buf, root_markers)

		if not root_dir then
			vim.notify("Could not find Java project root", vim.log.levels.WARN)
			return
		end

		local project_name = vim.fs.basename(root_dir)
		local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. project_name
		local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
		local bundles = {}

		vim.list_extend(
			bundles,
			vim.split(
				vim.fn.glob(mason_path .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"),
				"\n",
				{ trimempty = true }
			)
		)
		vim.list_extend(
			bundles,
			vim.split(vim.fn.glob(mason_path .. "/java-test/extension/server/*.jar"), "\n", { trimempty = true })
		)

		local cmd = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
		if vim.fn.executable(cmd) ~= 1 then
			cmd = "jdtls"
		end

		jdtls.start_or_attach({
			cmd = { cmd, "-data", workspace_dir },
			root_dir = root_dir,
			capabilities = require("blink.cmp").get_lsp_capabilities(),
			settings = {
				java = {
					configuration = {
						updateBuildConfiguration = "interactive",
					},
					format = {
						enabled = false,
					},
				},
			},
			init_options = {
				bundles = bundles,
			},
			on_attach = function(_, bufnr)
				jdtls.setup_dap({ hotcodereplace = "auto" })
				require("jdtls.setup").add_commands()

				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
				end

				map("<leader>jo", jdtls.organize_imports, "Java: Organize Imports")
				map("<leader>jc", "<cmd>JavaCompile<cr>", "Java: Compile Project")
				map("<leader>jv", jdtls.extract_variable, "Java: Extract Variable")
				map("<leader>jm", jdtls.extract_method, "Java: Extract Method")
				map("<leader>jt", jdtls.test_nearest_method, "Java: Test Method")
				map("<leader>jT", jdtls.test_class, "Java: Test Class")
			end,
		})
	end,
})
