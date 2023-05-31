return Entity_AI:new({
    id = "robot",
    name = "Robot",
    ent_type = ENT_TYPE.MONS_ROBOT,
    targetting = false,
    ranges = {
        { -- Attack
            shape = geometry.create_box_shape(0, -0.4, 6, 0.4),
            flip_with_ent = true,
            is_blocked_by_solids = true,
            is_visible = function(ent)
                return ent.move_state ~= 9
            end,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            label = "Attack"
        }
    }
})
