package.path = 'UE4SSTemplatingEngine/Scripts/?.lua;' .. package.path
local TE = require('te.init')
local Plan = require('te.player_actions.plan')
local te = TE.new({
    categoriesPath='UE4SSTemplatingEngine/Scripts/categories.lua',
    categoriesFolder='UE4SSTemplatingEngine/Scripts/categories',
    listFiles=function() return {} end,
})
te:registerTemplate('ActionFandango/Scripts/templates/main.lua')
assert(te:loadTemplatesFromRegister()==2)
local menu=te:generateMenu()
assert(menu.providers['UE4SSTemplatingEngine.module.ActionFandango'])
local selector=assert(menu.selectors['player.quickslots'])
local values={}
for value in pairs(selector.byValue) do values[#values+1]=value end
assert(#values==2)
local byName={}
for _,entry in ipairs(te.registry.templates) do
    assert(entry.template.category=='player.quickslots' and entry.template.version=='0.1.0'
        and entry.template.single==true)
    byName[entry.template.name]=entry.template
end
assert(byName['Swapping Fixed'] and byName['Dual Wheels'])
for _,value in ipairs(values) do
    local definition=assert(menu.definitions['player.quickslots'][value])
    assert(definition.access)
    assert(definition.direct['1'] and #definition.direct['1']==4)
    assert(definition.direct['2'] and #definition.direct['2']==4)
end
local plan=Plan.build(byName['Swapping Fixed'],{
    access=1,settings={PrimaryWheel=1},
    groups={['1']={key=0,mode=-1},['2']={key=164,mode=0}},
    shared={{key=49,mode=0},{key=50,mode=0},{key=51,mode=0},{key=52,mode=0}},
},te.categories:getCategory('player.quickslots'))
assert(#plan.actions==6 and plan.actions[1].binding.mode==-1
    and plan.actions[2].binding.key==164)
print('Action Fandango TE registration passed')
