-- TODO: How does the targetting work?
return Entity_AI:new({
    id = "flying_fish",
    name = "Flying fish",
    ent_type = ENT_TYPE.MONS_FISH,
    preprocess = function(ent, ctx)
        ctx.offsetx = ent.offsetx
        ctx.offsety = ent.offsety
        ctx.hitboxx = ent.hitboxx
        ctx.hitboxy = ent.hitboxy
    end,
    ranges = {
        { -- Rise
            -- TODO: Ceiling will reduce the height of the rise shape. Getting close may cause a rise even when there is a low ceiling.
            shape = geometry.create_box_shape(-10, 0, 10, 4),
            is_active = function(ent)
                return ent.state == 3 and ent.move_state == 0 and ent.target_selection_timer == 0
            end,
            label = "Rise"
        },
        { -- Attack
            shape = geometry.create_box_shape(-1000, -1000, 1000, 0),
            is_visible = function(ent)
                return ent.move_state == 2
            end,
            label = "Attack",
            label_position = LABEL_POSITION.TOP
        },
        { -- Stop rising
            shape = function(ent, ctx)
                local top_pos = ctx.offsety + ctx.hitboxy + 0.15
                return geometry.create_point_set_shape(Vec2:new(ctx.offsetx - ctx.hitboxx, top_pos), Vec2:new(0, top_pos), Vec2:new(ctx.offsetx + ctx.hitboxx, top_pos))
            end,
            type = Entity_AI.RANGE_TYPE.SOLID_CHECK,
            is_visible = function(ent)
                return ent.move_state == 2
            end,
            label = "Stop Rising",
            -- TODO: This hack puts the label above the points.
            label_position = LABEL_POSITION.BOTTOM
        }
    }
})
