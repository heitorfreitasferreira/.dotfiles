local models = {
	{ name = "GPT-5.5", id = "openai/gpt-5.5" },
	{ name = "DeepSeek V4 Flash Free", id = "opencode/deepseek-v4-flash-free" },
}

local function find_model(id)
	for index, model in ipairs(models) do
		if model.id == id then
			return model, index
		end
	end
end

local function set_model(model)
	vim.g.codecompanion_opencode_model = model.id
	vim.g.codecompanion_opencode_model_name = model.name
end

local function current_model()
	local model = find_model(vim.g.codecompanion_opencode_model) or models[1]
	set_model(model)
	return model
end

local function split_model_id(model_id)
	local provider_id, model = model_id:match("^([^/]+)/(.+)$")
	return provider_id, model
end

local function encode_query_value(value)
	if vim.uri_encode then
		return vim.uri_encode(value)
	end

	return tostring(value):gsub("([^%w%-_%.~])", function(char)
		return string.format("%%%02X", string.byte(char))
	end)
end

local function opencode_server_url()
	return (os.getenv("OPENCODE_SERVER_URL") or "http://127.0.0.1:4096"):gsub("/+$", "")
end

local function opencode_command()
	local command = vim.fn.exepath("opencode")
	if command == "" then
		command = vim.fn.expand("~/.opencode/bin/opencode")
	end

	return command
end

local function opencode_server_address()
	local url = opencode_server_url()
	local host, port = url:match("^https?://([^:/]+):(%d+)$")
	return host or "127.0.0.1", port or "4096"
end

local function opencode_headers()
	local headers = {
		["Content-Type"] = "application/json",
	}

	local password = os.getenv("OPENCODE_SERVER_PASSWORD")
	if password and password ~= "" and vim.base64 and vim.base64.encode then
		local username = os.getenv("OPENCODE_SERVER_USERNAME") or "opencode"
		headers.Authorization = "Basic " .. vim.base64.encode(username .. ":" .. password)
	end

	return headers
end

local function stringify_content(content)
	if type(content) == "string" then
		return content
	end

	return vim.inspect(content)
end

local function build_opencode_prompt(messages)
	local system = {}
	local prompt = {}

	for _, message in ipairs(messages or {}) do
		local content = stringify_content(message.content)
		if message.role == "system" then
			table.insert(system, content)
		else
			local role = message.role or "user"
			table.insert(prompt, string.format("<%s>\n%s\n</%s>", role, content, role))
		end
	end

	return table.concat(system, "\n\n"), table.concat(prompt, "\n\n")
end

local function decode_json_response(response)
	local body = type(response) == "table" and response.body or response
	if not body or body == "" then
		return nil, "empty response from OpenCode server"
	end

	local ok, json = pcall(vim.json.decode, body, { luanil = { object = true } })
	if not ok then
		return nil, "invalid JSON response from OpenCode server"
	end

	return json
end

local function extract_text(response)
	local json, err = decode_json_response(response)
	if not json then
		return nil, err
	end

	if json.info and json.info.error then
		local error_data = json.info.error.data or {}
		return nil, error_data.message or json.info.error.name or "OpenCode returned an error"
	end

	local chunks = {}
	for _, part in ipairs(json.parts or {}) do
		if part.type == "text" and part.text and part.text ~= "" then
			table.insert(chunks, part.text)
		end
	end

	if #chunks == 0 then
		return nil, "OpenCode returned no text parts"
	end

	return table.concat(chunks, "\n")
end

local opencode_server_callbacks = {}
local opencode_server_starting = false

local function check_opencode_server(callback)
	local Curl = require("plenary.curl")
	Curl.get(opencode_server_url() .. "/global/health", {
		callback = function(response)
			vim.schedule(function()
				callback(response and response.status and response.status < 400)
			end)
		end,
		headers = opencode_headers(),
		on_error = function()
			vim.schedule(function()
				callback(false)
			end)
		end,
		timeout = 1000,
	})
end

local function flush_opencode_server_callbacks(ok)
	local callbacks = opencode_server_callbacks
	opencode_server_callbacks = {}
	opencode_server_starting = false

	for _, callback in ipairs(callbacks) do
		callback(ok)
	end
end

local function wait_for_opencode_server(attempt)
	attempt = attempt or 1

	check_opencode_server(function(ok)
		if ok then
			return flush_opencode_server_callbacks(true)
		end

		if attempt >= 30 then
			vim.notify("OpenCode server nao ficou pronto em http://127.0.0.1:4096", vim.log.levels.ERROR)
			return flush_opencode_server_callbacks(false)
		end

		vim.defer_fn(function()
			wait_for_opencode_server(attempt + 1)
		end, 100)
	end)
end

local function start_opencode_server()
	local host, port = opencode_server_address()
	local command = opencode_command()

	if vim.fn.executable(command) ~= 1 then
		vim.notify("opencode nao encontrado: " .. command, vim.log.levels.ERROR)
		return flush_opencode_server_callbacks(false)
	end

	if host ~= "127.0.0.1" and host ~= "localhost" then
		vim.notify("OPENCODE_SERVER_URL nao e local; inicie o server manualmente: " .. opencode_server_url(), vim.log.levels.ERROR)
		return flush_opencode_server_callbacks(false)
	end

	local ok, err = pcall(vim.system, { command, "serve", "--hostname", host, "--port", port }, { detach = true })
	if not ok then
		vim.notify("Falha ao iniciar opencode serve: " .. tostring(err), vim.log.levels.ERROR)
		return flush_opencode_server_callbacks(false)
	end

	wait_for_opencode_server()
end

local function ensure_opencode_server(callback)
	table.insert(opencode_server_callbacks, callback)

	if opencode_server_starting then
		return
	end

	opencode_server_starting = true
	check_opencode_server(function(ok)
		if ok then
			return flush_opencode_server_callbacks(true)
		end

		start_opencode_server()
	end)
end

local function prompt_codecompanion_inline(placement, range)
	ensure_opencode_server(function(ok)
		if not ok then
			return
		end

		local context = require("codecompanion.utils.context").get(vim.api.nvim_get_current_buf(), { range = range })
		vim.ui.input({ prompt = "CodeCompanion Inline (" .. current_model().name .. ") " }, function(input)
			if not input or vim.trim(input) == "" then
				return
			end

			local inline = require("codecompanion.interactions.inline").new({
				buffer_context = context,
				placement = placement,
			})

			if inline then
				inline:prompt(input)
			end
		end)
	end)
end

local function codecompanion_inline()
	prompt_codecompanion_inline("add", 0)
end

local function codecompanion_inline_visual()
	prompt_codecompanion_inline("replace", 1)
end

local function opencode_request(client, payload, actions)
	local Curl = require("plenary.curl")
	local cancelled = false
	local session_job
	local message_job
	local base_url = opencode_server_url()
	local query = "?directory=" .. encode_query_value(vim.fn.getcwd())
	local headers = opencode_headers()

	local function finish_error(message, response)
		vim.schedule(function()
			if cancelled then
				return
			end
			actions.callback({ message = message, stderr = response }, nil)
		end)
	end

	local function finish_success(response)
		vim.schedule(function()
			if cancelled then
				return
			end
			actions.callback(nil, response, client.adapter)
			if actions.done then
				actions.done()
			end
		end)
	end

	session_job = Curl.post(base_url .. "/session" .. query, {
		body = vim.json.encode({ title = "CodeCompanion Inline" }),
		callback = function(session_response)
			if cancelled then
				return
			end

			if not session_response or (session_response.status and session_response.status >= 400) then
				return finish_error("failed to create OpenCode session at " .. base_url, session_response)
			end

			local session, session_err = decode_json_response(session_response)
			if not session or not session.id then
				return finish_error(session_err or "OpenCode session response did not include an id", session_response)
			end

			local system, text = build_opencode_prompt(payload.messages)
			local model_id = current_model().id
			local provider_id, model = split_model_id(model_id)
			local body = {
				model = {
					providerID = provider_id,
					modelID = model,
				},
				parts = {
					{
						type = "text",
						text = text,
					},
				},
				tools = {
					bash = false,
					edit = false,
					task = false,
					todowrite = false,
				},
			}

			if system ~= "" then
				body.system = system
			end

			local message_url = base_url .. "/session/" .. session.id .. "/message" .. query
			message_job = Curl.post(message_url, {
				body = vim.json.encode(body),
				callback = function(message_response)
					if cancelled then
						return
					end

					if not message_response or (message_response.status and message_response.status >= 400) then
						return finish_error("OpenCode message request failed", message_response)
					end

					finish_success(message_response)
				end,
				headers = headers,
				timeout = 300000,
			})
		end,
		headers = headers,
		timeout = 300000,
	})

	return {
		shutdown = function()
			cancelled = true
			if session_job and session_job.shutdown then
				pcall(session_job.shutdown, session_job)
			end
			if message_job and message_job.shutdown then
				pcall(message_job.shutdown, message_job)
			end
		end,
	}
end

local function toggle_model()
	local _, current_index = find_model(current_model().id)
	local next_index = (current_index % #models) + 1
	local model = models[next_index]
	set_model(model)

	local ok, codecompanion = pcall(require, "codecompanion")
	if ok and codecompanion.last_chat then
		local chat = codecompanion.last_chat()
		local is_opencode_chat = chat
			and chat.adapter
			and chat.adapter.name == "opencode"
			and chat.acp_connection
			and chat.acp_connection.session_id

		if is_opencode_chat then
			pcall(function()
				chat:change_model({ model = model.id })
			end)
		end
	end

	vim.notify("Modelo CodeCompanion: " .. model.name .. " (" .. model.id .. ")", vim.log.levels.INFO)
end

vim.pack.add({
	{ src = "https://github.com/olimorris/codecompanion.nvim", version = vim.version.range("^19.0.0") },
	"https://github.com/nvim-lua/plenary.nvim",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

current_model()

require("codecompanion").setup({
	adapters = {
		acp = {
			opencode = function()
				return require("codecompanion.adapters").extend("opencode", {
					commands = {
						default = { opencode_command(), "acp" },
					},
					defaults = {
						timeout = 60000,
						session_config_options = {
							model = function()
								return current_model().id
							end,
						},
					},
				})
			end,
		},
		http = {
			opencode_server = function()
				return {
					name = "opencode_server",
					formatted_name = "OpenCode Server",
					roles = {
						llm = "assistant",
						user = "user",
					},
					opts = {
						request = opencode_request,
						stream = false,
						tools = false,
						vision = false,
					},
					features = {
						text = true,
						tokens = false,
					},
					url = opencode_server_url(),
					headers = {},
					parameters = {},
					handlers = {
						chat_output = function(_, data)
							local text, err = extract_text(data)
							if not text then
								return { status = "error", output = err }
							end

							return {
								status = "success",
								output = {
									role = "assistant",
									content = text,
								},
							}
						end,
						inline_output = function(_, data)
							local text, err = extract_text(data)
							if not text then
								return { status = "error", output = err }
							end

							return { status = "success", output = text }
						end,
					},
					schema = {
						model = {
							order = 1,
							mapping = "parameters",
							type = "enum",
							desc = "OpenCode model used by the server adapter.",
							default = function()
								return current_model().id
							end,
							choices = vim.tbl_map(function(model)
								return model.id
							end, models),
						},
					},
				}
			end,
		},
	},
	interactions = {
		chat = {
			adapter = "opencode",
		},
		inline = {
			adapter = "opencode_server",
		},
		shared = {
			keymaps = {
				always_accept = {
					modes = { n = "<leader>aY" },
					description = "Always accept inline changes",
				},
				accept_change = {
					modes = { n = "<leader>ay" },
					description = "Accept inline change",
				},
				reject_change = {
					modes = { n = "<leader>an" },
					description = "Reject inline change",
				},
				next_hunk = {
					modes = { n = "<leader>aj" },
					description = "Next inline hunk",
				},
				previous_hunk = {
					modes = { n = "<leader>ak" },
					description = "Previous inline hunk",
				},
			},
		},
	},
	opts = {
		language = "Portuguese (Brazil)",
	},
})

vim.keymap.set("n", "<leader>ai", codecompanion_inline, { desc = "AI Inline" })
vim.keymap.set("x", "<leader>ai", codecompanion_inline_visual, { desc = "AI Inline" })
vim.keymap.set({ "n", "x" }, "<leader>am", toggle_model, { desc = "AI Toggle Model" })

vim.api.nvim_create_user_command("CodeCompanionOpenCodeServe", function()
	ensure_opencode_server(function(ok)
		if ok then
			vim.notify("OpenCode server pronto: " .. opencode_server_url(), vim.log.levels.INFO)
		end
	end)
end, {
	desc = "Start OpenCode server for CodeCompanion inline",
})

vim.api.nvim_create_user_command("CodeCompanionToggleModel", toggle_model, {
	desc = "Toggle CodeCompanion OpenCode model",
})
