-- A "chaser" is a ground-based AI type that runs, turns, jumps, and climbs based on the location of their target. RoomOwners, NPCs, and a few other entities utilize some subset of this chasing behavior.
-- "NPC" is often used as the name for the AI types of both NPCs and RoomOwners, since RoomOwners are basically just NPCs with extra room ownership behavior. The caveman shopkeeper does not use the RoomOwner class.

local module = {}

-- TODO: These values aren't the same across all entities. States are typically the same for similar types of entities (such as NPCs), but are used for unrelated behaviors for dissimilar entities.
module.MOVE_STATE = {
    TURNING = 3,
    ATTACKING = 6,
    CLIMBING = 11
}

local NPC_USABLE_ITEM_CLASS = {
    GUN = {
        action_name = "Shoot",
        can_use_now = function(item)
            return item.cooldown == 0
        end
    },
    BOW = {
        action_name = "Shoot",
        can_use_now = function(item)
            return item.holding_uid ~= -1
        end
    },
    SWINGABLE = {
        action_name = "Swing",
        can_use_now = function(item)
            return item.state == CHAR_STATE.STANDING
        end
    },
    THROWABLE = {
        action_name = "Throw",
        can_use_now = function(item)
            return true
        end
    },
    TELEPORTER = {
        action_name = "Teleport",
        can_use_now = function(item)
            return item.teleport_number < 3
        end
    }
}

-- NPCs can use these items if their target is within their attack range. NPCs still try to attack when holding other entities, but those entities will remain held and not do anything.
local NPC_USABLE_ITEMS = {
    [ENT_TYPE.ITEM_WEBGUN] = NPC_USABLE_ITEM_CLASS.GUN,
    [ENT_TYPE.ITEM_SHOTGUN] = NPC_USABLE_ITEM_CLASS.GUN,
    [ENT_TYPE.ITEM_FREEZERAY] = NPC_USABLE_ITEM_CLASS.GUN,
    [ENT_TYPE.ITEM_CROSSBOW] = NPC_USABLE_ITEM_CLASS.BOW,
    [ENT_TYPE.ITEM_CAMERA] = NPC_USABLE_ITEM_CLASS.GUN,
    [ENT_TYPE.ITEM_TELEPORTER] = NPC_USABLE_ITEM_CLASS.TELEPORTER,
    [ENT_TYPE.ITEM_MATTOCK] = NPC_USABLE_ITEM_CLASS.SWINGABLE,
    [ENT_TYPE.ITEM_BOOMERANG] = NPC_USABLE_ITEM_CLASS.THROWABLE,
    [ENT_TYPE.ITEM_MACHETE] = NPC_USABLE_ITEM_CLASS.SWINGABLE,
    [ENT_TYPE.ITEM_EXCALIBUR] = NPC_USABLE_ITEM_CLASS.SWINGABLE,
    [ENT_TYPE.ITEM_BROKENEXCALIBUR] = NPC_USABLE_ITEM_CLASS.SWINGABLE,
    [ENT_TYPE.ITEM_PLASMACANNON] = NPC_USABLE_ITEM_CLASS.GUN,
    [ENT_TYPE.ITEM_SCEPTER] = NPC_USABLE_ITEM_CLASS.GUN,
    [ENT_TYPE.ITEM_CLONEGUN] = NPC_USABLE_ITEM_CLASS.GUN,
    [ENT_TYPE.ITEM_HOUYIBOW] = NPC_USABLE_ITEM_CLASS.BOW
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
    return ent.overlay ~= nil and ent.overlay.rider_uid == ent.uid
end

-- This is only accurate for positions within the level bounds. Out-of-bounds room detection is inconsistent, calculating the bounds of those rooms is complicated, and that edge case is not supported by this script.
function module.get_room_bounds(x, y)
    local left, top = get_room_pos(get_room_index(x, y))
    return left, top - CONST.ROOM_HEIGHT, left + CONST.ROOM_WIDTH, top
end

-- Checks whether there is a solid grid entity within the grid tile at the given point, using the same behavior as the game engine. Notably, this will return true even if the grid entity's hitbox is smaller than the grid tile and does not overlap the point itself.
function module.is_point_solid_grid_entity(x, y, layer)
    local ent = get_entity(get_grid_entity_at(math.floor(x + 0.5), math.floor(y + 0.5), layer))
    return ent ~= nil and test_flag(ent.flags, ENT_FLAG.SOLID)
end

-- Checks whether there is a solid active floor entity at the given point, using the same behavior as the game engine. Hitbox edges and corners count as overlap with the point.
function module.is_point_solid_active_floor(x, y, layer)
    -- Spelunky's point overlap check includes hitbox edges and corners, but Overlunky's hitbox overlap check does not. To work around this, add some padding to ensure that the Overlunky function returns all potentially overlapping entities. Then do another check on each solid entity to see if any of them actually overlap the point, including edges and corners. Spelunky doesn't have any padding of its own for this check.
    local ids = get_entities_overlapping_hitbox(0, MASK.ACTIVEFLOOR,
        AABB:new(x - 0.0001, y + 0.0001, x + 0.0001, y - 0.0001), layer)
    for _, id in ipairs(ids) do
        if test_flag(get_entity(id).flags, ENT_FLAG.SOLID) then
            local hitbox = get_hitbox(id)
            if hitbox.left <= x and x <= hitbox.right and hitbox.bottom <= y and y <= hitbox.top then
                return true
            end
        end
    end
    return false
end

-- Checks if either `is_point_solid_grid_entity` or `is_point_solid_active_floor` are true at the given point. Many entities use both of these checks together.
function module.is_point_solid_grid_entity_or_active_floor(x, y, layer)
    return module.is_point_solid_grid_entity(x, y, layer) or module.is_point_solid_active_floor(x, y, layer)
end

-- Returns whether an NPC entity is holding a usable item and is in the attacking AI state.
function module.npc_use_held_item_range_visible(ent)
    if ent.move_state == module.MOVE_STATE.ATTACKING then
        local item = get_entity(ent.holding_uid)
        return item ~= nil and NPC_USABLE_ITEMS[item.type.id] ~= nil
    end
    return false
end

-- Returns whether an NPC entity is ready to use its held item, and the item is ready to be used. This function assumes that `npc_use_held_item_range_visible` returned true.
function module.npc_use_held_item_range_active(ent)
    if ent.state ~= CHAR_STATE.ATTACKING and ent.buttons & BUTTON.WHIP == 0 then
        local item = get_entity(ent.holding_uid)
        return NPC_USABLE_ITEMS[item.type.id].can_use_now(item)
    end
    return false
end

function module.npc_use_held_item_range_label(ent)
    local item = get_entity(ent.holding_uid)
    if item then
        local usable_item = NPC_USABLE_ITEMS[item.type.id]
        if usable_item then
            return usable_item.action_name
        end
    end
    return "Use held item"
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
