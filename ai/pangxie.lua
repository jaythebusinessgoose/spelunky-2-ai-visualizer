-- TODO: Bubble attack takes priority over claw and turn. Adjust the shapes to not overlap.
-- TODO: Can't attack while turning.
return Entity_AI:new({
    id = "pangxie",
    name = "Pangxie",
    ent_type = ENT_TYPE.MONS_CRABMAN,
    ranges = {
        { -- Bubble
            shape = geometry.create_box_shape(-1.5, 0, 1.5, 2.5),
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            label = "Bubble"
        },
        { -- Claw
            shape = geometry.create_box_shape(1, -0.5, 5, 1),
            flip_with_ent = true,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            label = "Claw"
        },
        { -- Turn
            shape = geometry.create_box_shape(-5, -0.5, -1, 1),
            flip_with_ent = true,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            label = "Turn"
        }
    }
})
