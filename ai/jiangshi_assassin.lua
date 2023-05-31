-- Assassins in a 1 tile high space will flip upright immediately and move forward until they escape the tight space, ignoring any targets.
-- TODO: Why is this value so weird? Is it some kind of hitbox check instead of an origin check?
local JIANGSHI_ASSASSIN_FLIP_HALF_WIDTH = 0.5555
return Entity_AI:new({
    id = "jiangshi_assassin",
    name = "Jiangshi assassin",
    ent_type = ENT_TYPE.MONS_FEMALE_JIANGSHI,
    ranges = {
        { -- Jump (floor)
            shape = geometry.create_circle_shape(8),
            is_visible = function(ent)
                return not ent.on_ceiling
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and ent.move_state == 0 and ent.wait_timer == 0
            end,
            label = function(ent)
                return ent.jump_counter == 0 and "Flip" or "Jump"
            end
        },
        { -- Jump (ceiling)
            shapes = {
                geometry.create_circle_shape(8):clip_right(-JIANGSHI_ASSASSIN_FLIP_HALF_WIDTH),
                geometry.create_circle_shape(8):clip_left(JIANGSHI_ASSASSIN_FLIP_HALF_WIDTH),
                geometry.create_circle_shape(8):clip_box(-JIANGSHI_ASSASSIN_FLIP_HALF_WIDTH, 0, JIANGSHI_ASSASSIN_FLIP_HALF_WIDTH, nil)
            },
            is_visible = function(ent)
                return ent.on_ceiling
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and ent.move_state == 0 and ent.wait_timer == 0
            end,
            label = "Jump"
        },
        { -- Flip (ceiling, narrow)
            shape = geometry.create_box_shape(-JIANGSHI_ASSASSIN_FLIP_HALF_WIDTH, -12, JIANGSHI_ASSASSIN_FLIP_HALF_WIDTH, 0),
            is_visible = function(ent)
                return ent.on_ceiling
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and ent.move_state == 0
            end,
            label = "Flip"
        },
        { -- Flip (ceiling, wide)
            shape = geometry.create_box_shape(-1000, -1000, 1000, -12),
            is_visible = function(ent)
                return ent.on_ceiling
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and ent.move_state == 0
            end,
            label = "Flip",
            label_position = LABEL_POSITION.TOP
        }
    }
})
