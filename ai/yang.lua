-- TODO: NPC attack ranges
-- TODO: Dead turkey aggro
-- TODO: Does this move_state stuff matter? Didn't really check it for other NPCs.

local ai_common = require("ai/common")

return Entity_AI:new({
    id = "yang",
    name = "Yang",
    ent_type = ENT_TYPE.MONS_YANG,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "lose_interest_timer"),
        ai_common.create_chaser_postpone_turn_range(ai_common.MOVE_STATE.ATTACKING, "lose_interest_timer"),
        ai_common.create_chaser_no_jump_range(ai_common.MOVE_STATE.ATTACKING),
        { -- Dialog (dwelling)
            shape = geometry.create_box_shape(0, -2, 2.2, 1),
            flip_with_ent = true,
            is_visible = function(ent)
                return ent.move_state == 0 and not ent.first_message_shown and state.quests.yang_state == YANG.TURKEY_PEN_SPAWNED and state.theme == THEME.DWELLING
            end,
            label = "Dialog"
        },
        { -- Dialog (black market)
            shape = geometry.create_box_shape(-2, -1.5, 2, 1.5),
            is_visible = function(ent)
                return (ent.move_state == 0 or ent.move_state == 1) and not ent.special_message_shown and state.quests.yang_state ~= YANG.ANGRY and state.theme == THEME.JUNGLE
            end,
            label = "Dialog",
            label_position = LABEL_POSITION.TOP
        },
        { -- Dialog (tide pool)
            shape = geometry.create_box_shape(-5, -1.5, 5, 1.5),
            is_visible = function(ent)
                return ent.move_state == 0 and not ent.special_message_shown and state.quests.yang_state ~= YANG.ANGRY and state.theme == THEME.TIDE_POOL
            end,
            label = "Dialog",
            label_position = LABEL_POSITION.TOP
        },
        { -- Dialog (neo babylon)
            shape = geometry.create_box_shape(-2, -1.5, 2, 1.5),
            is_visible = function(ent)
                return ent.move_state == 0 and not ent.special_message_shown and state.quests.yang_state ~= YANG.ANGRY and state.theme == THEME.NEO_BABYLON
            end,
            label = "Dialog",
            label_position = LABEL_POSITION.TOP
        },
        { -- Detect bomb
            -- TODO: Completely untested. Yang AI breaks if I put a bomb near him and then try to restore his old state. Don't know what I'm missing. Happens in the turkey pen and in 4-3. Couldn't find any unexposed variables for this.
            shape = geometry.create_box_shape(-4, -2.54, 4, 2.25),
            type = Entity_AI.RANGE_TYPE.HITBOX_OVERLAP,
            is_visible = function(ent)
                return ent.move_state ~= 6
            end,
            label = "Detect bomb",
            label_position = LABEL_POSITION.TOP
        }
    }
})
