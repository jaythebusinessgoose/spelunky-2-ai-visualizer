-- TODO: Finish NPC ranges

local ai_common = require("ai/common")

return Entity_AI:new({
    id = "tun",
    name = "Tun",
    ent_type = ENT_TYPE.MONS_MERCHANT,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "lose_interest_timer"),
        ai_common.create_chaser_postpone_turn_range(ai_common.MOVE_STATE.ATTACKING, "lose_interest_timer"),
        ai_common.create_chaser_no_jump_range(ai_common.MOVE_STATE.ATTACKING),
        { -- Dialog (Tiamat)
            shape = geometry.create_box_shape(-3, -1.5, 3, 1.5),
            is_visible = function(ent)
                -- TODO: Anything else affect this? Tun aggro? Can it happen in other move_states? Other themes?
                return ent.move_state == 0 and not ent.tiamat_encounter and state.theme == THEME.TIAMAT
            end,
            label = "Dialog",
            label_position = LABEL_POSITION.TOP
        },
        { -- Aggro
            shape = geometry.create_circle_shape(6),
            is_visible = function(ent)
                return (ent.move_state == 8 or ent.move_state == 9) and state.merchant_aggro > 0
            end,
            is_inactive_when_stuck = false,
            label = "Aggro"
        },
        { -- Use held item
            shape = geometry.create_box_shape(0, -0.2, 10, 0.2),
            flip_with_ent = true,
            line_of_sight_checks = 10,
            line_of_sight_extra_length = 1,
            is_visible = ai_common.npc_use_held_item_range_visible,
            is_inactive_when_stuck = false,
            is_active = ai_common.npc_use_held_item_range_active,
            label = ai_common.npc_use_held_item_range_label
        }
    }
})
