local Widget = require('te.widget')

local template = {
    name = 'Dual Wheels',
    description = 'Two always-visible action wheels with a separate input for every existing slot.',
    detachSecondaryWheel = true,
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

local function snapshot(service, switcher, shared)
    assert(service:valid(switcher), 'quickslots switcher unavailable')
    assert(type(shared)=='table' and shared.moved and service:same(shared.switcher,switcher),
        'quickslots category must separate the native wheels first')
    local hud = assert(shared.hud, 'game HUD unavailable')
    local ability,consumable = shared.ability,shared.consumable
    assert(service:valid(ability) and service:valid(consumable), 'native wheels unavailable')
    local prompt = Widget.property(hud,'WBP_HUD_Quickslots_ChangePrompt')
    if not service:valid(prompt) then prompt = nil end
    return {
        switcher=switcher, ability=ability, consumable=consumable,
        primary=shared.primary, secondary=shared.secondary,
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
    assert(service:valid(state.ability) and service:valid(state.consumable),
        'native wheels unavailable for visual restoration')
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
    return true
end

local function apply(service,state,config)
    local primary=config.primaryWheel==1 and state.ability or state.consumable
    local secondary=config.primaryWheel==1 and state.consumable or state.ability
    assert(service:same(primary,state.primary) and service:same(secondary,state.secondary),
        'quickslots category selected different wheel order')
    assert(service:same(service:parent(primary),state.switcher)
        and not service:same(service:parent(secondary),state.switcher),
        'quickslots category did not separate the secondary wheel')
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

function template:attach(service,switcher,configuration,previous,shared)
    if configuration.access ~= nil and configuration.access ~= 0 and configuration.access ~= 2 then
        return nil, 'Dual Wheels requires Individual or Advanced direct slot input'
    end
    local config=settings(configuration)
    if previous then
        local ok,err=pcall(restore,service,previous)
        if not ok then return nil,err end
    end
    local ok,state=pcall(snapshot,service,switcher,shared)
    if not ok then return nil,state end
    local applied,err=pcall(apply,service,state,config)
    if not applied then
        local restored,restoreError=pcall(restore,service,state)
        if not restored then
            return nil,tostring(err) .. '; restoration failed: ' .. tostring(restoreError)
        end
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

