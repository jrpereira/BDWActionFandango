package.path = 'UE4SSTemplatingEngine/Scripts/?.lua;' .. package.path
local TE = require('te.init')
local te = TE.new({
    categoriesPath='UE4SSTemplatingEngine/categories.lua',
    categoriesFolder='UE4SSTemplatingEngine/categories',
    listFiles=function() return {} end,
})
te:registerTemplate('ActionFandango/templates/action_fandango.lua')
assert(te:loadTemplatesFromRegister()==1)
local menu=te:generateMenu()
assert(menu.providers['UE4SSTemplatingEngine.module.ActionFandango'])
local selector=assert(menu.selectors['player.quickslots'])
local value=assert(next(selector.byValue))
local definition=assert(menu.definitions['player.quickslots'][value])
assert(definition.access=='TE_AccessMethod')
assert(definition.direct['1'] and #definition.direct['1']==4)
assert(definition.direct['2'] and #definition.direct['2']==4)
print('Action Fandango TE registration passed')
