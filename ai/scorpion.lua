local ai_common = require("ai/common")

return Entity_AI:new({
    id = "scorpion",
    name = "Scorpion",
    ent_type = ENT_TYPE.MONS_SCORPION,
    ranges = {
        { -- Attack
            shape = geometry.create_box_shape(0.6, -0.5, 4, 1.5),
            flip_with_ent = true,
            post_transform_shape = function(ent, ctx, shape)
                -- Scorpions check a slightly different set of points than most other entities with line-of-sight checks, and they only check for solid grid entities.
                local max_range_x = 0
                local facing_mult = ctx.is_facing_left and -1 or 1
                while max_range_x < 4 do
                    if ai_common.is_point_solid_grid_entity(ctx.ent_x + (max_range_x * facing_mult), ctx.ent_y, ent.layer) then
                        break
                    else
                        max_range_x = max_range_x + 1
                    end
                end
                if ctx.is_facing_left then
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
