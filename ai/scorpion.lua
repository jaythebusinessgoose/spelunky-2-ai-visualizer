return Entity_AI:new({
    id = "scorpion",
    name = "Scorpion",
    ent_type = ENT_TYPE.MONS_SCORPION,
    ranges = {
        { -- Attack
            shape = geometry.create_box_shape(0.6, -0.5, 4, 1.5),
            flip_with_ent = true,
            post_transform_shape = function(ent, ctx, shape)
                -- TODO: Double check that your flooring is correct for edge cases.
                local ent_grid_x = math.floor(ctx.ent_x + 0.5)
                local ent_grid_y = math.floor(ctx.ent_y + 0.5)
                -- TODO: Should I start at 0?
                local max_range_x = 1
                local facing_mult = ctx.is_facing_left and -1 or 1
                    while max_range_x < 4 do
                        local grid_ent = get_entity(get_grid_entity_at(ent_grid_x + (max_range_x * facing_mult), ent_grid_y, ent.layer))
                        if grid_ent and test_flag(grid_ent.flags, ENT_FLAG.SOLID) then
                            break
                        else
                            max_range_x = max_range_x + 1
                        end
                    end
                    if facing_mult < 0 then
                        return shape:clip_left(ctx.ent_x - max_range_x)
                    else
                        return shape:clip_right(ctx.ent_x + max_range_x)
                    end
            end,
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and (ent.move_state == 0 or ent.move_state == 1) and ent.jump_cooldown_timer == 0
            end,
            label = "Attack"
        }
    }
})
