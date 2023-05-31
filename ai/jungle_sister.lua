-- TODO: NPC AI stuff (climbing, attacking)

local ai_common = require("ai/common")

local function get_rescue_flag(ent)
    if ent.type.id == ENT_TYPE.MONS_SISTER_PARSLEY then
        return JUNGLESISTERS.PARSLEY_RESCUED
    elseif ent.type.id == ENT_TYPE.MONS_SISTER_PARSNIP then
        return JUNGLESISTERS.PARSNIP_RESCUED
    else
        return JUNGLESISTERS.PARMESAN_RESCUED
    end
end

local TURN_RANGE = ai_common.create_chaser_turn_range(ai_common.MOVE_STATE.ATTACKING, "target_in_sight_timer")
local POSTPONE_TURN_RANGE = ai_common.create_chaser_postpone_turn_range(ai_common.MOVE_STATE.ATTACKING, "target_in_sight_timer")
local NO_JUMP_RANGE = ai_common.create_chaser_no_jump_range(ai_common.MOVE_STATE.ATTACKING)

local DIALOG_JUNGLE_RANGE = {
    shape = geometry.create_circle_shape(2),
    post_transform_shape = function(ent, ctx, shape)
        -- The sister will only interact with the target if they are both in the same room.
        return shape:clip_box(ai_common.get_room_bounds(ctx.ent_x, ctx.ent_y))
    end,
    is_visible = function(ent)
        return (ent.move_state == 0 or ent.move_state == 1) and state.theme == THEME.JUNGLE
            and not test_flag(state.quests.jungle_sisters_flags, get_rescue_flag(ent))
    end,
    label = "Dialog"
}

local DIALOG_OLMEC_RANGE = {
    shape = geometry.create_circle_shape(3),
    post_transform_shape = function(ent, ctx, shape)
        -- The sister will only interact with the target if they are both in the same room.
        return shape:clip_box(ai_common.get_room_bounds(ctx.ent_x, ctx.ent_y))
    end,
    is_visible = function(ent)
        return ent.move_state == 8
    end,
    label = "Dialog",
    label_position = LABEL_POSITION.TOP
}

local DETECT_BOMB_RANGE = {
    -- TODO: Bottom and top are 2 tiles from sister's hitbox, not these seemingly arbitrary values. Left and right seem to be hard-coded to 4.
    shape = geometry.create_box_shape(-4, -2.54, 4, 2.25),
    type = Entity_AI.RANGE_TYPE.HITBOX_OVERLAP,
    is_visible = function(ent)
        return ent.move_state ~= 6
    end,
    label = "Detect bomb",
    label_position = LABEL_POSITION.TOP
}

return {
    Entity_AI:new({
        id = "jungle_sister",
        name = "Jungle sister"
    }),
    Entity_AI:new({
        id = "parsley",
        name = "Parsley",
        parent_id = "jungle_sister",
        ent_type = ENT_TYPE.MONS_SISTER_PARSLEY,
        ranges = {
            TURN_RANGE,
            POSTPONE_TURN_RANGE,
            NO_JUMP_RANGE,
            DIALOG_JUNGLE_RANGE,
            DIALOG_OLMEC_RANGE,
            DETECT_BOMB_RANGE,
            { -- Dialog (tide pool)
                shape = geometry.create_box_shape(-5, -1.5, 5, 1.5),
                is_visible = function(ent)
                    return (ent.move_state == 0 or ent.move_state == 1) and state.theme == THEME.TIDE_POOL
                        and not test_flag(state.quests.jungle_sisters_flags, JUNGLESISTERS.WARNING_ONE_WAY_DOOR)
                end,
                label = "Dialog",
                label_position = LABEL_POSITION.TOP
            }
        }
    }),
    Entity_AI:new({
        id = "parsnip",
        name = "Parsnip",
        parent_id = "jungle_sister",
        ent_type = ENT_TYPE.MONS_SISTER_PARSNIP,
        ranges = {
            TURN_RANGE,
            POSTPONE_TURN_RANGE,
            NO_JUMP_RANGE,
            DIALOG_JUNGLE_RANGE,
            DIALOG_OLMEC_RANGE,
            DETECT_BOMB_RANGE,
            { -- Dialog (neo babylon)
                shape = geometry.create_circle_shape(2),
                post_transform_shape = function(ent, ctx, shape)
                    -- The sister will only interact with the target if they are both in the same room.
                    return shape:clip_box(ai_common.get_room_bounds(ctx.ent_x, ctx.ent_y))
                end,
                is_visible = function(ent)
                    return (ent.move_state == 0 or ent.move_state == 1) and state.theme == THEME.NEO_BABYLON
                        and not test_flag(state.quests.jungle_sisters_flags, JUNGLESISTERS.GREAT_PARTY_HUH)
                end,
                label = "Dialog",
                label_position = LABEL_POSITION.TOP
            }
        }
    }),
    Entity_AI:new({
        id = "parmesan",
        name = "Parmesan",
        parent_id = "jungle_sister",
        ent_type = ENT_TYPE.MONS_SISTER_PARMESAN,
        ranges = {
            TURN_RANGE,
            POSTPONE_TURN_RANGE,
            NO_JUMP_RANGE,
            DIALOG_JUNGLE_RANGE,
            DIALOG_OLMEC_RANGE,
            DETECT_BOMB_RANGE,
            { -- Dialog (ice caves)
                shape = geometry.create_circle_shape(2),
                post_transform_shape = function(ent, ctx, shape)
                    -- The sister will only interact with the target if they are both in the same room.
                    return shape:clip_box(ai_common.get_room_bounds(ctx.ent_x, ctx.ent_y))
                end,
                is_visible = function(ent)
                    return (ent.move_state == 0 or ent.move_state == 1) and state.theme == THEME.ICE_CAVES
                        and not test_flag(state.quests.jungle_sisters_flags, JUNGLESISTERS.I_WISH_BROUGHT_A_JACKET)
                end,
                label = "Dialog",
                label_position = LABEL_POSITION.TOP
            }
        }
    })
}
