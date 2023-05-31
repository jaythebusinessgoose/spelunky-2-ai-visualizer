return Entity_AI:new({
    id = "bee",
    name = "Bee & queen bee",
    ent_type = { ENT_TYPE.MONS_BEE, ENT_TYPE.MONS_QUEENBEE },
    ranges = {
        { -- Aggro
            shape = geometry.create_circle_shape(6),
            is_visible = function(ent)
                return ent.move_state == 0 or ent.move_state == 8 or ent.move_state == 9
            end,
            is_active = function(ent)
                -- The fly_hang_timer variable also seems to control when the bee will notice a player while flying.
                return ent.move_state == 8 or ent.move_state == 9 or ent.fly_hang_timer == 0 or ent.fly_hang_timer == 1
            end,
            label = "Aggro"
        }
    }
})
