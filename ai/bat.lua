return Entity_AI:new({
    id = "bat",
    name = "Bat",
    ent_type = ENT_TYPE.MONS_BAT,
    ranges = {
        { -- Aggro
            shape = geometry.create_circle_shape(6):clip_top(-0.2),
            is_visible = function(ent)
                return ent.state == CHAR_STATE.HANGING
            end,
            is_inactive_when_stuck = false,
            label = "Aggro"
        }
    }
})
