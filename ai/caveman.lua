-- Held items appear to have no effect on range or behavior.
local ai_common = require("ai/common")

return Entity_AI:new({
    id = "caveman",
    name = "Caveman",
    ent_type = ENT_TYPE.MONS_CAVEMAN,
    targetting = false,
    ranges = {
        { -- Player wake
            shape = geometry.create_box_shape(-4, -2, 4, 2),
            is_visible = function(ent)
                return ent.move_state == 11
            end,
            is_inactive_when_stuck = false,
            label = "Player wake",
            label_position = LABEL_POSITION.TOP
        },
        { -- Explosion wake
            -- TODO: Radius to check is actually 4.01, but I've been omitting the small padding in these hitboxes.
            shape = geometry.create_rounded_box_shape(-0.35, -0.55, 0.35, 0.3, 4),
            is_visible = function(ent)
                return ent.move_state == 11
            end,
            is_inactive_when_stuck = false,
            label = "Explosion wake",
            label_position = LABEL_POSITION.TOP
        },
        { -- Aggro
            -- TODO: This is visible for cavemen in the Olmec cutscene, but they can't actually aggro at all. This behavior isn't tied to the praying animation, nor any flags or exposed variables I could find. WalkingMonster.cooldown_timer doesn't decrement at all on the original ones, making me think there is a setting somewhere that turns off the AI entirely. The cutscene doesn't seem to track the 3 original cavemen, and instead triggers animation changes on all cavemen in the level, and kills them all when it ends. Any late spawned cavemen caught up in a cutscene animation change also get their AI disabled. However, before an animation change, the late spawns have normal AI.
            shape = geometry.create_box_shape(0, -0.4, 6, 0.4),
            flip_with_ent = true,
            is_blocked_by_solids = true,
            is_visible = function(ent)
                return (ent.move_state == 0 or ent.move_state == 1) and not ai_common.is_mounted(ent)
            end,
            label = "Aggro"
        },
        { -- Reaggro
            -- TODO: Reaggro actually only occurs on the same frame that aggro_timer equals 0. This is never detectable since it gets set to 120 on that same frame if the target is still in range.
            shape = geometry.create_box_shape(-9, -4, 9, 4),
            flip_with_ent = true,
            is_visible = function(ent)
                return ent.move_state == 4 or ent.move_state == 6
            end,
            label = "Reaggro"
        }
    }
})
