-- TODO: Jump range isn't active for some amount of time at the start of the cutscene. Seems like his behavior is scripted and he can't acquire a target until some condition is met. I don't know what this condition is, but it becomes true while in the air above the cavemen. Jump range should be visible, but not active, until this condition is met. He can pick the player as the first target instead of a caveman if the player is closer.
-- TODO: attack_timer <= 1 cases might be caused by Olmec being able to start an attack on the same frame that the conditions are met when attack_timer is actually 0. Most enemies seem to start attacking one frame after detecting that the conditions are met.
-- TODO: Draw lines for Olmec's phase change heights. I think they're hard-coded.
return Entity_AI:new({
    id = "olmec",
    name = "Olmec",
    ent_type = ENT_TYPE.ACTIVEFLOOR_OLMEC,
    is_dead = function(ent)
        return ent.attack_phase == 3
    end,
    targetting = {
        id_field = "target_uid",
        timer_field = "ai_timer",
        timer_max = "200",
    },
    ranges = {
        { -- Jump
            shape = geometry.create_circle_shape(10),
            is_visible = function(ent)
                return ent.attack_phase == 0 or ent.attack_phase == 2
            end,
            is_active = function(ent)
                return ent.move_state == 0 and ent.attack_timer <= 1 and ent.falling_timer == 0
            end,
            label = "Jump",
            label_position = LABEL_POSITION.LEFT
        },
        { -- Stomp
            shape = geometry.create_box_shape(-2, -1000, 2, 0),
            is_visible = function(ent)
                if ent.attack_phase == 0 or ent.attack_phase == 2 then
                    local target_ent = get_entity(ent.target_uid)
                    return target_ent and target_ent.type.id ~= ENT_TYPE.MONS_CAVEMAN
                end
                return false
            end,
            is_active = function(ent)
                return ent.move_state == 5 and ent.attack_timer == 0
            end,
            label = function(ent)
                -- TODO: Uncertain what this variable does. It starts at 0, gets set to 2 the first time the floaters are broken, and then switches to 3 after a UFO spawn stomp and back to 2 after a non-spawn stomp. It could be a bit mask. unknown_attack_state was 0/1 in a different fight where Olmec skipped phase 2 entirely, instead of 2/3.
                return (ent.attack_phase == 2 and ent.unknown_attack_state % 2 == 0 and #get_entities_by(ENT_TYPE.MONS_UFO, MASK.MONSTER, ent.layer) < 8) and "Stomp and spawn" or "Stomp"
            end,
            label_position = LABEL_POSITION.TOP
        },
        { -- Bomb
            shape = geometry.create_box_shape(-1000, -1000, 1000, 0),
            post_transform_shape = function(ent, ctx, shape)
                -- TODO: Is this constraint hard-coded?
                return shape:clip_right(41.5)
            end,
            is_visible = function(ent)
                return ent.attack_phase == 1
            end,
            is_active = function(ent)
                return ent.move_state == 9 and ent.attack_timer <= 1 and ent.phase1_amount_of_bomb_salvos > 0
            end,
            label = "Bomb",
            -- TODO: Gets shoved off screen when clipping the shape.
            label_position = LABEL_POSITION.TOP
        }
    }
})
