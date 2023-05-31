return Entity_AI:new({
    id = "firefly",
    name = "Firefly",
    ent_type = ENT_TYPE.MONS_CRITTERFIREFLY,
    ranges = {
        { -- Move away
            shape = geometry.create_circle_shape(4),
            is_active = function(ent)
                return ent.move_state == 9
            end,
            label = "Move away"
        }
    }
})
