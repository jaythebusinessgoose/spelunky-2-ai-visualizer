return Entity_AI:new({
    id = "ammit",
    name = "Ammit",
    ent_type = ENT_TYPE.MONS_AMMIT,
    ranges = {
        { -- Attack
            shape = geometry.create_box_shape(0, -0.4, 8, 0.4),
            flip_with_ent = true,
            line_of_sight_checks = 8,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            label = "Attack"
        }
    }
})
