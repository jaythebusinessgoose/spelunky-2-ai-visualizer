-- The carried entity doesn't seem to affect behavior. Hermit crabs with no carried entity will stay emerged and spawn bubbles forever.
-- TODO: Hermit crabs in nooks or 1 tile tunnels might behave differently.
-- TODO: Dim targetting when crab has no shelter or pole..
return Entity_AI:new({
    id = "hermit_crab",
    name = "Hermit crab",
    ent_type = ENT_TYPE.MONS_HERMITCRAB,
    preprocess = function(ent, ctx)
        local entx, enty, entlayer = get_position(ent.uid)
        local above = get_entities_at(0, MASK.ACTIVEFLOOR | MASK.FLOOR, entx, enty + 1, entlayer, 0.5)
        local left = get_entities_at(0, MASK.ACTIVEFLOOR | MASK.FLOOR, entx - 1, enty, entlayer, 0.5)
        local right = get_entities_at(0, MASK.ACTIVEFLOOR | MASK.FLOOR, entx + 1, enty, entlayer, 0.5)
        local solid_floor_above = false
        local solid_floor_left = false
        local solid_floor_right = false
        if above then
            for _, floor in pairs(above) do
                if test_flag(get_entity(floor).flags, ENT_FLAG.SOLID) then
                    solid_floor_above = true
                    break
                end
            end
        end
        if left then
            for _, floor in pairs(left) do
                if test_flag(get_entity(floor).flags, ENT_FLAG.SOLID) then
                    solid_floor_left = true
                    break
                end
            end
        end
        if right then
            for _, floor in pairs(right) do
                if test_flag(get_entity(floor).flags, ENT_FLAG.SOLID) then
                    solid_floor_right = true
                    break
                end
            end
        end

        ctx.trapped = solid_floor_left and solid_floor_right
        ctx.in_cubby_left_opening = solid_floor_above and solid_floor_right and (not solid_floor_left)
        ctx.in_cubby_right_opening = solid_floor_above and solid_floor_left and (not solid_floor_right)
    end,
    ranges = {
        { -- Emerge
            shape = geometry.create_circle_shape(5),
            is_visible = function(ent, ctx)
                return (ent.move_state == 0 or ent.move_state == 3) and ent.is_inactive and not ctx.trapped and not ctx.in_cubby_left_opening and not ctx.in_cubby_right_opening
            end,
            is_active = function(ent)
                return ent.move_state == 0
            end,
            label = "Emerge"
        },
        { -- Emerge (Left Cubby)
            shape = geometry.create_circle_shape(5):clip_box(nil, -1, 0, 1),
            is_visible = function(ent, ctx)
                return (ent.move_state == 0 or ent.move_state == 3) and ent.is_inactive and ctx.in_cubby_left_opening and not ctx.trapped
            end,
            is_active = function(ent)
                return ent.move_state == 0
            end,
            label = "Emerge"
        },
        { -- Emerge (Right Cubby)
            shape = geometry.create_circle_shape(5):clip_box(0, -1, nil, 1),
            is_visible = function(ent, ctx)
                return (ent.move_state == 0 or ent.move_state == 3) and ent.is_inactive and ctx.in_cubby_right_opening and not ctx.trapped
            end,
            is_active = function(ent)
                return ent.move_state == 0
            end,
            label = "Emerge"
        },
        { -- No hide
            -- They hide if they reach a wall or ledge, even if the player is within this range. They'll emerge again shortly afterward if the player is also within the emerge range.
            shape = geometry.create_circle_shape(8),
            is_visible = function(ent)
                return ent.move_state ~= 0 and ent.move_state ~= 3 and ent.is_active and ent.carried_entity_uid > -1
            end,
            label = "No hide"
        },
        { -- Bubble (climbing)
            shape = geometry.create_box_shape(-3, -0.1, 3, 3),
            is_visible = function(ent)
                return ent.state == CHAR_STATE.CLIMBING
            end,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            label = "Bubble"
        }
    }
})
