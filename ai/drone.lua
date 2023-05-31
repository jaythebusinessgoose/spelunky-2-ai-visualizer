return Entity_AI:new({
    id = "drone",
    name = "Drone",
    ent_type = ENT_TYPE.MONS_CRITTERDRONE,
    ranges = {
        { -- Move away
            shape = geometry.create_circle_shape(2),
            is_active = function(ent)
                return ent.move_timer == 0
            end,
            label = function(ent)
                return ent.unfriendly and "Move away" or "Approach"
            end
        }
    }
})
