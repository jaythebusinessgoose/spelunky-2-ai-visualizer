-- TODO: Detect when Quillback is turning
-- TODO: Stomp shape
-- TODO: He switches to the stomping state if you are behind him while he is falling, even if the fall wasn't caused by him jumping at the player. Doesn't matter if you're above or below him. Haven't checked ranges on this behavior.
-- TODO: If he is falling for any reason and you enter the roll range in front of him, he will start to roll in mid air.
-- TODO: If he is falling for any reason and you enter the jump range in front of him, he will gain forward velocity.
-- TODO: Player position sort of influences his hops when stuck on a single tile.
return Entity_AI:new({
    id = "quillback",
    name = "Quillback",
    ent_type = ENT_TYPE.MONS_CAVEMAN_BOSS,
    targetting = {
        id_field = "chased_target_uid"
    },
    ranges = {
        { -- Jump
            shape = geometry.create_circle_shape(5):clip_box(0, -2, nil, 2),
            flip_with_ent = true,
            is_active = function(ent)
                -- TODO
                return true
            end,
            label = "Jump"
        },
        { -- Turn
            shape = geometry.create_circle_shape(5):clip_box(nil, -2, 0, 2),
            flip_with_ent = true,
            is_active = function(ent)
                -- TODO
                return true
            end,
            label = "Turn"
        },
        { -- Roll
            shape = geometry.create_donut_shape(5, 12):clip_box(0, -2, nil, 2),
            flip_with_ent = true,
            is_active = function(ent)
                -- TODO
                return true
            end,
            label = "Roll"
        },
        { -- Stomp
            shape = geometry.create_box_shape(-1000, -1000, 0, 1000),
            flip_with_ent = true,
            is_visible = function(ent)
                return ent.move_state == 2
            end,
            is_active = function(ent)
                return ent.chased_target_uid ~= -1
            end,
            label = "Stomp",
            label_position = LABEL_POSITION.RIGHT,
        }
    }
})
