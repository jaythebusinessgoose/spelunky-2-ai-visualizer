local ai_common = require("ai/common")

return Entity_AI:new({
    id = "cat_mummy",
    name = "Cat mummy",
    ent_type = ENT_TYPE.MONS_CATMUMMY,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "attack_timer"),
        ai_common.create_chaser_postpone_turn_range(ai_common.MOVE_STATE.ATTACKING, "attack_timer"),
        ai_common.create_chaser_no_jump_range(ai_common.MOVE_STATE.ATTACKING),
        { -- Aggro
            shape = geometry.create_box_shape(-6, -0.4, 6, 0.4),
            is_visible = function(ent)
                return ent.move_state == 0
            end,
            label = "Aggro"
        }
    }
})
