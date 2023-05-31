return Entity_AI:new({
    id = "locust",
    name = "Locust",
    ent_type = ENT_TYPE.MONS_CRITTERLOCUST,
    ranges = {
        { -- Jump away
            -- When standing or jumping (but not falling) within this range, clamp jump_timer to a maximum of 4.
            -- When jumping from within this range, always jump away from the target.
            shape = geometry.create_circle_shape(1),
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING or ent.state == CHAR_STATE.JUMPING
            end,
            label = "Jump away"
        }
    }
})
