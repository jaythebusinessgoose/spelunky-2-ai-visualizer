-- TODO: There is a range which seems to be a 12x12 square where the move_state changes to 6, which just makes the vampire never stop walking. When not in this move_state, it walks and stops like most other walking monsters. Vlad's version of this range seems to be a 20x20 square.
return Entity_AI:new({
    id = "vampire",
    name = "Vampire & Vlad",
    ent_type = { ENT_TYPE.MONS_VAMPIRE, ENT_TYPE.MONS_VLAD },
    ranges = {
        { -- Aggro
            shape = geometry.create_circle_shape(6):clip_top(-0.2),
            is_visible = function(ent)
                return ent.state == CHAR_STATE.HANGING
            end,
            label = "Aggro"
        },
        { -- No land
            shape = geometry.create_circle_shape(6),
            is_visible = function(ent)
                return ent.move_state == 9
            end,
            label = "No land"
        },
        { -- Jump
            shape = geometry.create_circle_shape(6):clip_top(3),
            is_visible = function(ent)
                return ent.state == CHAR_STATE.STANDING or ent.state == CHAR_STATE.FALLING
            end,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1 or ent.move_state == 6
            end,
            label = "Jump"
        },
        { -- Fly
            shape = geometry.create_circle_shape(6):clip_bottom(3),
            is_visible = function(ent)
                return ent.state == CHAR_STATE.STANDING or ent.state == CHAR_STATE.FALLING
            end,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1 or ent.move_state == 6
            end,
            label = "Fly"
        }
    }
})
