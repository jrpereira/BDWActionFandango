local source = debug.getinfo(1,'S').source:gsub('^@','')
local folder = assert(source:match('^(.*)[/\\]main%.lua$'),
    'cannot locate Action Fandango templates')
local function load(name)
    local path = folder .. '/' .. name .. '.lua'
    return assert(loadfile(path,'t'))()
end

local header = {
    category = 'player.quickslots',
    name = "Action Fandango",
    version = '0.1.0',
    single = true,
}

return header, {load('wheels_plus')}
