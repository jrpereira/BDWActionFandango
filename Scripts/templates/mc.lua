-- Fangdango owns the two layouts; MCT owns target capture and restoration.
local MC=require('mc')
local Widget=MC('widget')
local wheels=MC.template('wheels')
local bar=MC.template('bars')

function wheels.attach(objects,params,original)
    local switcher,ability,consumable=objects.switcher,objects.abilities,objects.consumables

    if params.settings.Style==0 then
        Widget.appearance(ability,params.settings,'Wheels',original.abilities.position)
        Widget.appearance(consumable,params.settings,'Wheels',original.consumables.position)
    else
        local owner=MC.parent(switcher)
        assert(switcher:RemoveChild(consumable)~=false, 'could not separate wheel')
        assert(MC.valid(owner:AddChild(consumable)), 'could not attach distant wheel')
        local switcherPosition=Widget.translation(switcher)
        local consumablePosition=original.consumables.position
        Widget.appearance(ability,params.settings,'Wheel1',original.abilities.position)
        switcher:SetActiveWidget(ability)
        Widget.appearance(consumable,params.settings,'Wheel2',{
            X=consumablePosition.X+switcherPosition.X,
            Y=consumablePosition.Y+switcherPosition.Y})
    end
    return original
end

return {wheels,bar}
