return Entity_AI:new({
    id = "sorceress",
    name = "Sorceress",
    ent_type = ENT_TYPE.MONS_SORCERESS,
    ranges = {
        { -- Attack
            shape = geometry.create_box_shape(-8, -4, 8, 4),
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and (ent.move_state == 0 or ent.move_state == 1) and ent.inbetween_attack_timer == 0
            end,
            label = "Attack"
        }
    }
})
