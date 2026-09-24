package.path = 'ModCoreTemplates/Scripts/?.lua;' .. package.path
local te=require('ket.init').new({categoriesFolder='ModCoreTemplates/Scripts/categories',listFiles=function() return {} end})
te:registerTemplate('ActionFangdango/Scripts/templates/main.lua')
assert(te:loadTemplatesFromRegister()==1)
local menu=te:generateMenu({externalQuickslotControls=true})
local page=assert(menu.providers['ModCoreTemplates.module.ActionFangdango'])
local selector=menu.selectors['player.quickslots']
local value=assert(next(selector.byValue))
assert(next(selector.byValue,value)==nil)
local definition=menu.definitions['player.quickslots'][value]
assert(te.registry.byId[definition.id].template.name=='Wheels')
assert(not definition.access and not definition.direct)
local rows,values={},{}
for _,row in ipairs(page.rows) do
    rows[row.Id]=row
    if row.Default~=nil then values[row.Id]=tonumber(row.Default) or row.Default end
end
values[selector.id]=value
assert(rows[selector.id].mcLevel==1)
local style=rows[definition.settings.Style]
assert(style.PresetLabels=='Swap|Distant' and style.PresetValues=='0|1')
local count=0
for _ in pairs(definition.settings) do count=count+1 end
assert(count==13)
for _,group in ipairs({'Wheels','Wheel1','Wheel2'}) do
    for _,field in ipairs({'X','Y','Size','Opacity'}) do
        local row=rows[definition.settings[group..field]]
        assert(row.VisibleWhen==definition.settings.Style)
        assert(row.VisibleValues==(group=='Wheels' and '0' or '1'))
    end
end
local settings=page.decode(values)['player.quickslots'].settings
assert(settings.Style==0 and settings.WheelsSize==100 and settings.Wheel2X==360)
assert(settings.access==nil and settings.AccessMode==nil)
print('AF Wheels registration and settings contract passed')
