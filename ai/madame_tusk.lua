-- TODO: Turns when stuck in a web if lose_interest_timer reaches 0 and the player is behind, no matter how far. Crescent ranges seem to be irrelevant. lose_interest_timer loops forever instead of staying at 0 when far away. Still doesn't turn if airborne in the web.

local ai_common = require("ai/common")

return Entity_AI:new({
    id = "madame_tusk",
    name = "Madame Tusk",
    ent_type = ENT_TYPE.MONS_MADAMETUSK,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "lose_interest_timer"),
        { -- Dialog
            shape = geometry.create_box_shape(-3, -1, 3, 1),
            is_visible = function(ent)
                -- TODO: Figure out which entity states allow this. It actually still happens even while angered if the quest state is correct.
                return state.quests.madame_tusk_state == TUSK.HIGH_ROLLER_STATUS and state.theme == THEME.NEO_BABYLON
            end,
            label = "Dialog",
            label_position = LABEL_POSITION.TOP
        }
    }
})
