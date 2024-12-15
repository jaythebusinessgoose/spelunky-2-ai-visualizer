-- Lunge distance depends on how far away the player is at the end of the jump wind-up animation. She can't jump backwards, but can jump extremely far forwards and seems to try to land at your X position, ignoring height. The lunge has a horizontal limit of about 40 tiles.
-- TODO: Is the lunge distance constrained by the speed limit of 0.4 tiles per frame that most entities seem to have?
-- TODO: Does the lunge attack have any extra hitbox other than hers?
-- Punch is prioritized over all other actions.
return Entity_AI:new({
    id = "yeti_queen",
    name = "Yeti queen",
    ent_type = ENT_TYPE.MONS_YETIQUEEN,
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
            -- Width is the width of the yeti queen's hitbox, and the heights from the top of her hitbox to 1 tile above.
            shape = function(ent)
                local top = ent.offsety + ent.hitboxy
                return geometry.create_box_shape(ent.offsetx - ent.hitboxx, top, ent.offsetx + ent.hitboxx, top + 1)
            end,
            type = Entity_AI.RANGE_TYPE.HURTBOX,
            is_active = function(ent)
                -- TODO: Only seems to deal damage on the first frame. How do I detect this?
                -- ANSWER: Does it make sense to make it "active" during move_state 7 (the wind-up for the punch)?
                return ent.move_state == 6
            end,
            label = "Punch hurtbox"
        },
        { -- Lunge
            shape = geometry.create_box_shape(1, -0.5, 5, 2),
            flip_with_ent = true,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and (ent.move_state == 0 or ent.move_state == 1)
            end,
            label = "Lunge"
        },
        { -- Turn
            shape = geometry.create_box_shape(-5, -0.5, -1, 2),
            flip_with_ent = true,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and (ent.move_state == 0 or ent.move_state == 1)
            end,
            label = "Turn"
        }
    }
})
