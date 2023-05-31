return Entity_AI:new({
    id = "imp",
    name = "Imp",
    ent_type = ENT_TYPE.MONS_IMP,
    ranges = {
        { -- Aggro
            shape = geometry.create_circle_shape(8):clip_box(-0.5, nil, 0.5, 0),
            is_visible = function(ent)
                return ent.carrying_uid >= 0
            end,
            is_inactive_when_stuck = false,
            label = "Aggro",
        }
    }
})
