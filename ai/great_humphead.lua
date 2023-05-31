return Entity_AI:new({
    id = "great_humphead",
    name = "Great Humphead",
    ent_type = ENT_TYPE.MONS_GIANTFISH,
    ranges = {
        { -- Attack
            shape = geometry.create_box_shape(-12, -5, 12, 5),
            is_active = function(ent)
                return ent.state == 3 and ent.move_state == 0 and ent.lose_interest_timer == 0
            end,
            label = "Attack"
        }
    }
})
