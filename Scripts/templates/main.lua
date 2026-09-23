local source = debug.getinfo(1,'S').source:gsub('^@','')
local folder = assert(source:match('^(.*)[/\\]main%.lua$'),
    'cannot locate Action Fandango templates')
local function load(name)
    local path = folder .. '/' .. name .. '.lua'
    return assert(loadfile(path,'t'))()
end

local header = {
    category = 'player.quickslots',
    single = true,
    version = '0.1.0',
}

return header, {load('swapping_fixed'),load('dual_wheels')}
