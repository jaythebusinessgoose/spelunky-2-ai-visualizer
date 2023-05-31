-- A "chaser" is an AI type that runs, turns, jumps, and climbs based on the location of their target. RoomOwners, NPCs, and a few other entities utilize some subset of this chasing behavior.

local module = {}

module.MOVE_STATE = {
    TURNING = 3,
    ATTACKING = 6,
    CLIMBING = 11
}

function module.get_field(ent, fields)
    if type(fields) == "table" then
        local value = ent
        for _, field in ipairs(fields) do
            value = value[field]
            if value == nil then
                return nil
            end
        end
        return value
    else
        return ent[fields]
    end
end

-- Returns whether an entity is riding a mount.
function module.is_mounted(ent)
    return ent.overlay and ent.overlay.rider_uid == ent.uid
end

-- Returns whether an entity (presumably an NPC) is holding a weapon which is ready to shoot. A gun is ready to shoot if it's off cooldown, and a bow is ready to shoot if it has an arrow loaded. Not every NPC will voluntarily pick up every weapon handled here, but they can all shoot any weapon if forced to hold it. No NPC will pick up the clone gun, webgun, scepter, or bow (not even Tun), but they can still shoot them. The scepter shot won't track players and can attack the NPC that fired it. This function is assuming that the NPC is holding a legitimate ranged weapon and may not work correctly for other held items.
function module.can_shoot_held_weapon(ent)
    if ent.holding_uid ~= -1 then
        local weapon = get_entity(ent.holding_uid)
        if weapon then
            if weapon.cooldown == 0 then
                -- This is a gun or scepter and it's off cooldown.
                return true
            elseif weapon.holding_uid ~= -1 then
                local arrow = get_entity(weapon.holding_uid)
                if arrow then
                    -- This is a bow or crossbow and it's loaded with an arrow.
                    return true
                end
            end
        end
    end
    return false
end

-- This is only accurate for positions within the level bounds. Out-of-bounds room detection is inconsistent, calculating the bounds of those rooms is complicated, and that edge case is not supported by this script.
function module.get_room_bounds(x, y)
    local left, top = get_room_pos(get_room_index(x, y))
    return left, top - CONST.ROOM_HEIGHT, left + CONST.ROOM_WIDTH, top
end

-- TODO: Show while turning for entities with turn animations. Can't just check for the turning move_state because they also use that state when turning for dialog. How do they keep track of their aggro state while turning?
function module.create_chaser_turn_range(attack_move_state, turn_timer_field)
    return {
        shape = geometry.create_donut_shape(3, 4):clip_right(0),
        flip_with_ent = true,
        is_visible = function(ent)
            -- TODO: Climbers can have a lot of ranges. Maybe don't show these at all when climbing.
            -- TODO: Climbing irrelevant for enemies that can't do that.
            return ent.move_state == attack_move_state -- or ent.move_state == MOVE_STATE.CLIMBING
        end,
        is_inactive_when_stuck = false,
        is_active = function(ent)
            return ent.standing_on_uid ~= -1 and ent[turn_timer_field] == 0
        end,
        label = "Turn",
        label_position = LABEL_POSITION.LEFT
    }
end

-- TODO: Show while turning for entities with turn animations. Can't just check for the turning move_state because they also use that state when turning for dialog. How do they keep track of their aggro state while turning?
function module.create_chaser_postpone_turn_range(attack_move_state, turn_timer_field)
    return {
        shape = geometry.create_donut_shape(3, 4):clip_left(0),
        flip_with_ent = true,
        is_visible = function(ent)
            -- TODO: Climbers can have a lot of ranges. Maybe don't show these at all when climbing.
            -- TODO: Climbing irrelevant for enemies that can't do that.
            return ent.move_state == attack_move_state -- or ent.move_state == MOVE_STATE.CLIMBING
        end,
        is_inactive_when_stuck = false,
        is_active = function(ent)
            return ent.standing_on_uid ~= -1 and ent[turn_timer_field] == 0
        end,
        label = "Postpone turn",
        label_position = LABEL_POSITION.RIGHT
    }
end

-- TODO: There is more complexity to this than I thought. Some combination of ai_state (or the equivalent field for non-RoomOwners), nearby floors (up to 3 tall?), and other unknown factors prevents jumping when the player is up to 1 tile above and any distance away. I've also seen cat mummies start jumping in small holes specifically when the player is in this range, and not outside it.
function module.create_chaser_no_jump_range(attack_move_state)
    return {
        shape = geometry.create_circle_shape(8):clip_top(0.2),
        is_visible = function(ent)
            return ent.move_state == attack_move_state
        end,
        is_active = function(ent)
            -- TODO: Is this based on standing_on_uid or stand_counter?
            return ent.standing_on_uid ~= -1
        end,
        label = "No jump"
    }
end

return module
