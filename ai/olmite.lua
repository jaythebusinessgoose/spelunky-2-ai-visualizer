-- TODO: Olmites in short corridors apparently turn to move towards their target if they have one and that target is less than 4 tiles away.
return Entity_AI:new({
    id = "olmite",
    name = "Olmite",
    ent_type = { ENT_TYPE.MONS_OLMITE_BODYARMORED, ENT_TYPE.MONS_OLMITE_HELMET, ENT_TYPE.MONS_OLMITE_NAKED },
    ranges = {
        { -- Jump
            shape = geometry.create_box_shape(0, -0.4, 3, 0.4),
            flip_with_ent = true,
            is_blocked_by_solids = true,
            is_visible = function(ent)
                return not ent.in_stack
            end,
            is_active = function(ent)
                -- TODO: attack_cooldown_timer is normally 0-60, but breaking an olmite stack can produce an olmite with a timer > 60 that never decrements. An olmite in this state can jump immediately and will fix its timer after landing.
                return (ent.move_state == 0 or ent.move_state == 1) and ent.attack_cooldown_timer == 0
            end,
            label = "Jump"
        },
        { -- Stomp
            shape = geometry.create_box_shape(-0.4, -1000, 0.4, 0),
            is_visible = function(ent)
                return ent.move_state == 2 or ent.move_state == 4
            end,
            is_active = function(ent)
                return ent.move_state == 2
            end,
            label = "Stomp",
            label_position = LABEL_POSITION.TOP
        }
    }
})
