-- TODO: Finish NPC ranges

local ai_common = require("ai/common")

return Entity_AI:new({
    id = "shopkeeper",
    name = "Shopkeeper",
    ent_type = ENT_TYPE.MONS_SHOPKEEPER,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "lose_interest_timer"),
        ai_common.create_chaser_no_jump_range(ai_common.MOVE_STATE.ATTACKING),
        { -- Aggro
            shape = geometry.create_circle_shape(6),
            is_visible = function(ent)
                return ent.move_state ~= ai_common.MOVE_STATE.ATTACKING and ent.move_state ~= ai_common.MOVE_STATE.CLIMBING and state.shoppie_aggro_next > 0
            end,
            is_inactive_when_stuck = false,
            label = "Aggro"
        },
        { -- Detect bomb
            -- TODO: Does it differ when passive, on patrol, and aggroed? Seeing a bomb too close counts as an offense even if aggroed already.
            shape = geometry.create_box_shape(-1, -1.04, 2, 1.25),
            flip_with_ent = true,
            type = Entity_AI.RANGE_TYPE.HITBOX_OVERLAP,
            is_visible = function(ent)
                return not test_flag(state.level_flags, 10) -- Angry shopkeeper flag
            end,
            is_inactive_when_stuck = false,
            label = "Detect bomb"
        },
        { -- Use held item
            -- TODO: Check range with other weapons. Seemed like they were all the same for bodyguards.
            -- TODO: Doesn't seem to shoot if face is too close to a wall. Also doesn't shoot if facing into a ladder. Is it just a check for FLOOR entities? Is he checking a single point in front of himself?
            shape = geometry.create_donut_shape(2, 12):clip_box(0, nil, 5, nil),
            flip_with_ent = true,
            is_visible = ai_common.npc_use_held_item_range_visible,
            is_inactive_when_stuck = false,
            is_active = ai_common.npc_use_held_item_range_active,
            label = ai_common.npc_use_held_item_range_label,
            label_position = LABEL_POSITION.RIGHT
        },
        { -- No climb
            -- TODO: Consider inverting this into a climb range.
            -- TODO: Shopkeeper can regrab even in the air. Is there ever a situation where he can't climb when outside this range?
            -- TODO: Seems to prefer climbing in direction of player. Is it like this even at long distances?
            -- TODO: Seems to have a delay before he can regrab if in the air, but it resets instantly on the ground. Maybe the same regrab delay the player has?
            -- TODO: Unclear if facing direction has any effect.
            shapes = {
                geometry.create_box_shape(-4, 2, 4, 8),
                geometry.create_box_shape(-1000, -4, 1000, 2)
            },
            is_visible = function(ent)
                return ent.move_state == ai_common.MOVE_STATE.ATTACKING and not entity_has_item_type(ent.uid, ENT_TYPE.ITEM_PASTEBOMB)
            end,
            is_inactive_when_stuck = false,
            label = "No climb"
        },
        --[[{ -- Stop climb
            -- TODO: Seems to always do a short hop off the ladder instead of dropping.
            -- TODO: Dismounts if player is below him, but seemingly after a delay and in an unclear range.
            -- TODO: Unclear if facing direction has any effect.
            shape = geometry.create_circle_shape(1), -- TODO: Placeholder, not accurate at all.
            is_visible = function(ent)
                return ent.move_state == MOVE_STATE.CLIMBING
            end,
            is_inactive_when_stuck = false,
            label = "Stop climb"
        }]]
    }
})
