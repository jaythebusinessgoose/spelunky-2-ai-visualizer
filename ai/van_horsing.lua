-- TODO: NPC attack ranges, aggro
-- TODO: Where does Vlad need to be to trigger a shot?
-- TODO: move_state affects willingness to show dialogs. show_text and special_message_shown might have different rules from the quest dialogs.

local ai_common = require("ai/common")

return Entity_AI:new({
    id = "van_horsing",
    name = "Van Horsing",
    ent_type = ENT_TYPE.MONS_OLD_HUNTER,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "target_in_sight_timer"),
        ai_common.create_chaser_postpone_turn_range(ai_common.MOVE_STATE.ATTACKING, "target_in_sight_timer"),
        ai_common.create_chaser_no_jump_range(ai_common.MOVE_STATE.ATTACKING),
        { -- Dialog (jail cell)
            shape = geometry.create_circle_shape(2),
            post_transform_shape = function(ent, ctx, shape)
                -- Van Horsing will only interact with the target if they are both in the same room.
                return shape:clip_box(ai_common.get_room_bounds(ctx.ent_x, ctx.ent_y))
            end,
            is_visible = function(ent)
                return state.quests.van_horsing_state == VANHORSING.JAILCELL_SPAWNED
            end,
            label = "Dialog"
        },
        { -- Dialog (Vlad's castle)
            -- The show_text field is the only thing that actually controls whether this dialog occurs.
            shape = geometry.create_box_shape(-8, -4, 8, 4),
            is_visible = function(ent)
                return ent.show_text or state.quests.van_horsing_state == VANHORSING.SPAWNED_IN_VLADS_CASTLE
            end,
            is_active = function(ent)
                return ent.show_text
            end,
            label = "Dialog"
        },
        { -- Dialog (tide pool)
            shape = geometry.create_box_shape(-5, -1.5, 5, 1.5),
            is_visible = function(ent)
                return not ent.special_message_shown and state.quests.van_horsing_state == VANHORSING.SHOT_VLAD and state.theme == THEME.TIDE_POOL
            end,
            label = "Dialog",
            label_position = LABEL_POSITION.TOP
        },
        { -- Dialog (temple)
            shape = geometry.create_box_shape(-3, -1, 3, 1),
            post_transform_shape = function(ent, ctx, shape)
                -- Van Horsing will only interact with the target if they are both in the same room.
                return shape:clip_box(ai_common.get_room_bounds(ctx.ent_x, ctx.ent_y))
            end,
            is_visible = function(ent)
                return state.quests.van_horsing_state == VANHORSING.TEMPLE_HIDEOUT_SPAWNED
            end,
            label = "Dialog"
        },
        { -- Dialog (Tusk palace)
            shape = geometry.create_box_shape(-5, -1, 5, 1),
            post_transform_shape = function(ent, ctx, shape)
                -- Van Horsing will only interact with the target if they are both in the same room.
                return shape:clip_box(ai_common.get_room_bounds(ctx.ent_x, ctx.ent_y))
            end,
            is_visible = function(ent)
                return state.quests.van_horsing_state == VANHORSING.SECOND_ENCOUNTER_COMPASS_THROWN and state.theme == THEME.NEO_BABYLON
            end,
            label = "Dialog"
        }
    }
})
