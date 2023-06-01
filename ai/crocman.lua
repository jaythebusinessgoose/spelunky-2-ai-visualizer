return Entity_AI:new({
    id = "crocman",
    name = "Crocman",
    ent_type = ENT_TYPE.MONS_CROCMAN,
    targetting = false,
    ranges = {
        { -- Aggro
            shape = geometry.create_box_shape(0, -0.4, 6, 0.4),
            flip_with_ent = true,
            line_of_sight_checks = 6,
            is_visible = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            label = "Aggro"
        }
    }
})
