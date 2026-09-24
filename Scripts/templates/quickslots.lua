local Widget = require('ket.widget')

local fields = {
    {id='Style', type='picker', group='Style', label='Style',
        values={0,1}, labels={'Swap','Distant'}, default=0, tab=true, level=2},

    {id='WheelsX', type='integer', group='Wheels', label='X',
        min=-1000, max=1000, step=10, default=0,
        order=1, visibleWhen='Style', visibleValues={0}},
    {id='WheelsY', type='integer', group='Wheels', label='Y',
        min=-1000, max=1000, step=10, default=0,
        order=2, visibleWhen='Style', visibleValues={0}},
    {id='WheelsSize', type='integer', group='Wheels', label='Size',
        min=25, max=200, step=5, suffix='%', default=100,
        order=3, visibleWhen='Style', visibleValues={0}},
    {id='WheelsOpacity', type='integer', group='Wheels', label='Opacity',
        min=0, max=100, step=5, suffix='%', default=100,
        order=4, visibleWhen='Style', visibleValues={0}},

    {id='Wheel1X', type='integer', group='Wheel1', label='X',
        min=-1000, max=1000, step=10, default=0,
        order=1, visibleWhen='Style', visibleValues={1}},
    {id='Wheel1Y', type='integer', group='Wheel1', label='Y',
        min=-1000, max=1000, step=10, default=0,
        order=2, visibleWhen='Style', visibleValues={1}},
    {id='Wheel1Size', type='integer', group='Wheel1', label='Size',
        min=25, max=200, step=5, suffix='%', default=100,
        order=3, visibleWhen='Style', visibleValues={1}},
    {id='Wheel1Opacity', type='integer', group='Wheel1', label='Opacity',
        min=0, max=100, step=5, suffix='%', default=100,
        order=4, visibleWhen='Style', visibleValues={1}},

    {id='Wheel2X', type='integer', group='Wheel2', label='X',
        min=-1000, max=1000, step=10, default=360,
        order=1, visibleWhen='Style', visibleValues={1}},
    {id='Wheel2Y', type='integer', group='Wheel2', label='Y',
        min=-1000, max=1000, step=10, default=0,
        order=2, visibleWhen='Style', visibleValues={1}},
    {id='Wheel2Size', type='integer', group='Wheel2', label='Size',
        min=25, max=200, step=5, suffix='%', default=100,
        order=3, visibleWhen='Style', visibleValues={1}},
    {id='Wheel2Opacity', type='integer', group='Wheel2', label='Opacity',
        min=0, max=100, step=5, suffix='%', default=100,
        order=4, visibleWhen='Style', visibleValues={1}},
}
local template = {
    name='Wheels',
    description='Swap wheels in place or display both at separate positions.',
    settings={target='module', enabled=true, groups={
        {id='Style',label='Style',heading=false,order=1},
        {id='Wheels',label='Wheels',order=2},
        {id='Wheel1',label='Wheel 1',order=3},
        {id='Wheel2',label='Wheel 2',order=4},
    }, fields=fields},
}


local function capture(widget)
    return {widget=widget, translation=Widget.translation(widget),
        scale=Widget.scale(widget), opacity=Widget.opacity(widget)}
end
local function restore(service, state)
    if not service:valid(state.switcher.widget) then return true end
    if state.moved then
        for _, wheel in ipairs(state.order) do
            local parent=service:parent(wheel)
            if parent then
                assert(service:same(parent,state.owner) or service:same(parent,state.switcher.widget),
                    'wheel moved by another owner')
                assert(parent:RemoveChild(wheel) ~= false, 'could not detach wheel for restoration')
            end
        end
        for index,wheel in ipairs(state.order) do
            assert(service:valid(state.switcher.widget:AddChild(wheel)), 'could not restore wheel')
            Widget.restoreSlot(wheel,state.slots[index])
        end
        state.switcher.widget:SetActiveWidgetIndex(state.activeIndex)
        state.moved=false
    end
    for _, record in ipairs({state.switcher,state.ability,state.consumable}) do
        assert(service:valid(record.widget), 'wheel unavailable for restoration')
        Widget.setTranslation(record.widget,record.translation.X,record.translation.Y)
        Widget.setScale(record.widget,record.scale.X,record.scale.Y)
        Widget.setOpacity(record.widget,record.opacity)
    end
    return true
end
local function appearance(record, settings, prefix, x, y)
    Widget.setTranslation(record.widget,x+settings[prefix..'X'],y+settings[prefix..'Y'])
    Widget.setScale(record.widget,settings[prefix..'Size']/100)
    Widget.setOpacity(record.widget,settings[prefix..'Opacity']/100)
end

function template:attach(service, switcher, settings, previous)
    local config={}
    for _,field in ipairs(fields) do
        local value=settings[field.id]
        if value == nil then value=field.default end
        assert(type(value)=='number' and value%1==0, 'invalid setting: '..field.id)
        if field.type=='picker' then
            assert(value==0 or value==1, 'invalid Style')
        else
            assert(value>=field.min and value<=field.max, 'setting outside range: '..field.id)
        end
        config[field.id]=value
    end
    settings=config
    if previous then
        local ok, why=pcall(restore,service,previous)
        if not ok then return nil,why end
    end
    if not service:valid(switcher) then return nil,'not_ready' end
    if switcher:GetChildrenCount()<2 then return nil,'not_ready' end
    local ok,state=pcall(function()
        assert(switcher:GetChildrenCount()==2, 'expected two native wheels')
        local ability,consumable
        local order={switcher:GetChildAt(0),switcher:GetChildAt(1)}
        for _,wheel in ipairs(order) do
            local class=service:identity(wheel):match('^(%S+)')
            if class=='WBP_AA_Quickslots_C' then ability=wheel end
            if class=='WBP_HUD_Quickslots_C' then consumable=wheel end
        end
        assert(service:valid(ability) and service:valid(consumable), 'native wheels unavailable')
        local owner=service:parent(switcher)
        assert(service:valid(owner), 'wheel container unavailable')
        return {switcher=capture(switcher),ability=capture(ability),consumable=capture(consumable),
            owner=owner,order=order,slots={Widget.snapshotSlot(order[1]),Widget.snapshotSlot(order[2])},
            activeIndex=switcher:GetActiveWidgetIndex(),moved=false}
    end)
    if not ok then return nil,state end
    local applied,why=pcall(function()
        if settings.Style == 0 then
            -- Both children use the same position; native controls select the visible wheel.
            local origin=state.ability.translation
            appearance(state.ability,settings,'Wheels',origin.X,origin.Y)
            appearance(state.consumable,settings,'Wheels',origin.X,origin.Y)
        else
            -- AF separates the ability wheel; the consumable wheel stays in its switcher.
            state.moved=true
            assert(switcher:RemoveChild(state.ability.widget) ~= false, 'could not separate wheel')
            assert(service:valid(state.owner:AddChild(state.ability.widget)), 'could not attach distant wheel')
            for _, item in ipairs({{state.ability,'Wheel1'},{state.consumable,'Wheel2'}}) do
                local record,prefix=item[1],item[2]
                local x,y=record.translation.X,record.translation.Y
                if not service:same(service:parent(record.widget),switcher) then
                    x,y=x+state.switcher.translation.X,y+state.switcher.translation.Y
                else
                    switcher:SetActiveWidget(record.widget)
                end
                appearance(record,settings,prefix,x,y)
            end
        end
    end)
    if not applied then
        local restored,err=pcall(restore,service,state)
        return nil,tostring(why)..(restored and '' or '; restoration failed: '..tostring(err))
    end
    return state
end
function template:render(service,state)
    if not service:valid(state.switcher.widget) or not service:valid(state.ability.widget)
        or not service:valid(state.consumable.widget) then return 'not_ready' end
    return 'applied'
end
function template:detach(service,state) return restore(service,state) end
return template
