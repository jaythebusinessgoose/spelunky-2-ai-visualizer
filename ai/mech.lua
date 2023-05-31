-- Rider type doesn't seem to affect behavior.
-- The mech won't shoot in mid-air, but it'll remember seeing you and shoot immediately when it lands.
-- If the mech is forced to duck while the rider wants to punch, it will shoot instead.
-- TODO: Mech doesn't attack if you are in a range while it is in the turning animation.
-- TODO: Show punch hurtbox.
-- TODO: Some riders are showing their own inactive ranges while riding, like olmites. Could add a flag to disable all ranges when riding a mount and apply it to those enemies.
return Entity_AI:new({
    id = "mech",
    name = "Mech",
    ent_type = ENT_TYPE.MOUNT_MECH,
    preprocess = function(ent, ctx)
        local can_attack = false
        if ent.rider_uid >= 0 then
            local rider = get_entity(ent.rider_uid)
            -- gun_cooldown also applies to punching.
            can_attack = (ent.state == CHAR_STATE.STANDING or ent.state == CHAR_STATE.FALLING or (ent.state == CHAR_STATE.DUCKING and ent.move_state == 0))
                and ent.gun_cooldown == 0 and (rider.type.id == ENT_TYPE.MONS_ALIEN or rider.type.id == ENT_TYPE.MONS_OLMITE_NAKED)
        end
        ctx.can_attack = can_attack
    end,
    ranges = {
        { -- Punch
            -- TODO: Becomes a shoot range when crouched, since the mech can't punch in that state.
            shape = geometry.create_box_shape(0, -1, 1.65, 1),
            flip_with_ent = true,
            is_blocked_by_solids = true, -- TODO: There seems to be a minimum range in which the mech attacks anyways, but solids definitely shorten it.
            is_visible = function(ent, ctx)
                return ctx.can_attack
            end,
            is_active = function(ent)
                -- TODO
                return true
            end,
            label = "Punch"
        },
        { -- Shoot
            shape = geometry.create_box_shape(4, -1, 6, 1),
            flip_with_ent = true,
            is_blocked_by_solids = true, -- TODO: Label appears even when the entire range is blocked and should not be visible. Is something surviving the clip and giving the shape a zero-area AABB?
            is_visible = function(ent, ctx)
                return ctx.can_attack
            end,
            is_active = function(ent)
                -- TODO
                return true
            end,
            label = "Shoot"
        }
    }
})
