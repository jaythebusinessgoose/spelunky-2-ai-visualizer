local HITBOX_H_HALF = get_type(ENT_TYPE.MONS_LAVAMANDER).hitboxx

return Entity_AI:new({
    id = "lavamander",
    name = "Lavamander",
    ent_type = ENT_TYPE.MONS_LAVAMANDER,
    ranges = {
        { -- Aggro
            -- Once the lavamander sees the player in its aggro range, it will switch to attack mode. It will rise as long as the player is in the attack range, and will attack if it reaches the surface of the lava. It will deaggro after a short time if it isn't able to attack, though it will appear to keep attacking if the player is within the aggro/attack overlap since it immediately reaggros. The first time it surfaces, it will stare at the player for a moment instead of attacking.
            shape = geometry.create_circle_shape(8):clip_box(nil, -1, nil, 4),
            is_visible = function(ent)
                return ent.is_hot
            end,
            is_active = function(ent)
                return ent.state == 3 and (ent.move_state == 0 or ent.move_state == 1) and ent.shoot_lava_timer == 0
            end,
            label = function(ent)
                return ent.player_detect_state == 0 and "Rise and stare" or "Rise and attack"
            end,
        },
        { -- Jump
            shape = geometry.create_circle_shape(8):clip_left(0),
            flip_with_ent = true,
            is_visible = function(ent)
                return not ent.is_hot
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and (ent.move_state == 0 or ent.move_state == 1) and ent.jump_pause_timer == 0
            end,
            label = "Jump"
        },
        { -- Turn
            shape = geometry.create_circle_shape(8):clip_right(0),
            flip_with_ent = true,
            is_visible = function(ent)
                return not ent.is_hot
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and (ent.move_state == 0 or ent.move_state == 1) and ent.jump_pause_timer == 0
            end,
            label = "Turn"
        },
        { -- Lava checks
            -- Top check is used to stop the lavamander rising during the attack. Both are used to check if the lavamander is in lava and should
            -- heat/cool.
            shape = geometry.create_point_set_shape(Vec2:new(0, HITBOX_H_HALF / 2), Vec2:new(0, -HITBOX_H_HALF / 2)),
            type = Entity_AI.RANGE_TYPE.SOLID_CHECK,
            label = "Lava Checks",
            label_position = LABEL_POSITION.BOTTOM
        },
    }
})
