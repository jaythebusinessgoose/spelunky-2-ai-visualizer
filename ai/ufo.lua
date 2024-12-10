-- TODO: Add the ranges that cause the UFO to move up or down.
return Entity_AI:new({
    id = "ufo",
    name = "UFO",
    ent_type = ENT_TYPE.MONS_UFO,
    ranges = {
        { -- Attack
            shape = geometry.create_box_shape(-0.5, -16, 0.5, 0),
            is_visible = function(ent)
                return ent.move_state ~= 4
            end,
            is_active = function(ent)
                return ent.move_state == 0 and ent.attack_cooldown_timer == 0
            end,
            label = "Attack"
        },
        { -- Rise
            shape = geometry.create_circle_shape(8):clip_bottom(0),
            is_visible = function(ent)
                return ent.move_state ~= 4 and not ent.is_falling
            end,
            is_active = function(ent)
                return ent.move_state == 0
            end,
            label = "Rise"
        },
        { -- Lower
            shape = geometry.create_circle_shape(8):clip_top(-4),
            is_visible = function(ent)
                return ent.move_state ~= 4 and not ent.is_falling
            end,
            is_active = function(ent)
                return ent.move_state == 0
            end,
            label = "Lower"
        },
        { -- Stop Rising
            shape = geometry.create_circle_shape(8):clip_top(-3),
            is_visible = function(ent)
                return ent.move_state ~= 4 and ent.is_falling
            end,
            is_active = function(ent)
                return ent.move_state == 0
            end,
            label = "Stop Rising"
        }
    }
})
