-- TODO: Finish NPC ranges. Probably very similar to shopkeeper.

local ai_common = require("ai/common")

return Entity_AI:new({
    id = "shopkeeper_clone",
    name = "Shopkeeper clone",
    ent_type = ENT_TYPE.MONS_SHOPKEEPERCLONE,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "target_in_sight_timer"),
        ai_common.create_chaser_no_jump_range(ai_common.MOVE_STATE.ATTACKING),
        { -- Use held item
            shape = geometry.create_donut_shape(2, 12):clip_box(0, nil, 5, nil),
            flip_with_ent = true,
            is_visible = ai_common.npc_use_held_item_range_visible,
            is_inactive_when_stuck = false,
            is_active = ai_common.npc_use_held_item_range_active,
            label = ai_common.npc_use_held_item_range_label,
            label_position = LABEL_POSITION.RIGHT
        },
    }
})
