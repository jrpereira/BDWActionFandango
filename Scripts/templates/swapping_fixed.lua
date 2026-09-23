local template = {
    name = 'Swapping Fixed',
    description = 'Keep one native wheel and let the secondary group key return to Abilities on its next tap.',
    settings = {
        target = 'module',
        enabled = true,
        groups = {{id='Behavior', label='Behavior', level=4}},
        fields = {{id='PrimaryWheel', type='picker', group='Behavior', label='Default Wheel',
            description='Abilities supports the one-key return. Consumables needs a TE group-order update.',
            values={1,0}, labels={'Abilities','Consumables (pending)'}, default=1,
            tab=true, level=4, order=1}},
    },
}

local function validate(configuration)
    if configuration.access ~= 1 then
        return nil, 'Swapping Fixed requires Activate group first input'
    end
    if not configuration.settings or configuration.settings.PrimaryWheel ~= 1 then
        return nil, 'Swapping Fixed currently requires Abilities as the default wheel'
    end
    local groups = configuration.groups or {}
    local ability, consumable = groups['1'], groups['2']
    if not ability or ability.mode ~= -1 then
        return nil, 'set Abilities group to Default'
    end
    if not consumable or consumable.mode ~= 0 or not consumable.key or consumable.key == 0 then
        return nil, 'bind a Tap key for the Consumables group'
    end
    return true
end

function template:attach(service, switcher, configuration, previous, shared)
    local ready,why = validate(configuration)
    if not ready then return nil,why end
    if not service:valid(switcher) or switcher:GetChildrenCount() ~= 2 then
        return nil,'native quickslots switcher unavailable'
    end
    if type(shared) ~= 'table' or not service:same(shared.switcher, switcher) then
        return nil,'quickslots category handle unavailable'
    end
    local ability = shared.ability
    if not service:valid(ability) or not service:same(service:parent(ability),switcher) then
        return nil,'native Ability wheel unavailable'
    end
    local state
    if previous and service:same(previous.switcher,switcher) then
        state=previous
    else
        state={switcher=switcher,originalIndex=switcher:GetActiveWidgetIndex()}
    end
    local ok,err=pcall(function() switcher:SetActiveWidget(ability) end)
    if not ok then return nil,err end
    return state
end

function template:render(service,state,target,reason)
    if not service:valid(state.switcher) then return 'not_ready' end
    if target and not service:same(target,state.switcher) then return 'ignored' end
    return 'applied'
end

function template:detach(service,state,reason)
    if not service:valid(state.switcher) then return true end
    local ok,err=pcall(function() state.switcher:SetActiveWidgetIndex(state.originalIndex) end)
    if not ok then return nil,err end
    return true
end

return template
