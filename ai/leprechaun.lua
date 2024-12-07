-- TODO: Any constraints on when/where teleports can occur? Starts a timer at 120 to teleport when it reaches 0, but only if he has enough gold. Countdown can be paused by stunning him, but will resume when he unstuns and can only be reset to 120 by letting him successfully hump again. Won't teleport to any position less than ~10 tiles away from himself. Can teleport right next to his target sometimes, but not directly on top of most entities, including prior teleport FX. Won't teleport onto bordertiles either. If there is no valid teleport location, then the timer will reach 0 and nothing will happen.
-- TODO: Doesn't teleport without strictly greater than 1000 gold when I tested on 1-1 and 3-1. Same for all levels?

local ai_common = require("ai/common")

return Entity_AI:new({
    id = "leprechaun",
    name = "Leprechaun",
    ent_type = ENT_TYPE.MONS_LEPRECHAUN,
    ranges = {
        ai_common.create_chaser_turn_range(2, "target_in_sight_timer"),
        ai_common.create_chaser_no_jump_range(2),
        {
            -- Range in which the leprechaun can jump if there is a tile above an empty space 2 in front of it.
            shape = geometry.create_box_shape(-1000, -1, 1000, 1000),
            is_visible = function(ent)
                return ent.move_state == 2
            end,
            is_active = function(ent)
                return ent.standing_on_uid ~= -1
            end,
            label = "Gap Jump",
            label_position = LABEL_POSITION.BOTTOM,
        },
        { -- Aggro
            shape = geometry.create_circle_shape(8),
            is_visible = function(ent)
                return ent.move_state == 0 or ent.move_state == 1 or ent.move_state == 5 or ent.move_state == 6
            end,
            is_active = function(ent)
                return ent.move_state == 0 or ent.move_state == 1
            end,
            label = "Aggro"
        }
    }
})
