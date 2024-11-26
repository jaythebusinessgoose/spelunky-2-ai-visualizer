-- TODO: Targetting should be dimmed or hidden after detaching from wall.
return Entity_AI:new({
    id = "grub",
    name = "Grub",
    ent_type = ENT_TYPE.MONS_GRUB,
    ranges = {
        { -- Attack
            shape = geometry.create_circle_shape(3),
            is_visible = function(ent)
                return ent.move_state == 0 or ent.move_state == 10
            end,
            is_active = function(ent)
                return ent.move_state == 0
            end,
            label = "Attack"
        },
        { -- Turn to fly (backwall)
            shape = geometry.create_box_shape(-1, -1, 1, 1),
            is_visible = function(ent)
                return ent.move_state == 0 and ent.turn_into_fly_timer ~= -1
            end,
            is_active = function(ent)
                return ent.turn_into_fly_timer == 0
            end,
            label = "Turn to fly blockers",
            label_position = LABEL_POSITION.TOP
        },
        { -- Turn to fly (floor)
            shape = geometry.create_box_shape(-1, 0, 1, 2),
            is_visible = function(ent)
                return ent.move_state == 9 and ent.turn_into_fly_timer ~= -1
            end,
            is_active = function(ent)
                return ent.turn_into_fly_timer == 0
            end,
            label = "Turn to fly blockers",
            label_position = LABEL_POSITION.TOP
        }
    }
})
