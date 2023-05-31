return Entity_AI:new({
    id = "jiangshi",
    name = "Jiangshi",
    ent_type = ENT_TYPE.MONS_JIANGSHI,
    ranges = {
        { -- Jump
            shape = geometry.create_circle_shape(8),
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and ent.move_state == 0 and ent.wait_timer == 0
            end,
            label = "Jump"
        }
    }
})
