-- Necromancers seem to only be able to resurrect things that are laying motionless on the ground, not being carried.
-- TODO: Necromancers attack as long as they have a target, no matter how far that target is. The attack range shown is actually the aggro range, and the necromancer will attack when possible until the 60 frame target_selection_timer cycle makes him lose his target.
-- TODO: Summon/rez range while attacking. Seems to be relative to player position. Both actions can occur slightly outside his attack range near the target.
-- TODO: For far targets, he doesn't seem to be able to do anything there and will summon/resurrect things close to himself instead of the target.
return Entity_AI:new({
    id = "necromancer",
    name = "Necromancer",
    ent_type = ENT_TYPE.MONS_NECROMANCER,
    ranges = {
        { -- Attack
            shape = geometry.create_circle_shape(8),
            layer = function(ent)
                -- Back layer necromancers can attack the front layer, but not vice-versa.
                return ent.layer == LAYER.BACK and LAYER.BOTH or ent.layer
            end,
            is_visible = function(ent)
                -- TODO: He can acquire a target while falling and will immediately attack when touching the ground even if the target moves out of range.
                return ent.move_state == 0 or ent.move_state == 1
            end,
            is_active = function(ent)
                -- TODO: He can acquire a target while falling and will immediately attack when touching the ground even if the target moves out of range.
                return ent.state == CHAR_STATE.STANDING and ent.resurrection_timer == 0
            end,
            label = "Attack"
        },
        { -- Resurrect
            shape = geometry.create_box_shape(-8, -8, 8, 8),
            layer = function(ent)
                -- Back layer necromancers can attack the front layer, but not vice-versa.
                return ent.layer == LAYER.BACK and LAYER.BOTH or ent.layer
            end,
            is_visible = function(ent)
                return ent.move_state == 6
            end,
            label = "Resurrect"
        }
    }
})
