-- TODO: Finish NPC ranges
-- TODO: He won't shoot if Tusk is in the way. How does that check work?

local ai_common = require("ai/common")

return Entity_AI:new({
    id = "bodyguard",
    name = "Bodyguard",
    ent_type = ENT_TYPE.MONS_BODYGUARD,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "target_in_sight_timer"),
        ai_common.create_chaser_no_jump_range(ai_common.MOVE_STATE.ATTACKING),
        { -- Tusk idol aggro
            -- The bodyguard aggros from seeing the idol, not the player. The idol can be seen even through walls. Tusk does not aggro from seeing the idol.
            -- TODO: These values are weird. Is the aggro based on seeing any part of the tusk idol's hitbox? This makes sense for the width, but not the height. The idol hitbox is -0.23 left, -0.44 bottom, 0.23 right, 0.34 top (origin is not vertically centered). X was not measured to float32 precision. Y was measured to float32 precision.
            shape = geometry.create_box_shape(-6.23, -2.8805, 6.23, 2.6905),
            is_visible = function(ent)
                return ent.move_state == 0 and state.quests.madame_tusk_state == TUSK.DICE_HOUSE_SPAWNED
            end,
            is_inactive_when_stuck = false,
            label = "Tusk idol aggro"
        },
        { -- Use held item
            shape = geometry.create_box_shape(0, -1, 6, 1),
            flip_with_ent = true,
            is_visible = ai_common.npc_use_held_item_range_visible,
            is_inactive_when_stuck = false,
            is_active = ai_common.npc_use_held_item_range_active,
            label = ai_common.npc_use_held_item_range_label
        }
    }
})
