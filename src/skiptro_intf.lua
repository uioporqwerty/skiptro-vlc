--#region Utilities
local random = math.random

function Sleep(seconds)
	vlc.misc.mwait(vlc.misc.mdate() + seconds * 1000000)
end

function GetTableLength(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function UUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end
--#endregion

--#region Logger
local LogLevel = { DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3
}

function LogLevelToString(level)
    if level == LogLevel.DEBUG then
        return "DEBUG"
    elseif level == LogLevel.INFO then
        return "INFO"
    elseif level == LogLevel.WARN then
        return "WARN"
    else
        return "ERROR"
    end
end

local Logger = {}
local logLevel = LogLevel.DEBUG -- Default log level

function Logger.new(level)
    logLevel = level
    return Logger
end

function Logger.log(level, message)
    if level >= logLevel then
        local msg = "[Skiptro][" .. LogLevelToString(level) .. "] " .. message

        if level == LogLevel.DEBUG then
        	vlc.msg.dbg(msg)
        end

        if level == LogLevel.INFO then
            vlc.msg.info(msg)
        end

        if level == LogLevel.WARN then
            vlc.msg.warn(msg)
        end

        if level == LogLevel.ERROR then
            vlc.msg.err(msg)
        end
    end
end

function Logger.debug(message)
    Logger.log(LogLevel.DEBUG, message)
end

function Logger.info(message)
    Logger.log(LogLevel.INFO, message)
end

function Logger.warn(message)
    Logger.log(LogLevel.WARN, message)
end

function Logger.error(message)
    Logger.log(LogLevel.ERROR, message)
end
--#endregion

local logger = Logger.new(LogLevel.DEBUG)

--#region Network Utilities
function Parse_Url(url)
	local url_parsed = vlc.net.url_parse(url)
	return url_parsed["host"], url_parsed["path"], url_parsed["option"]
end

function Parse_Header(data)
	local header = {}

	for name, s, val in string.gfind(data, "([^%s:]+)(:?)%s([^\n]+)\r?\n") do
		if s == "" then header['statuscode'] = tonumber(string.sub (val, 1 , 3))
		else header[name] = val end
	end
	return header
end

function Post(url, data)
    local host, path = Parse_Url(url)
	local header = {
		"POST "..path.." HTTP/1.1",
        "Accept: text/plain",
		"Host: "..host,
        "Content-Type: application/json",
        "Content-Length: "..string.len(data),
		"",
		data
	}
	local request = table.concat(header, "\r\n")
    local status, response = Http_Req(host, 80, request)

	if status == 200 then
		return response
	else
		return false, status, response
	end
end

function Get(url)
	local host, path = Parse_Url(url)
	local header = {
		"GET "..path.." HTTP/1.1",
		"Host: "..host,
		"",
		""
	}
	local request = table.concat(header, "\r\n")

	local status, response = Http_Req(host, 80, request)

	if status == 200 then
		return response
	else
		return false, status, response
	end
end

function Http_Req(host, port, request)
	local fd = vlc.net.connect_tcp(host, port)
	if not fd then return false end
	local pollfds = {}

	pollfds[fd] = vlc.net.POLLIN
	vlc.net.send(fd, request)
	vlc.net.poll(pollfds)

	local response = vlc.net.recv(fd, 1024)
	local headerStr, body = string.match(response, "(.-\r?\n)\r?\n(.*)")
	local header = Parse_Header(headerStr)
	local contentLength = tonumber(header["Content-Length"])
	local status = tonumber(header["statuscode"])
	local bodyLength = string.len(body)
	
	--~ if status ~= 200 then return status end

	while contentLength and bodyLength < contentLength do
		vlc.net.poll(pollfds)
		response = vlc.net.recv(fd, 1024)

		if response then
			body = body..response
		else
			vlc.net.close(fd)
			return false
		end
		bodyLength = string.len(body)
	end
	vlc.net.close(fd)

	return status, body
end
--#endregion

--#region Analytics
local Mixpanel = {}
local Base_Url = "https://api.mixpanel.com"
local Token = "80b838ac885df32f564bef471a9616a0"
local User_Id = nil

function Mixpanel.new()
    return Mixpanel
end

function Mixpanel.track(event, properties)

    logger.debug("Sending track event")
    local url = Base_Url.."/track"
    logger.debug(url)
    local event_data = '[{"event":"'..event..'","properties":{"token":"'..Token..'","time":"'..os.time()..'","distinct_id":"'..User_Id..'","$insert_id":"'..UUID()..'"'

    if properties ~= nil then
        for key, value in pairs(properties) do
            event_data = event_data..',"'..key..'":"'..value[0]..'"'
        end
    end

    event_data = event_data.."}}]"
    logger.debug(event_data)

    local response = Post(url, event_data)
    logger.debug(response)
    print(response)
end
--#endregion

local analytics = Mixpanel.new()

function Looper()
    if User_Id == nil then
        User_Id = UUID() -- TODO: Retrieve from persistent storage. Only initialize this once.
    end
    
    while true do
        -- Keep showing the skip on screen display message while current position < intro end.

        -- If video is playing:
            -- Optional: Extract video metadata. Possibly useful for caching/marking the detected intro portions.

            -- Extract audio frames x seconds ahead of current position.

            -- Extract video frames x seconds ahead of current position.

            -- Process audio & video frames. Make a network call to determine where the skip start might be based on the current position in the video.

            -- Set intro end timestamp
        Sleep(30) -- Depends on how often we want the detection to run. Since detection might be expensive, maybe every 10 seconds?
    end
end

Looper()