return Entity_AI:new({
    id = "mummy",
    name = "Mummy",
    ent_type = ENT_TYPE.MONS_MUMMY,
    ranges = {
        { -- Attack
            shape = geometry.create_circle_shape(8):clip_box(0, -2, nil, 2),
            flip_with_ent = true,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            label = "Attack"
        },
        { -- Turn
            shape = geometry.create_circle_shape(8):clip_box(nil, -2, 0, 2),
            flip_with_ent = true,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            label = "Turn"
        }
    }
})
