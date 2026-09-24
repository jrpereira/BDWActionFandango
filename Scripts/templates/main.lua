local source = debug.getinfo(1,'S').source:gsub('^@','')
local folder = assert(source:match('^(.*)[/\\]main%.lua$'),
    'cannot locate Action Fangdango templates')
local function load(name)
    local path = folder .. '/' .. name .. '.lua'
    return assert(loadfile(path,'t'))()
end

local header = {
    category = 'player.quickslots',
    name = "Action Fangdango",
    version = '0.2.1',
    single = true,
}

return header, {load('quickslots')}
