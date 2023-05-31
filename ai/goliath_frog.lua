return Entity_AI:new({
    id = "goliath_frog",
    name = "Goliath frog",
    ent_type = ENT_TYPE.MONS_GIANTFROG,
    ranges = {
        { -- Spawn
            shape = geometry.create_box_shape(-8, -4, 8, 4),
            is_active = function(ent)
                return ent.move_state == 0 and ent.attack_timer == 0
            end,
            label = "Spawn"
        }
    }
})
