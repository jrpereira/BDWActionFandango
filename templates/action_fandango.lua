local Widget = require('te.widget')

local template = {
    name = 'Action Fandango',
    version = '0.1.0',
    description = 'Two always-visible action wheels with a separate input for every existing slot.',
    category = 'player.quickslots',
    single = true,
    settings = {
        target = 'module',
        enabled = true,
        groups = {
            {id='Layout', label='Layout', level=4},
            {id='Primary', label='Primary Wheel', level=4},
            {id='Secondary', label='Secondary Wheel', level=4},
        },
        fields = {
            {id='Arrangement', type='picker', group='Layout', label='Arrangement',
                description='Place both action wheels vertically or side by side.',
                values={0,1}, labels={'Stacked','Side by side'}, default=0, tab=true, level=4, order=1},
            {id='PrimaryWheel', type='picker', group='Layout', label='Primary Wheel',
                description='Choose which group occupies the primary position. Inputs stay with their skills.',
                values={0,1}, labels={'Consumables','Abilities'}, default=0, tab=true, level=4, order=2},
            {id='X', type='integer', group='Layout', label='X', description='Primary wheel horizontal offset.',
                min=-1000, max=1000, step=10, default=20, order=3},
            {id='Y', type='integer', group='Layout', label='Y', description='Primary wheel vertical offset.',
                min=-1000, max=1000, step=10, default=40, order=4},
            {id='Gap', type='integer', group='Layout', label='Spacing',
                description='Distance between the two action wheels.',
                min=100, max=800, step=10, default=360, order=5},
            {id='PrimarySize', type='integer', group='Primary', label='Size',
                min=25, max=200, step=5, suffix='%', default=100, order=1},
            {id='PrimaryOpacity', type='integer', group='Primary', label='Opacity',
                min=0, max=100, step=5, suffix='%', default=100, order=2},
            {id='SecondarySize', type='integer', group='Secondary', label='Size',
                min=25, max=200, step=5, suffix='%', default=75, order=1},
            {id='SecondaryOpacity', type='integer', group='Secondary', label='Opacity',
                min=0, max=100, step=5, suffix='%', default=85, order=2},
        },
    },
}

local function settings(configuration)
    local source = configuration.settings or {}
    local function integer(name, default, minimum, maximum)
        local value = source[name]
        if value == nil then value = default end
        assert(type(value) == 'number' and value % 1 == 0 and value >= minimum and value <= maximum,
            'invalid Action Fandango setting: ' .. name)
        return value
    end
    return {
        arrangement=integer('Arrangement',0,0,1), primaryWheel=integer('PrimaryWheel',0,0,1),
        x=integer('X',20,-1000,1000), y=integer('Y',40,-1000,1000), gap=integer('Gap',360,100,800),
        primarySize=integer('PrimarySize',100,25,200),
        primaryOpacity=integer('PrimaryOpacity',100,0,100),
        secondarySize=integer('SecondarySize',75,25,200),
        secondaryOpacity=integer('SecondaryOpacity',85,0,100),
    }
end

local function owningHud(service, switcher)
    local node = switcher
    for _=1,20 do
        if not service:valid(node) then return nil end
        local name = service:identity(node)
        if name:find('WBP_GameHUD_C',1,true) then return node end
        node = service:parent(node)
    end
end

local function snapshot(service, switcher)
    assert(service:valid(switcher), 'quickslots switcher unavailable')
    assert(switcher:GetChildrenCount() == 2, 'quickslots switcher must have two native wheels')
    local hud = assert(owningHud(service,switcher), 'game HUD unavailable')
    local ability = assert(Widget.property(hud,'WBP_AA_Quickslots'), 'ability wheel unavailable')
    local consumable = assert(Widget.property(hud,'WBP_HUD_Quickslots'), 'consumable wheel unavailable')
    assert(service:valid(ability) and service:valid(consumable), 'native wheels unavailable')
    local first, second = switcher:GetChildAt(0), switcher:GetChildAt(1)
    assert((service:same(first,ability) and service:same(second,consumable))
        or (service:same(first,consumable) and service:same(second,ability)),
        'native wheel order changed')
    local owner = assert(service:parent(switcher), 'quickslots switcher parent unavailable')
    local prompt = Widget.property(hud,'WBP_HUD_Quickslots_ChangePrompt')
    if not service:valid(prompt) then prompt = nil end
    return {
        switcher=switcher, owner=owner, ability=ability, consumable=consumable,
        order={first,second}, slots={Widget.snapshotSlot(first),Widget.snapshotSlot(second)},
        activeIndex=switcher:GetActiveWidgetIndex(),
        switcherTranslation=Widget.translation(switcher),
        abilityTranslation=Widget.translation(ability),
        consumableTranslation=Widget.translation(consumable),
        abilityScale=Widget.scale(ability), consumableScale=Widget.scale(consumable),
        abilityOpacity=Widget.opacity(ability), consumableOpacity=Widget.opacity(consumable),
        prompt=prompt, promptOpacity=prompt and Widget.opacity(prompt) or nil,
    }
end

local function restore(service, state)
    if not service:valid(state.switcher) then return true end
    assert(service:valid(state.owner) and service:valid(state.ability)
        and service:valid(state.consumable), 'wheel hierarchy changed before restoration')
    for index=0,state.switcher:GetChildrenCount()-1 do
        local child=state.switcher:GetChildAt(index)
        assert(service:same(child,state.ability) or service:same(child,state.consumable),
            'another mod changed switcher children')
    end
    for _,wheel in ipairs(state.order) do
        local parent=service:parent(wheel)
        if parent then
            assert(service:same(parent,state.switcher) or service:same(parent,state.owner),
                'another mod moved a wheel')
            assert(parent:RemoveChild(wheel) ~= false, 'failed to detach wheel for restoration')
        end
    end
    for index,wheel in ipairs(state.order) do
        assert(service:valid(state.switcher:AddChild(wheel)), 'failed to restore wheel')
        Widget.restoreSlot(wheel,state.slots[index])
    end
    Widget.setTranslation(state.switcher,state.switcherTranslation.X,state.switcherTranslation.Y)
    Widget.setTranslation(state.ability,state.abilityTranslation.X,state.abilityTranslation.Y)
    Widget.setTranslation(state.consumable,state.consumableTranslation.X,state.consumableTranslation.Y)
    Widget.setScale(state.ability,state.abilityScale.X,state.abilityScale.Y)
    Widget.setScale(state.consumable,state.consumableScale.X,state.consumableScale.Y)
    Widget.setOpacity(state.ability,state.abilityOpacity)
    Widget.setOpacity(state.consumable,state.consumableOpacity)
    if state.prompt and service:valid(state.prompt) then
        Widget.setOpacity(state.prompt,state.promptOpacity)
    end
    state.switcher:SetActiveWidgetIndex(state.activeIndex)
    return true
end

local function apply(service,state,config)
    local primary=config.primaryWheel==1 and state.ability or state.consumable
    local secondary=config.primaryWheel==1 and state.consumable or state.ability
    assert(service:same(service:parent(primary),state.switcher)
        and service:same(service:parent(secondary),state.switcher),
        'native quickslots wheels are no longer switcher children')
    assert(state.switcher:RemoveChild(secondary) ~= false, 'cannot separate secondary wheel')
    assert(service:valid(state.owner:AddChild(secondary)), 'cannot display secondary wheel')
    state.switcher:SetActiveWidget(primary)
    Widget.setTranslation(primary,0,0)
    Widget.setTranslation(state.switcher,config.x,config.y)
    local sx,sy=config.x,config.y-config.gap
    if config.arrangement==1 then sx,sy=config.x+config.gap,config.y end
    Widget.setTranslation(secondary,sx,sy)
    Widget.setScale(primary,config.primarySize/100)
    Widget.setScale(secondary,config.secondarySize/100)
    Widget.setOpacity(primary,config.primaryOpacity/100)
    Widget.setOpacity(secondary,config.secondaryOpacity/100)
    if state.prompt then Widget.setOpacity(state.prompt,0) end
    state.primary, state.secondary = primary,secondary
end

function template:attach(service,switcher,configuration,previous)
    if configuration.access ~= nil and configuration.access ~= 0 then
        return nil, 'Action Fandango requires one key per slot for separate skills'
    end
    local config=settings(configuration)
    if previous then
        local ok,err=pcall(restore,service,previous)
        if not ok then return nil,err end
    end
    local ok,state=pcall(snapshot,service,switcher)
    if not ok then return nil,state end
    local applied,err=pcall(apply,service,state,config)
    if not applied then
        pcall(restore,service,state)
        return nil,err
    end
    return state
end

function template:render(service,state,target,reason)
    if not service:valid(state.switcher) then return 'not_ready' end
    if target and not service:same(target,state.switcher) then return 'ignored' end
    return 'applied'
end

function template:detach(service,state,reason)
    return restore(service,state)
end

return template
