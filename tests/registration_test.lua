package.path = 'UE4SSTemplatingEngine/Scripts/?.lua;' .. package.path
local TE = require('te.init')
local Plan = require('te.player_actions.plan')
local Delivery = require('te.player_actions.delivery')
local te = TE.new({
    categoriesPath='UE4SSTemplatingEngine/Scripts/categories.lua',
    categoriesFolder='UE4SSTemplatingEngine/Scripts/categories',
    listFiles=function() return {} end,
})
te:registerTemplate('ActionFandango/Scripts/templates/main.lua')
assert(te:loadTemplatesFromRegister()==2)
local menu=te:generateMenu()
local page=assert(menu.providers['UE4SSTemplatingEngine.module.ActionFandango'])
local selector=assert(menu.selectors['player.quickslots'])
local values={}
for value in pairs(selector.byValue) do values[#values+1]=value end
assert(#values==2)
local byName={}
local definitions={}
for _,entry in ipairs(te.registry.templates) do
    assert(entry.template.category=='player.quickslots' and entry.template.version=='0.1.0'
        and entry.template.single==true)
    byName[entry.template.name]=entry.template
end
assert(byName['Swapping Fixed'] and byName['Dual Wheels'])
local positions, categoryInput={}
for index,row in ipairs(page.rows) do
    if row.Id then positions[row.Id]=index end
    if row.Label=='Input Keys' then categoryInput=row.Id end
end
assert(categoryInput and positions[categoryInput])
for _,value in ipairs(values) do
    local definition=assert(menu.definitions['player.quickslots'][value])
    local name=te.registry.byId[definition.id].template.name
    definitions[name]={value=value,definition=definition}
    assert(definition.access)
    assert(definition.direct['1'] and #definition.direct['1']==4)
    assert(definition.direct['2'] and #definition.direct['2']==4)
    for _,settingId in pairs(definition.settings) do
        assert(positions[categoryInput]<positions[settingId],
            'category settings must precede template settings')
    end
end
local defaults={}
for _,row in ipairs(page.rows) do
    if row.Id and row.Default~=nil then defaults[row.Id]=tonumber(row.Default) end
end
for name,item in pairs(definitions) do
    defaults[selector.id]=item.value
    local configuration=menu.decode(defaults)['player.quickslots'].configuration
    assert(configuration.categorySettings.AccessMode==0)
    assert(configuration.settings.AccessMode==nil)
    assert(configuration.settings.PrimaryWheel==(name=='Dual Wheels' and 0 or 1))
end
defaults[selector.id]=definitions['Dual Wheels'].value
defaults[categoryInput]=2
local advanced=menu.decode(defaults)['player.quickslots'].configuration
assert(advanced.access==2 and advanced.categorySettings.AccessMode==2)
local advancedPlan=Plan.build(byName['Dual Wheels'],advanced,
    te.categories:getCategory('player.quickslots'))
assert(#advancedPlan.actions==16 and advancedPlan.actions[1].slot==1
    and advancedPlan.actions[9].targetSlot==1)
local activated, nativeSelections = {}, 0
local service = {
    activateQuickslot=function(_,kind,slot)
        activated[#activated+1]={kind,slot}
        return true
    end,
    selectQuickslotGroup=function()
        nativeSelections=nativeSelections+1
        return true
    end,
}
local state={configuration=advanced,selectedGroup=1,defaultGroup=1}
for _,action in ipairs(advancedPlan.actions) do
    if action.slot then
        state.selectedGroup=action.groupIndex==1 and 2 or 1
        assert(Delivery.deliver(byName['Dual Wheels'],state,action,'Triggered',service))
        assert(#activated==0,'inactive Advanced group must not activate a slot')
        local groupKey
        for _,candidate in ipairs(advancedPlan.actions) do
            if candidate.targetSlot==action.slot and candidate.groupIndex==action.groupIndex then
                groupKey=candidate
                break
            end
        end
        assert(groupKey and Delivery.deliver(byName['Dual Wheels'],state,groupKey,'Triggered',service))
        assert(state.selectedGroup==action.groupIndex and nativeSelections==0)
        assert(Delivery.deliver(byName['Dual Wheels'],state,action,'Triggered',service))
        assert(#activated==1 and activated[1][1]==action.type
            and activated[1][2]==action.slot)
        activated={}
    end
end
local plan=Plan.build(byName['Swapping Fixed'],{
    access=1,settings={PrimaryWheel=1},
    groups={['1']={key=0,mode=-1},['2']={key=164,mode=0}},
    shared={{key=49,mode=0},{key=50,mode=0},{key=51,mode=0},{key=52,mode=0}},
},te.categories:getCategory('player.quickslots'))
assert(#plan.actions==6 and plan.actions[1].binding.mode==-1
    and plan.actions[2].binding.key==164)
print('Action Fandango TE registration passed')
