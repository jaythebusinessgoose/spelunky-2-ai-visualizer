return Entity_AI:new({
    id = "lahamu",
    name = "Lahamu",
    ent_type = ENT_TYPE.MONS_ALIENQUEEN,
    ranges = {
        { -- Attack
            shape = geometry.create_circle_shape(9),
            is_visible = function(ent)
                return ent.state == CHAR_STATE.STANDING
            end,
            is_active = function(ent)
                -- TODO: This doesn't convey the full mechanic. The timer counts down while the player is inside the range, and an attack is performed at 0.
                return ent.attack_cooldown_timer == 0
            end,
            label = "Attack"
        }
    }
})
