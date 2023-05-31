-- TODO: Show the hurtboxes for the feet and thunder thighs.
return {
    Entity_AI:new({
        id = "hundun",
        name = "Hundun",
        ent_type = ENT_TYPE.MONS_HUNDUN,
        preprocess = function(ent, ctx)
            ctx.bird_ent = get_entity(ent.birdhead_entity_uid)
            ctx.snake_ent = get_entity(ent.snakehead_entity_uid)
            -- Hundun will not start to move while a head is attacking. A head will not start a bite if itself or the other head is already attacking. An "attack" is charging up a fireball and biting, but not the retreat after a bite.
            ctx.is_head_attacking = (ctx.bird_ent and ctx.bird_ent.move_state == 6) or (ctx.snake_ent and ctx.snake_ent.move_state == 6)
        end,
        ranges = {
            { -- Move left
                -- TODO: This draws over the entire screen. Make it fully transparent.
                shape = geometry.create_box_shape(-1000, -1000, 0, 1000),
                is_visible = function(ent)
                    return ent.move_state ~= 4
                end,
                is_active = function(ent, ctx)
                    -- TODO: Are the X limits based on the level width?
                    -- TODO: Hundun can get closer to the sides while walking. I think this is because it uses the same checks to start walking, but then doesn't cut off the walk movement like it does when jumping into the sides.
                    return ent.move_state == 0 and ent.bounce_timer == 0 and not ctx.is_head_attacking and ctx.ent_x >= 8
                end,
                label = "Move left",
                label_position = LABEL_POSITION.RIGHT
            },
            { -- Move right
                -- TODO: This draws over the entire screen. Make it fully transparent.
                shape = geometry.create_box_shape(0, -1000, 1000, 1000),
                is_visible = function(ent)
                    return ent.move_state ~= 4
                end,
                is_active = function(ent, ctx)
                    -- TODO: See comments for move left range.
                    return ent.move_state == 0 and ent.bounce_timer == 0 and not ctx.is_head_attacking and ctx.ent_x <= 28
                end,
                label = "Move right",
                label_position = LABEL_POSITION.LEFT
            },
            { -- Bite
                shape = geometry.create_circle_shape(6),
                is_visible = function(ent, ctx)
                    return ent.move_state ~= 4 and (ctx.bird_ent or ctx.snake_ent)
                end,
                is_active = function(ent, ctx)
                    -- For some reason, bounce_timer affects whether a bite attack can occur. If Hundun is up against a wall and can't move, then it gets randomized to a number around 120 after either head finishes an attack. If it's higher than 120, then it has to count down to at most 120 before a head can bite again. Otherwise, a head can bite again immediately if the other one isn't already attacking. This is why the bite timings during floor strats are inconsistent.
                    -- A head cannot attack during its spawn movement.
                    -- TODO: The bite attack is performed by whichever head is closest to the player, regardless of where the player is relative to Hundun. Should I try to depict this by splitting this range?
                    local are_all_heads_spawning = (not ctx.bird_ent or ctx.bird_ent.move_state == 2) and (not ctx.snake_ent or ctx.snake_ent.move_state == 2)
                    return ent.move_state == 0 and not ctx.is_head_attacking and not are_all_heads_spawning and ent.bounce_timer <= 120
                end,
                label = "Bite",
                label_position = LABEL_POSITION.TOP
            },
            { -- Fireball
                shape = geometry.create_box_shape(-1000, -1000, 1000, 1000),
                post_transform_shape = function(ent, ctx, shape)
                    -- TODO: Is this hard-coded, or based on something in the level? Hundun's y_level is an arbitrary value slightly above the spike floor when it's at the top. Seems to be hard-coded based on testing where I moved Hundun further up.
                    return shape:clip_bottom(101.5)
                end,
                is_visible = function(ent)
                    return ent.move_state ~= 4 and ent.hundun_flags & HUNDUNFLAGS.TOPLEVELARENAREACHED > 0
                end,
                is_active = function(ent)
                    return ent.fireball_timer == 0
                end,
                label = "Fireball",
                label_position = LABEL_POSITION.BOTTOM
            }
        }
    }),
    Entity_AI:new({
        id = "hundun_bird_head",
        name = "Hundun bird head",
        parent_id = "hundun",
        ent_type = ENT_TYPE.MONS_HUNDUN_BIRDHEAD,
        targetting = {
            id_field = "targeted_player_uid"
        }
    }),
    Entity_AI:new({
        id = "hundun_snake_head",
        name = "Hundun snake head",
        parent_id = "hundun",
        ent_type = ENT_TYPE.MONS_HUNDUN_SNAKEHEAD,
        targetting = {
            id_field = "targeted_player_uid"
        }
    })
}
