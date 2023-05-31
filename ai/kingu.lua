-- Kingu moves exactly (1.55, 0) tiles horizontally, or (~1.096, ~1.096) (1.55 * sqrt(2) / 2) tiles diagonally for each cycle. Kingu does not move straight up or down. This means that any X position is eventually possible, but Y positions start at 111 and change in increments of ~1.096.

local MIN_X = 10
-- TODO: MAX_X based on level state.width, not hard-coded.
local MAX_X = (4 * CONST.ROOM_WIDTH) - 4
local MIN_Y = 107
local MAX_Y = 113

local function get_move_label(ent, can_move_x_left, can_move_x_right, can_move_y_down, can_move_y_neutral, can_move_y_up)
    if ent.x < MIN_X then
        can_move_x_left = false
        can_move_x_right = true
    elseif ent.x > MAX_X then
        can_move_x_left = true
        can_move_x_right = false
    end
    if ent.y < MIN_Y then
        can_move_y_up = can_move_y_up or not can_move_y_neutral
        can_move_y_neutral = can_move_y_neutral or can_move_y_down
        can_move_y_down = false
    elseif ent.y > MAX_Y then
        can_move_y_down = can_move_y_down or not can_move_y_neutral
        can_move_y_neutral = can_move_y_neutral or can_move_y_up
        can_move_y_up = false
    end
    if can_move_x_left and can_move_x_right and can_move_y_down and can_move_y_neutral and can_move_y_up then
        return "Move random"
    end
    local x_text
    if can_move_x_left then
        x_text = "left"
    end
    if can_move_x_right then
        x_text = x_text and (x_text.."/right") or "right"
    end
    local y_text
    if can_move_y_down or can_move_y_up then
        if can_move_y_down then
            y_text = "down"
        end
        if can_move_y_neutral then
            y_text = y_text and (y_text.."/neutral") or "neutral"
        end
        if can_move_y_up then
            y_text = y_text and (y_text.."/up") or "up"
        end
    end
    local move_text = "Move "
    if y_text then
        move_text = move_text..y_text
    end
    if x_text then
        move_text = y_text and (move_text.." & "..x_text) or (move_text..x_text)
    end
    return move_text
end

return Entity_AI:new({
    id = "kingu",
    name = "Kingu",
    ent_type = ENT_TYPE.MONS_KINGU,
    ranges = {
        { -- Add journal sticker
            -- TODO: Still active even if Kingu is dead. Could exist after fight if Kingu killed remotely with bombs.
            shape = geometry.create_box_shape(-8, -4, 8, 4),
            is_visible = function(ent)
                return not ent.player_seen_by_kingu
            end,
            label = "Add journal sticker",
            label_position = LABEL_POSITION.BOTTOM
        },
        { -- Spawn
            -- Monsters are spawned when monster_spawn_timer equals 60, 30 and 0. The timer starts at 90 and only counts down while the player is in range.
            shape = geometry.create_circle_shape(5),
            is_active = function(ent)
                return ent.move_state == 0 and ent.monster_spawn_timer > 0
            end,
            label = "Spawn",
            label_position = LABEL_POSITION.TOP
        },
        { -- Move random
            -- AI bug: This range extends infinitely left, but not right.
            shape = geometry.create_box_shape(-1000, -6, 5, 6),
            label = function(ent)
                return get_move_label(ent, true, true, true, true, true)
            end,
            label_position = LABEL_POSITION.RIGHT
        },
        { -- Move up & left/right
            shape = geometry.create_box_shape(-1000, -1000, 1000, -6),
            label = function(ent)
                return get_move_label(ent, true, true, false, false, true)
            end,
            label_position = LABEL_POSITION.TOP
        },
        { -- Move up & left/right
            shape = geometry.create_box_shape(-1000, 6, 1000, 1000),
            label = function(ent)
                return get_move_label(ent, true, true, false, false, true)
            end,
            label_position = LABEL_POSITION.BOTTOM
        },
        { -- Move right
            shape = geometry.create_box_shape(5, -3, 1000, 3),
            label = function(ent)
                return get_move_label(ent, false, true, false, true, false)
            end,
            label_position = LABEL_POSITION.LEFT
        },
        { -- Move down & right
            shape = geometry.create_box_shape(5, -6, 1000, -3),
            label = function(ent)
                return get_move_label(ent, false, true, true, false, false)
            end,
            label_position = LABEL_POSITION.LEFT
        },
        { -- Move up & right
            shape = geometry.create_box_shape(5, 3, 1000, 6),
            label = function(ent)
                return get_move_label(ent, false, true, false, false, true)
            end,
            label_position = LABEL_POSITION.LEFT
        },
        { -- Move limit
            -- AI bug: This range is not horizontally centered within the level.
            shape = geometry.create_box_shape(MIN_X, MIN_Y, MAX_X, MAX_Y),
            type = Entity_AI.RANGE_TYPE.MISC,
            translate_shape = function(ent)
                return 0, 0
            end,
            label = "Move limit"
        }
    }
})
