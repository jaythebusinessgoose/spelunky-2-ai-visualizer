-- TODO: Finish NPC ranges
-- Beg does not pick up any items and will not use them even if forced to hold them.

local ai_common = require("ai/common")

return Entity_AI:new({
    id = "beg",
    name = "Beg",
    ent_type = ENT_TYPE.MONS_HUNDUNS_SERVANT,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "target_in_sight_timer"),
        ai_common.create_chaser_postpone_turn_range(ai_common.MOVE_STATE.ATTACKING, "target_in_sight_timer"),
        ai_common.create_chaser_no_jump_range(ai_common.MOVE_STATE.ATTACKING),
        { -- Dialog
            shape = geometry.create_circle_shape(2),
            is_visible = function(ent)
                return (ent.move_state == 0 or ent.move_state == 1)
                    and (state.quests.beg_state == BEG.SPAWNED_WITH_BOMBBAG or state.quests.beg_state == BEG.SPAWNED_WITH_TRUECROWN)
            end,
            label = "Dialog"
        }
    }
})
