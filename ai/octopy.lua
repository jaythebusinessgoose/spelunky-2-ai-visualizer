return Entity_AI:new({
    id = "octopy",
    name = "Octopy",
    ent_type = ENT_TYPE.MONS_OCTOPUS,
    ranges = {
        { -- Ink
            shape = geometry.create_box_shape(0, -0.4, 6, 0.4),
            flip_with_ent = true,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            label = "Ink"
        },
        { -- Jump
            shape = geometry.create_box_shape(-1, 1, 1, 4),
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1 or ent.move_state == 5
            end,
            label = "Jump"
        }
    }
})
