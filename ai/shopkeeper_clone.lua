-- TODO: Unfinished. Probably very similar to shopkeeper AI.

local ai_common = require("ai/common")

return Entity_AI:new({
    id = "shopkeeper_clone",
    name = "Shopkeeper clone",
    ent_type = ENT_TYPE.MONS_SHOPKEEPERCLONE,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "target_in_sight_timer"),
        ai_common.create_chaser_postpone_turn_range(ai_common.MOVE_STATE.ATTACKING, "target_in_sight_timer"),
        ai_common.create_chaser_no_jump_range(ai_common.MOVE_STATE.ATTACKING)
    }
})
