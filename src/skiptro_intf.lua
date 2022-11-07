--- logging.lua ---
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
local logLevel = LogLevel.DEBUG

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

--- END logging.lua ---

--- END IMPORTS ---
local logger = Logger.new(LogLevel.DEBUG)

function Sleep(st) -- seconds
	vlc.misc.mwait(vlc.misc.mdate() + st*1000000)
end

function looper()
    while true do
        logger.debug("hello")
        Sleep(1)
    end
end

function log(message)
    return "Skiptro: " .. message
end

looper()