--[[
 				 `/shdmmmmmmmmmd-`ymmmddyo:`       //                sm- /h/                        --
				`yNMMMMMMMMMMMMm-.dMMMMMMMMMN+     `MN  `-:::.`   .-:-hM- -o-  .-::.  .::-.   `.:::` MN--. `-::-.
				yMMMMMMMMMMMMMd.:NMMMMMMMMMMMM+    `MN  yMs+oNh  oNy++mM- +Mo -Mm++:`hmo+yN+ .dmo++- MNoo/ `o+odN:
				yMMMMMMMMMMMMy`+NMMMMMMMMMMMMM+    `MN  yM:  dM. MN   yM- +Mo -Mh   /Mmss    sM+     MN    +h ohMo
				`yNMMMMMMMMMo`sMMMMMMMMMMMMMNo     `MN  yM:  dM. oNy//dM- +Mo -Mh   `dNs++o. -mm+//- dM+/+ mN+/sMo
				  `/shddddd/ odddddddddddho:`       ::  .:`  -:   `:///-` .:. `:-     .://:`  `-///. `-//: `-///:.

		DisplayOverBindable™️ Module 4 Xinu
		Licensed under GNU General Public License v3.0
		Revision: 5



]]


local bindablename = "DisplayOverBindable™️"
local module = {}
local device = {}
device.__index = device

local print = print

module.registeredDevices = {}
module.enabled = false
module.bindable = nil
module.configuration = nil

function device:Output(...) -- self:OutputToDevice({DEVICE}, "info", "time: ", os.time())

	assert(module.enabled, "Module is disabled")
	assert(module.bindable, "Bindable has not been created")
	assert(self.Identifier, "Device missing an Identifier")

	local fn = table.pack(...)[1]
	local args = table.pack(...)
	table.remove(args, 1)

	local setts = self.CustomEchoSettings or nil

	if module[fn] then
		wait(math.random(10,50)/100) -- Wait 0.1 for less slowness
		
		local fnt = module[fn]

		local fullText, header, color, text, timedate, prefix = fnt(module, setts, args)

		if self.LegacyTextYLimit and self.LegacyTextLabel and self.LegacyTextLabel.TextBounds.Y >= self.LegacyTextYLimit then
			self.TextBuffer = ""
		end

		self.TextBuffer ..= fullText

		module.bindable:Fire("OutputDevice", self.Identifier, {
			textBfr = self.TextBuffer;
			textAdd = fullText;
			optText = {header, color, text, timedate, prefix}
		})
	else
		module.bindable:Fire("DeviceCommand", self.Identifier, {
			command = fn,
			args = args,
		})
	end



end


function module:OutputToAll(...) -- self:OutputToAll("error","test")
	assert(self.enabled, "Module is disabled")
	assert(self.bindable, "Bindable has not been created")
	for i, v in ipairs(self.registeredDevices) do
		v:Output(...)
	end
end

function module:GetAllDevices()
	return self.registeredDevices
end
function module:GetDeviceByIdentifier(identifier)
	for i, v in ipairs(self.registeredDevices) do
		if v.Identifier == identifier then
			return v
		end
	end
	return nil
end
function module:GetDeviceByName(name)
	for i, v in ipairs(self.registeredDevices) do
		if v.Name == name then
			return v
		end
	end
	return nil
end
function module:init(configuration)
	local main = configuration.Parent.Parent
	local config = require(configuration)
	self.configuration = config
	self.bindable = main:FindFirstChild(bindablename)

	if not self.bindable then
		self.bindable = Instance.new("BindableEvent", main)
		self.bindable.Name = bindablename
	end

	self.enabled = true

	self.bindable.Event:Connect(
		function(...)
			local data = table.pack(...)
			local header, body = data[1], data[2]

			if type(header) == "string" and header == "IndexDevice" then
				if type(body) == "table" then
					if body.Identifier and body.DeviceScript then
						if #config.DOBWhitelist == 0 or config.DOBWhitelist[body.Object] and not self:GetDeviceByIdentifier(body.Identifier) then
							local newDevice = {
								Name = body.Name,
								Identifier = body.Identifier,
								Script = body.DeviceScript,
								Object = body.Object,
								SurfaceGui = body.SurfaceGui or nil,
								Resolution = body.SurfaceGui and
									{X = body.SurfaceGui.AbsoluteSize.X, Y = body.SurfaceGui.AbsoluteSize.Y} or
									nil,
								TextBuffer = "",
								LegacyTextLabel = body.LegacyTextLabel,
								LegacyTextYLimit = body.LegacyTextYLimit,
								DeviceType = (body.LegacyTextLabel and "LegacyMonitor" or
									(body.SurfaceGui and "Monitor" or (body.Object and "Device" or "Interface")));
								CustomEchoSettings = body.CustomEchoSettings or nil;
								CustomParams = body.CustomParams or nil;
							}
							setmetatable(newDevice,device)
							table.insert(self.registeredDevices, newDevice)
						end
					end
				end
			end
		end
	)
	return {
		echo = "echo",
		onEcho = "onEcho",
		echoSettings = "echoSettings",

		info = "info",
		success = "success",
		debug = "debug",
		warn = "warn",
		error = "error",

		ProgressBar = "ProgressBar",

		GetDeviceByName = "GetDeviceByName",
		GetDeviceByIdentifier = "GetDeviceByIdentifier",
		GetAllDevices = "GetAllDevices",
		OutputToAll = "OutputToAll",

	}, self
end

module.onEcho = Instance.new("BindableEvent")

module.echoSettings = {
	prefixSurround = {"[", "]"},
	includeTime = true,
	includeUnix = true,
	newlinePadding = true,
	lastPaddingChar = " ",
	formatStrForRichText = true
}
function module:echo(echosetts, color, prefix, args)

	local text = table.concat(args, "\n")
	local setts = echosetts or self.echoSettings
	prefix = prefix and setts.prefixSurround[1] .. prefix .. setts.prefixSurround[2] or ""
	color =
		"rgb(" ..
		math.round(color.R * 255) .. ", " .. math.round(color.G * 255) .. ", " .. math.round(color.B * 255) .. ")"
	local header = ""

	local time = os.time()
	local timedate = os.date("*t", time)
	if timedate.sec < 10 then
		timedate.sec = "0" .. timedate.sec
	end
	if timedate.min < 10 then
		timedate.min = "0" .. timedate.min
	end
	if timedate.hour < 10 then
		timedate.hour = "0" .. timedate.hour
	end

	if setts.includeTime then
		header =
			header ..
			"<font color='rgb(53, 53, 53)'>[" ..
			timedate.hour .. ":" .. timedate.min .. ":" .. timedate.sec .. "]</font>"
	end
	if setts.includeUnix then
		header = header .. "<font color='rgb(53, 53, 53)'>[" .. tostring(time) .. "]</font>"
	end
	header = header .. '<font color="' .. color .. '">' .. prefix .. " "

	local function removeTags(str)
		return (str:gsub("(\\?)<[^<>]->", {[""] = ""}))
	end

	local spaces = ""
	for i = 1, #removeTags(header) do
		spaces = spaces .. " "
	end
	if setts.lastPaddingChar == " " then
	else
		spaces = string.sub(spaces, 1, #spaces - 1) .. setts.lastPaddingChar
	end
	if setts.formatStrForRichText then
		text = text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;")
	end
	if setts.newlinePadding then
		text = text:gsub("\n", "\n" .. spaces)
	end

	local fullText = header .. text .. "<br/></font>"

	self.onEcho:Fire(fullText, header, color, text, timedate)
	return fullText, header, color, text, timedate, prefix
end

function module:info(...)
	local args = table.pack(...)
	local setts = args[1] or nil
	table.remove(args,1)
	args = table.unpack(args)
	return self:echo(setts, Color3.fromRGB(24, 97, 255), "INFO", args)
end
function module:success(...)
	local args = table.pack(...)
	local setts = args[1] or nil
	table.remove(args,1)
	args = table.unpack(args)
	return self:echo(setts, Color3.fromRGB(0, 255, 0), "SUCCESS", args)
end
function module:debug(...)
	local args = table.pack(...)
	local setts = args[1] or nil
	table.remove(args,1)
	args = table.unpack(args)
	return self:echo(setts, Color3.fromRGB(145, 49, 255), "DEBUG", args)
end
function module:warn(...)
	local args = table.pack(...)
	local setts = args[1] or nil
	table.remove(args,1)
	args = table.unpack(args)
	return self:echo(setts, Color3.fromRGB(255, 165, 0), "WARN", args)
end
function module:error(...)
	local args = table.pack(...)
	local setts = args[1] or nil
	table.remove(args,1)
	args = table.unpack(args)
	return self:echo(setts, Color3.fromRGB(255, 48, 29), "ERROR", args)
end

function module:ProgressBar(progress, width, showPercentage, showColor)
	showPercentage,showColor = showPercentage or false, showColor or false
	-- 100 --> 1
	progress = progress / 100
	width = width or 25

	local parts = {" ", "▏", "▎", "▍", "▍", "▋", "▊", "▉"}
	local progress_width = math.floor(progress * width)
	local remainder_width = (progress * width) % 1
	local part_width = math.floor(remainder_width * 8)
	local part_char = parts[part_width]
	if width - progress_width - 1 < 0 then
		part_char = ""
	end
	local remainder_pos = width - progress_width - 1

	local additional = ""

	for i = 1, width - progress_width - 1 do
		additional = additional .. " "
	end

	local filled = ""
	local CRITICAL_COLOR = Color3.new(1, 0, 0)
	local STABLE_COLOR = Color3.new(0, 1, 0)

	for i = 1, progress_width do
		print(i, progress_width, progress, width, remainder_width, part_width, i/width)

		local color = CRITICAL_COLOR:Lerp(STABLE_COLOR, i/width)
		filled = filled .. (showColor and "<font color='rgb(".. math.round(color.R*255) ..", ".. math.round(color.G*255) ..", ".. math.round(color.B*255) ..")'>" or "").."▉"..(showColor and "</font>" or "")
	end

	local cVar = math.min((progress_width+1)/width, 1)
	local color = CRITICAL_COLOR:Lerp(STABLE_COLOR, cVar)
	part_char = part_char and (showColor and "<font color='rgb(".. math.round(color.R*255) ..", ".. math.round(color.G*255) ..", ".. math.round(color.B*255) ..")'>"..part_char.."</font>" or part_char) or ""

	local line =
		"[" .. filled .. (part_char or "") .. additional .. "] " .. (showPercentage and string.format("%.1f", progress * 100) .. "%" or "")
	return line
end

return module
