local root = (arg[0] or ''):match('^(.*)/tests/template_test%.lua$') or '.'
package.path = root .. '/../UE4SSTemplatingEngine/Scripts/?.lua;' .. package.path
local header, choices = dofile(root .. '/templates/action_fandango.lua')
assert(header.category=='player.quickslots' and #choices==2)
local fixed,template=choices[1],choices[2]

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

local handle,err=template:attach(service,switcher,{access=0,settings={Arrangement=0,Gap=360}},nil)
assert(handle,err)
assert(switcher:GetChildrenCount()==1 and switcher:GetChildAt(0)==consumable)
assert(ability:GetParent()==owner)
assert(ability.RenderTransform.Translation.X==20 and ability.RenderTransform.Translation.Y==-320)
assert(prompt.opacity==0)

local second,secondError=template:attach(service,switcher,{access=0,
    settings={Arrangement=1,PrimaryWheel=1,X=-40,Y=60,Gap=300}},handle)
assert(second,secondError)
assert(switcher:GetChildAt(0)==ability and consumable:GetParent()==owner)
assert(consumable.RenderTransform.Translation.X==260 and consumable.RenderTransform.Translation.Y==60)
assert(template:render(service,second,switcher,'GroupSelected')=='applied')
assert(template:detach(service,second,'disable'))
assert(switcher:GetChildrenCount()==2)
assert(switcher:GetChildAt(0)==ability and switcher:GetChildAt(1)==consumable)
assert(switcher:GetActiveWidgetIndex()==1)
assert(prompt.opacity==1)
assert(ability.RenderTransform.Translation.X==0 and ability.RenderTransform.Translation.Y==0)
assert(consumable.RenderTransform.Translation.X==0 and consumable.RenderTransform.Translation.Y==0)

local rejected,message=template:attach(service,switcher,{access=1,settings={}},nil)
assert(rejected==nil and message:find('one key per slot',1,true))
assert(switcher:GetChildrenCount()==2 and prompt.opacity==1)

local addChild=owner.AddChild
function owner:AddChild(child)
    if child==ability then return nil end
    return addChild(self,child)
end
local failed,failure=template:attach(service,switcher,{access=0,settings={PrimaryWheel=0}},nil)
assert(failed==nil and failure:find('cannot display secondary wheel',1,true))
assert(switcher:GetChildrenCount()==2 and switcher:GetChildAt(0)==ability
    and switcher:GetChildAt(1)==consumable)
assert(prompt.opacity==1)

local fixedConfig={access=1,settings={PrimaryWheel=1},
    groups={['1']={key=0,mode=-1},['2']={key=164,mode=0}}}
local fixedState,fixedError=fixed:attach(service,switcher,fixedConfig,nil)
assert(fixedState,fixedError)
assert(switcher:GetActiveWidgetIndex()==0 and switcher:GetChildrenCount()==2)
assert(fixed:render(service,fixedState,switcher,'GroupSelected')=='applied')
assert(fixed:detach(service,fixedState,'disable'))
assert(switcher:GetActiveWidgetIndex()==1)
local wrongAccess=select(1,fixed:attach(service,switcher,{access=0,settings={PrimaryWheel=1}},nil))
assert(wrongAccess==nil and switcher:GetActiveWidgetIndex()==1)

function switcher:AddChild(child)
    if child==ability then return nil end
    return addChild(self,child)
end
local unrestored,restoreFailure=template:attach(service,switcher,
    {access=0,settings={PrimaryWheel=0}},nil)
assert(unrestored==nil and restoreFailure:find('cannot display secondary wheel',1,true)
    and restoreFailure:find('restoration failed:',1,true)
    and restoreFailure:find('failed to restore wheel',1,true), restoreFailure)
print('Action Fandango template lifecycle passed')
