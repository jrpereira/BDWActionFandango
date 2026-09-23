local root = (arg[0] or ''):match('^(.*)/tests/template_test%.lua$') or '.'
package.path = root .. '/../UE4SSTemplatingEngine/Scripts/?.lua;' .. package.path
local header, choices = dofile(root .. '/Scripts/templates/main.lua')
local category = dofile(root .. '/../UE4SSTemplatingEngine/Scripts/categories/player_quickslots.lua')
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

local firstConfig={access=0,Arrangement=0}
local shared=category:attach(service,switcher,firstConfig,nil,template)
local handle,err=template:attach(service,switcher,firstConfig,nil,shared)
assert(handle,err)
assert(switcher:GetChildrenCount()==1 and switcher:GetChildAt(0)==consumable)
assert(ability:GetParent()==owner)
assert(ability.RenderTransform.Translation.X==20 and ability.RenderTransform.Translation.Y==-320)
assert(prompt.opacity==0)

local secondConfig={access=0,Arrangement=1,PrimaryWheel=1,X=-40,Y=60,
    SecondaryX=-100,SecondaryY=60}
shared=category:attach(service,switcher,secondConfig,shared,template)
local second,secondError=template:attach(service,switcher,secondConfig,handle,shared)
assert(second,secondError)
assert(switcher:GetChildAt(0)==ability and consumable:GetParent()==owner)
assert(switcher.RenderTransform.Translation.X==-40 and switcher.RenderTransform.Translation.Y==60)
assert(consumable.RenderTransform.Translation.X==260 and consumable.RenderTransform.Translation.Y==60)
assert(template:render(service,second,switcher,'GroupSelected')=='applied')
assert(template:detach(service,second,'disable'))
assert(category:detach(service,shared,'disable'))
assert(switcher:GetChildrenCount()==2)
assert(switcher:GetChildAt(0)==ability and switcher:GetChildAt(1)==consumable)
assert(switcher:GetActiveWidgetIndex()==1)
assert(prompt.opacity==1)
assert(ability.RenderTransform.Translation.X==0 and ability.RenderTransform.Translation.Y==0)
assert(consumable.RenderTransform.Translation.X==0 and consumable.RenderTransform.Translation.Y==0)

local advancedConfig={access=2,PrimaryWheel=1}
shared=category:attach(service,switcher,advancedConfig,nil,template)
local advanced,advancedError=template:attach(service,switcher,advancedConfig,nil,shared)
assert(advanced,advancedError)
assert(switcher:GetChildrenCount()==1 and switcher:GetChildAt(0)==ability)
assert(template:detach(service,advanced,'disable'))
assert(category:detach(service,shared,'disable'))
assert(switcher:GetChildrenCount()==2 and switcher:GetActiveWidgetIndex()==1)

local overlapConfig={access=0,Arrangement=2,PrimaryWheel=1,X=-40,Y=60,
    SecondaryX=120,SecondaryY=-30}
shared=category:attach(service,switcher,overlapConfig,nil,template)
local overlap,overlapError=template:attach(service,switcher,overlapConfig,nil,shared)
assert(overlap,overlapError)
assert(consumable.RenderTransform.Translation.X==120
    and consumable.RenderTransform.Translation.Y==-30)
assert(template:detach(service,overlap,'disable'))
assert(category:detach(service,shared,'disable'))
assert(switcher:GetChildrenCount()==2 and switcher:GetActiveWidgetIndex()==1)

switcher:SetRenderTranslation({X=7,Y=11})
ability:SetRenderTranslation({X=2,Y=5})
consumable:SetRenderTranslation({X=-3,Y=4})
local nativeConfig={access=0,Arrangement=0,PrimaryWheel=1,X=13,Y=17,
    SecondaryX=-5,SecondaryY=9}
shared=category:attach(service,switcher,nativeConfig,nil,template)
local native,nativeError=template:attach(service,switcher,nativeConfig,nil,shared)
assert(native,nativeError)
assert(switcher.RenderTransform.Translation.X==20
    and switcher.RenderTransform.Translation.Y==28)
assert(ability.RenderTransform.Translation.X==2 and ability.RenderTransform.Translation.Y==5)
assert(consumable.RenderTransform.Translation.X==-1
    and consumable.RenderTransform.Translation.Y==-336)
assert(template:detach(service,native,'disable'))
assert(category:detach(service,shared,'disable'))
assert(switcher.RenderTransform.Translation.X==7 and switcher.RenderTransform.Translation.Y==11)
assert(ability.RenderTransform.Translation.X==2 and ability.RenderTransform.Translation.Y==5)
assert(consumable.RenderTransform.Translation.X==-3
    and consumable.RenderTransform.Translation.Y==4)
switcher:SetRenderTranslation({X=0,Y=0})
ability:SetRenderTranslation({X=0,Y=0})
consumable:SetRenderTranslation({X=0,Y=0})

local rejectedConfig={access=1,}
shared=category:attach(service,switcher,rejectedConfig,nil,template)
local rejected,message=template:attach(service,switcher,rejectedConfig,nil,shared)
assert(category:detach(service,shared,'attach_failed'))
assert(rejected==nil and message:find('Individual or Advanced',1,true))
assert(switcher:GetChildrenCount()==2 and prompt.opacity==1)

local addChild=owner.AddChild
function owner:AddChild(child)
    if child==ability then return nil end
    return addChild(self,child)
end
local failed,failure=pcall(function()
    return category:attach(service,switcher,{access=0,PrimaryWheel=0},nil,template)
end)
assert(not failed and failure:find('could not attach secondary wheel to owner',1,true))
assert(switcher:GetChildrenCount()==2 and switcher:GetChildAt(0)==ability
    and switcher:GetChildAt(1)==consumable)
assert(prompt.opacity==1)

function switcher:AddChild(child)
    if child==ability then return nil end
    return addChild(self,child)
end
local unrestored,restoreFailure=pcall(function()
    return category:attach(service,switcher,{access=0,PrimaryWheel=0},nil,template)
end)
assert(not unrestored and restoreFailure:find('could not attach secondary wheel to owner',1,true),restoreFailure)
print('Action Fandango template lifecycle passed')
