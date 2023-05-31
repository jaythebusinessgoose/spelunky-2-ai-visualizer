-- The carried entity doesn't seem to affect behavior. Hermit crabs with no carried entity will stay emerged and spawn bubbles forever.
-- TODO: Hermit crabs in nooks or 1 tile tunnels might behave differently.
-- TODO: Dim targetting when crab has no shelter or pole..
return Entity_AI:new({
    id = "hermit_crab",
    name = "Hermit crab",
    ent_type = ENT_TYPE.MONS_HERMITCRAB,
    ranges = {
        { -- Emerge
            shape = geometry.create_circle_shape(5),
            is_visible = function(ent)
                return (ent.move_state == 0 or ent.move_state == 3) and ent.is_inactive
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
            -- TODO: Not 100% sure about -0.1, but it's pretty close.
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
