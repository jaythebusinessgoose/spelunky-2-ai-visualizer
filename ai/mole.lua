return Entity_AI:new({
    id = "mole",
    name = "Mole",
    ent_type = ENT_TYPE.MONS_MOLE,
    preprocess = function(ent, ctx)
        local entx, enty, entlayer = get_position(ent.uid)
        local function contains_diggable(floors)
            local function is_diggable(floor)
                if floor == -1 then return false end
                local floor_ent = get_entity(floor)
                if not floor_ent then return false end

                if not test_flag(floor_ent.flags, ENT_FLAG.SOLID) then return false end
                if floor_ent.type.search_flags == MASK.ACTIVEFLOOR then return false end
                if floor_ent.type.id == ENT_TYPE.FLOOR_BORDERTILE then return false end
                if test_flag(floor_ent.type.properties_flags, 2) then return false end
                if not test_flag(floor_ent.type.properties_flags, 1) then return false end
                return true
            end
            for _, floor in pairs(floors) do
                if is_diggable(floor) then
                    return true
                end
            end
            return false
        end
        local here = get_entities_at(0,  MASK.FLOOR, entx, enty, entlayer, 0.5)
        local above = get_entities_at(0,  MASK.FLOOR, entx, enty + 1, entlayer, 0.5)
        local left = get_entities_at(0, MASK.FLOOR, entx - 1, enty, entlayer, 0.5)
        local right = get_entities_at(0, MASK.FLOOR, entx + 1, enty, entlayer, 0.5)
        local below = get_entities_at(0, MASK.FLOOR, entx, enty - 1, entlayer, 0.5)

        ctx.trapped = contains_diggable(here) and not (contains_diggable(above) or contains_diggable(below) or contains_diggable(left) or contains_diggable(right))
    end,
    ranges = {
        { -- Emerge
            -- Moles have an erratic countdown_for_appearing variable that decrements every time the mole digs into a new tile, regardless of whether a player is near. If a player is in range while it's at 0, then the mole will move directly towards the player until it either hits air or an undiggable tile. If it hits air, then it emerges. Otherwise, it resets the counter and goes back to digging randomly. If the player moves out of range while it's digging towards them, it will go back to digging randomly, but the counter will stay at 0.
            -- TODO: Moles trapped in a single tile do not move randomly. When a player is in range, they ignore countdown_for_appearing and try to emerge towards the player immediately. They do not create any dirt particles while not moving, so this is why this kind of mole seems to appear with no warning.
            shape = geometry.create_circle_shape(8),
            is_visible = function(ent)
                return ent.move_state == 9 and ent.digging_state == 2
            end,
            is_active = function(ent, ctx)
                return ent.countdown_for_appearing == 0 or ctx.trapped
            end,
            label = "Emerge"
        },
        { -- Activate
            shape = geometry.create_circle_shape(16),
            post_transform_shape = function(ent, ctx)
                local radius = ctx.trapped and 8 or 16
                local shape = geometry.create_circle_shape(radius)
                local x, y = get_position(ent.uid)
                shape:translate(x, y)
                return shape
            end,
            is_visible = function(ent)
                return ent.move_state == 8 and ent.digging_state == 2
            end,
            label = "Active"
        }
    }
})
