local Entity_AI = {
    RANGE_TYPE = { MISC = 1, ORIGIN_CHECK = 2, HITBOX_OVERLAP = 3, HURTBOX = 4, SOLID_CHECK = 5 },
    is_dead = function(ent)
        return ent.health == 0
    end,
    targetting = {
        id_field = "chased_target_uid",
        timer_field = "target_selection_timer",
        timer_max = 60
    }
}
Entity_AI.__index = Entity_AI

function Entity_AI:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

return Entity_AI
