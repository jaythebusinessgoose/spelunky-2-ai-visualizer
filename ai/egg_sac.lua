return Entity_AI:new({
    id = "egg_sac",
    name = "Egg sac",
    ent_type = ENT_TYPE.ITEM_EGGSAC,
    ranges = {
        { -- Aggro
            shape = geometry.create_circle_shape(2),
            is_visible = function(ent)
                return ent.move_state == 0 and not test_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
            end,
            label = "Aggro"
        }
    }
})
