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
        }
    }
})
