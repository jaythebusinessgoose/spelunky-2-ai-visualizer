local HITBOX_W_HALF = get_type(ENT_TYPE.MONS_FEMALE_JIANGSHI).hitboxx

return Entity_AI:new({
    id = "jiangshi_assassin",
    name = "Jiangshi assassin",
    ent_type = ENT_TYPE.MONS_FEMALE_JIANGSHI,
    ranges = {
        { -- Jump/flip (on floor)
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
        { -- Jump (on ceiling)
            shape = geometry.create_circle_shape(8),
            is_visible = function(ent)
                return ent.on_ceiling
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and ent.move_state == 0 and ent.wait_timer == 0
            end,
            label = "Jump"
        },
        { -- Flip (on ceiling, hitbox check)
            -- Flipping is prioritized over jumping.
            shape = geometry.create_box_shape(-HITBOX_W_HALF, -12, HITBOX_W_HALF, 0),
            type = Entity_AI.RANGE_TYPE.HITBOX_OVERLAP,
            is_visible = function(ent)
                return ent.on_ceiling
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and ent.move_state == 0
            end,
            label = "Flip"
        },
        { -- Flip (on ceiling, distance check)
            shape = geometry.create_box_shape(-1000, -1000, 1000, -12),
            is_visible = function(ent)
                return ent.on_ceiling
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and ent.move_state == 0
            end,
            label = "Flip",
            label_position = LABEL_POSITION.TOP
        },
        { -- Crawl (on floor, corridor check)
            shape = geometry.create_point_set_shape(Vec2:new(-HITBOX_W_HALF, 1), Vec2:new(HITBOX_W_HALF, 1)),
            type = Entity_AI.RANGE_TYPE.SOLID_CHECK,
            is_visible = function(ent)
                return not ent.on_ceiling
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and ent.move_state == 0
            end,
            label = "Crawl",
            -- TODO: This hack puts the label above the points.
            label_position = LABEL_POSITION.BOTTOM
        },
        { -- Flip (on ceiling, corridor check)
            shape = geometry.create_point_set_shape(Vec2:new(-HITBOX_W_HALF, -1), Vec2:new(HITBOX_W_HALF, -1)),
            type = Entity_AI.RANGE_TYPE.SOLID_CHECK,
            is_visible = function(ent)
                return ent.on_ceiling
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and ent.move_state == 0
            end,
            label = "Flip",
            -- TODO: This hack puts the label below the points.
            label_position = LABEL_POSITION.TOP
        }
    }
})
