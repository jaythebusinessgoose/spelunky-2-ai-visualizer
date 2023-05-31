-- TODO: Approaches player from any distance outside the attack range. Should I bother depicting this?
return Entity_AI:new({
    id = "anubis",
    name = "Anubis",
    ent_type = ENT_TYPE.MONS_ANUBIS,
    ranges = {
        { -- Wake
            shape = geometry.create_circle_shape(5),
            is_visible = function(ent)
                return ent.move_state == 0
            end,
            label = "Wake"
        },
        { -- Attack
            shape = geometry.create_circle_shape(8),
            is_visible = function(ent)
                return ent.move_state == 6
            end,
            is_active = function(ent)
                return ent.state == 3 and ent.next_attack_timer == 0
            end,
            label = "Attack",
            label_position = LABEL_POSITION.TOP
        },
        { -- Retreat
            shape = geometry.create_circle_shape(4),
            is_visible = function(ent)
                return ent.move_state == 6
            end,
            label = "Retreat",
            label_position = LABEL_POSITION.TOP
        }
    }
})
