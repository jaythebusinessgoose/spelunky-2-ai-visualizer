return Entity_AI:new({
    id = "anubis_2",
    name = "Anubis II",
    ent_type = ENT_TYPE.MONS_ANUBIS2,
    ranges = {
        { -- Attack
            shape = geometry.create_circle_shape(4.5),
            is_active = function(ent)
                return ent.state == 3 and ent.next_attack_timer == 0
            end,
            label = "Attack",
            label_position = LABEL_POSITION.TOP
        },
        { -- Retreat
            shape = geometry.create_circle_shape(4),
            label = "Retreat",
            label_position = LABEL_POSITION.TOP
        }
    }
})
