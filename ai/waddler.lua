local ai_common = require("ai/common")

return Entity_AI:new({
    id = "waddler",
    name = "Waddler",
    ent_type = ENT_TYPE.MONS_STORAGEGUY,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "lose_interest_timer"),
        ai_common.create_chaser_postpone_turn_range(ai_common.MOVE_STATE.ATTACKING, "lose_interest_timer")
    }
})
