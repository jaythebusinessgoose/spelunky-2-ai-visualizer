-- Punch is prioritized over all other actions.
return Entity_AI:new({
    id = "yeti_king",
    name = "Yeti king",
    ent_type = ENT_TYPE.MONS_YETIKING,
    ranges = {
        { -- Punch
            shape = geometry.create_box_shape(-1, 0, 1, 2),
            is_active = function(ent)
                return (ent.state == CHAR_STATE.STANDING or ent.state == CHAR_STATE.FALLING) and (ent.move_state == 0 or ent.move_state == 1)
            end,
            label = "Punch",
            label_position = LABEL_POSITION.TOP
        },
        { -- Punch hurtbox
            -- TODO: Same comments as yeti queen.
            shape = geometry.create_box_shape(-0.525, 0.45, 0.525, 1.45),
            type = Entity_AI.RANGE_TYPE.HURTBOX,
            is_active = function(ent)
                -- TODO: Same comments as yeti queen.
                return ent.move_state == 6
            end,
            label = "Punch hurtbox"
        },
        { -- Freeze
            shape = geometry.create_circle_shape(6):clip_left(0),
            flip_with_ent = true,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and (ent.move_state == 0 or ent.move_state == 1)
            end,
            label = "Freeze"
        },
        { -- Freeze hurtbox
            -- This is a hitbox overlap check. It's 2 tiles in front of the yeti king's hitbox and its height matches the king's hitbox.
            -- TODO: Shape starts at 0 width and gradually extends to 2 tiles during the attack?
            shape = geometry.create_box_shape(0.525, -0.93, 2.525, 0.45),
            flip_with_ent = true,
            type = Entity_AI.RANGE_TYPE.HURTBOX,
            is_active = function(ent)
                return ent.state == CHAR_STATE.ATTACKING and ent.move_state == 11
            end,
            label = "Freeze hurtbox"
        },
        { -- Active freeze hurtbox
            -- This is a hitbox overlap check. It's 2 tiles in front of the yeti king's hitbox and its height matches the king's hitbox.
            shape = function(ent)
                local damage_range = math.min(1, ent.idle_counter / 15.0) * 2
                return geometry.create_box_shape(ent.offsetx + ent.hitboxx, ent.offsety - ent.hitboxy, ent.offsetx + ent.hitboxx + damage_range, ent.offsety + ent.hitboxy)
            end,
            flip_with_ent = true,
            type = Entity_AI.RANGE_TYPE.HURTBOX,
            is_visible = function(ent)
                return ent.state == CHAR_STATE.ATTACKING and ent.move_state == 11 and ent.current_animation.id == 0x26
            end,
            label = " "
        },
        { -- Ice break hurtbox
            -- This is a hitbox overlap check. He can only break ice tiles that have empty space under them. Left is 1 tile in front of his hitbox, right is 7 tiles in front of his hitbox, bottom is the bottom of his hitbox, and top is 6 tiles above the top of his hitbox. Hitbox padding allows the ice floor below him to break. He cannot break thin ice tiles.
            shape = geometry.create_box_shape(1.525, -0.93, 7.525, 6.45),
            flip_with_ent = true,
            type = Entity_AI.RANGE_TYPE.HURTBOX,
            is_active = function(ent)
                -- TODO: Not sure when the ice break happens. Seems to be one specific frame of the attack.
                return ent.state == CHAR_STATE.ATTACKING and ent.move_state == 11
            end,
            label = "Ice break hurtbox"
        },
        { -- Turn
            shape = geometry.create_circle_shape(6):clip_right(0),
            flip_with_ent = true,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and (ent.move_state == 0 or ent.move_state == 1)
            end,
            label = "Turn"
        }
    }
})
