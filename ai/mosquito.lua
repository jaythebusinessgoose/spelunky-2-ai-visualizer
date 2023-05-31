return Entity_AI:new({
    id = "mosquito",
    name = "Mosquito",
    ent_type = ENT_TYPE.MONS_MOSQUITO,
    targetting = false,
    ranges = {
        { -- Attack
            shape = geometry.create_box_shape(0, -0.2, 10, 0.2),
            flip_with_ent = true,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 9
            end,
            label = "Attack"
        }
    }
})
