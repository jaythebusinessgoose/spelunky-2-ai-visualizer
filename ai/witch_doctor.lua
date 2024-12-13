return {
    Entity_AI:new({
        id = "witch_doctor",
        name = "Witch doctor",
        ent_type = ENT_TYPE.MONS_WITCHDOCTOR,
        targetting = {
            id_field = "chased_target_uid"
        },
        ranges = {
            { -- Attack
                shape = geometry.create_box_shape(0, -0.4, 6, 0.4),
                flip_with_ent = true,
                line_of_sight_checks = 6,
                is_active = function(ent)
                    -- TODO: When can the witch doctor can initiate another attack after just doing one? He can start another attack at some point during the finishing animation from the previous one.
                    return true
                end,
                label = "Attack"
            },
            { -- Chat
                shape = geometry.create_box_shape(0.5, -0.1, 1.5, 0.1),
                flip_with_ent = true,
                is_visible = function(ent)
                    return ent.move_state == 0 or ent.move_state == 1
                end,
                is_active = function(ent)
                    return ent.cooldown_timer == 0
                end,
                label = "Chat"
            }
        }
    }),
    Entity_AI:new({
        id = "witch_doctor_skull",
        name = "Witch doctor skull",
        parent_id = "witch_doctor",
        ent_type = ENT_TYPE.MONS_WITCHDOCTORSKULL,
        ranges = {
            { -- Chase
                -- The skull can move when partially transparent, but has no hurtbox unless it's fully opaque.
                shape = geometry.create_circle_shape(4),
                is_visible = function(ent)
                    -- TODO: Is this actually how the game determines whether the skull is active?
                    return ent.color.a > 0
                end,
                is_active = function(ent)
                    -- TODO: When does the skull get an active hurtbox?
                    return true
                end,
                label = "Chase",
            },
            { -- Orbit
                shape = geometry.create_donut_shape(1.3, 1.3),
                translate_shape = function(ent)
                    if ent.witch_doctor_uid >= 0 then
                        local x, y = get_position(ent.witch_doctor_uid)
                        return x, y
                    end
                end,
                is_visible = function(ent)
                    -- TODO: Is this actually how the game determines whether the skull is active? Does it care if the witch doctor exists?
                    return ent.color.a > 0 and ent.witch_doctor_uid >= 0
                end,
                label = "Orbit",
                label_position = LABEL_POSITION.TOP,
            }
        }
    })
}
