-- TODO: Finish NPC ranges
-- TODO: move_state affects willingness to show dialogs.

local ai_common = require("ai/common")

return Entity_AI:new({
    id = "sparrow",
    name = "Sparrow",
    ent_type = ENT_TYPE.MONS_THIEF,
    ranges = {
        ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "target_in_sight_timer"),
        ai_common.create_chaser_no_jump_range(ai_common.MOVE_STATE.ATTACKING),
        { -- Use held item
            shape = geometry.create_box_shape(0, -0.18, 10, 0.18),
            flip_with_ent = true,
            line_of_sight_checks = 10,
            line_of_sight_extra_length = 2,
            is_visible = ai_common.npc_use_held_item_range_visible,
            is_inactive_when_stuck = false,
            is_active = ai_common.npc_use_held_item_range_active,
            label = ai_common.npc_use_held_item_range_label
        },
        { -- Dialog
            shape = geometry.create_circle_shape(2.5),
            post_transform_shape = function(ent, ctx, shape)
                -- Sparrow will only interact with the target if they are both in the same room.
                return shape:clip_box(ai_common.get_room_bounds(ctx.ent_x, ctx.ent_y))
            end,
            is_visible = function(ent)
                return state.quests.sparrow_state == SPARROW.FIRST_HIDEOUT_SPAWNED_ROPE_THROW
                    or state.quests.sparrow_state == SPARROW.SECOND_HIDEOUT_SPAWNED_NEOBAB
                    or (state.quests.sparrow_state == SPARROW.SECOND_ENCOUNTER_INTERACTED and state.quests.madame_tusk_state ~= TUSK.DEAD)
            end,
            label = "Dialog"
        },
        { -- Give reward
            shape = geometry.create_circle_shape(2.5),
            post_transform_shape = function(ent, ctx, shape)
                -- Sparrow will only interact with the target if they are both in the same room.
                return shape:clip_box(ai_common.get_room_bounds(ctx.ent_x, ctx.ent_y))
            end,
            is_visible = function(ent)
                return state.quests.sparrow_state == SPARROW.MEETING_AT_TUSK_BASEMENT and state.quests.madame_tusk_state ~= TUSK.DEAD and state.world == 6 and state.level == 3
            end,
            is_active = function(ent)
                local total_opened = 0
                -- Only vault chests in the back layer are checked, no matter where Sparrow is.
                for _, id in pairs(get_entities_by(ENT_TYPE.ITEM_VAULTCHEST, MASK.ITEM, LAYER.BACK)) do
                    if get_entity(id).health == 0 then
                        total_opened = total_opened + 1
                    end
                end
                return total_opened == 4
            end,
            label = "Give reward"
        }
    }
})
