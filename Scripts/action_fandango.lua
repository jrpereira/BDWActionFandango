local source = debug.getinfo(1,'S').source:gsub('^@','')
local root = assert(source:match('^(.*)[/\\]Scripts[/\\][^/\\]+$'),
    'cannot locate Action Fandango module')
local function load(name)
    local path = root .. '/Scripts/action_fandango/' .. name .. '.lua'
    return assert(loadfile(path,'t'))()
end

local header = {
    category = 'player.quickslots',
    single = true,
    version = '0.1.0',
}

return header, {load('swapping_fixed'),load('dual_wheels')}
