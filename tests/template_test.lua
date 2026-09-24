local root = 'ActionFangdango'
package.path = root .. '/../ModCoreTemplates/Scripts/?.lua;' .. package.path
local header, choices = dofile(root .. '/Scripts/templates/main.lua')
assert(header.category=='player.quickslots' and #choices==1)
local template=choices[1]

local function widget(name)
    local w = {
        name=name, children={}, RenderTransform={Translation={X=0,Y=0},Scale={X=1,Y=1}},
        opacity=1, active=0,
    }
    function w:IsValid() return true end
    function w:GetFullName() return self.name end
    function w:GetParent() return self.parent end
    function w:GetChildrenCount() return #self.children end
    function w:GetChildAt(index) return self.children[index+1] end
    function w:AddChild(child)
        assert(child.parent==nil)
        self.children[#self.children+1]=child
        child.parent=self
        child.Slot={Padding={Left=0,Top=0,Right=0,Bottom=0},HorizontalAlignment=0,VerticalAlignment=0}
        function child.Slot:IsValid() return true end
        function child.Slot:SetPadding(value) self.Padding=value end
        function child.Slot:SetHorizontalAlignment(value) self.HorizontalAlignment=value end
        function child.Slot:SetVerticalAlignment(value) self.VerticalAlignment=value end
        return child.Slot
    end
    function w:RemoveChild(child)
        for index,item in ipairs(self.children) do
            if item==child then
                table.remove(self.children,index)
                child.parent=nil
                return true
            end
        end
        return false
    end
    function w:GetActiveWidgetIndex() return self.active end
    function w:SetActiveWidgetIndex(index) self.active=index end
    function w:SetActiveWidget(child)
        for index,item in ipairs(self.children) do
            if item==child then self.active=index-1; return end
        end
        error('active widget is not a child')
    end
    function w:SetRenderTranslation(value) self.RenderTransform.Translation=value end
    function w:SetRenderScale(value) self.RenderTransform.Scale=value end
    function w:GetRenderOpacity() return self.opacity end
    function w:SetRenderOpacity(value) self.opacity=value end
    return w
end

local service={}
function service:valid(value) return type(value)=='table' and value.IsValid and value:IsValid() end
function service:identity(value) return value:GetFullName() end
function service:same(a,b) return self:valid(a) and self:valid(b) and self:identity(a)==self:identity(b) end
function service:parent(value) return value:GetParent() end

local hud=widget('WBP_GameHUD_C /Engine/Transient.GameHUD')
local owner=widget('Panel /Engine/Transient.Panel')
local switcher=widget('Switcher /Engine/Transient.Switcher')
local ability=widget('WBP_AA_Quickslots_C /Engine/Transient.Abilities')
local consumable=widget('WBP_HUD_Quickslots_C /Engine/Transient.Consumables')
local prompt=widget('Prompt /Engine/Transient.Prompt')
hud:AddChild(owner)
hud:AddChild(prompt)
owner:AddChild(switcher)
switcher:AddChild(ability)
switcher:AddChild(consumable)
switcher:SetActiveWidgetIndex(1)
hud.WBP_AA_Quickslots=ability
hud.WBP_HUD_Quickslots=consumable
hud.WBP_HUD_Quickslots_ChangePrompt=prompt


local swap={Style=0,WheelsX=20,WheelsY=40,WheelsSize=80,WheelsOpacity=60}
local state=assert(template:attach(service,switcher,swap))
assert(switcher:GetChildrenCount()==2 and switcher:GetActiveWidgetIndex()==1)
assert(ability.RenderTransform.Translation.X==20 and consumable.RenderTransform.Translation.X==20)
assert(ability.RenderTransform.Scale.X==0.8 and consumable.opacity==0.6)
local distant={Style=1,Wheel1X=-100,Wheel1Y=10,Wheel2X=200,Wheel2Y=30}
state=assert(template:attach(service,switcher,distant,state))
assert(ability:GetParent()==owner and consumable:GetParent()==switcher)
assert(ability.RenderTransform.Translation.X==-100 and consumable.RenderTransform.Translation.X==200)
state=assert(template:attach(service,switcher,distant,state))
assert(ability.RenderTransform.Translation.X==-100)
state=assert(template:attach(service,switcher,swap,state))
assert(switcher:GetChildrenCount()==2 and switcher:GetActiveWidgetIndex()==1)
assert(template:detach(service,state))
assert(ability.RenderTransform.Translation.X==0 and consumable.RenderTransform.Translation.X==0)
assert(ability.opacity==1 and consumable.opacity==1)
local originalAdd=owner.AddChild
function owner:AddChild() error('injected attachment failure') end
local failed,why=template:attach(service,switcher,distant)
assert(not failed and why:find('injected attachment failure',1,true))
assert(switcher:GetChildrenCount()==2 and ability:GetParent()==switcher)
owner.AddChild=originalAdd
local te=require('ket.init').new({
    categoriesFolder='ModCoreTemplates/Scripts/categories',
    listFiles=function() return {} end,
})
te:registerTemplate('ActionFangdango/Scripts/templates/main.lua')
assert(te:loadTemplatesFromRegister()==1)
local menu=te:generateMenu({externalQuickslotControls=true})
local selector=menu.selectors['player.quickslots']
local value=assert(next(selector.byValue))
local page=menu.providers['ModCoreTemplates.module.ActionFangdango']
local values={[selector.id]=value}
for _,row in ipairs(page.rows) do
    if row.Id and row.Default~=nil then values[row.Id]=tonumber(row.Default) or row.Default end
end
values[selector.id]=value
local selection=page.decode(values)['player.quickslots']
local context={playerActions=service,targets={['player.quickslots']=switcher}}
local applied,reason=te.runtime:apply('player.quickslots',selection.id,selection.settings,context)
assert(applied,reason)
assert(switcher:GetChildrenCount()==2,'Swap must preserve native wheel switching')
local distantSettings={}
for key,item in pairs(selection.settings) do distantSettings[key]=item end
distantSettings.Style=1
applied,reason=te.runtime:apply('player.quickslots',selection.id,distantSettings,context)
assert(applied,reason)
assert(switcher:GetChildrenCount()==1 and ability:GetParent()==owner)
applied,reason=te.runtime:apply('player.quickslots',selection.id,selection.settings,context)
assert(applied,reason)
assert(switcher:GetChildrenCount()==2)
assert(te.runtime:apply('player.quickslots',nil,{},context))
assert(switcher:GetChildrenCount()==2 and switcher:GetActiveWidgetIndex()==1)
print('AF Swap/Distant attachment, restoration, and MCT lifecycle passed')
