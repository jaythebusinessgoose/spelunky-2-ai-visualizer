return Entity_AI:new({
    id = "mole",
    name = "Mole",
    ent_type = ENT_TYPE.MONS_MOLE,
    ranges = {
        { -- Emerge
            -- Moles have an erratic countdown_for_appearing variable that decrements every time the mole digs into a new tile, regardless of whether a player is near. If a player is in range while it's at 0, then the mole will move directly towards the player until it either hits air or an undiggable tile. If it hits air, then it emerges. Otherwise, it resets the counter and goes back to digging randomly. If the player moves out of range while it's digging towards them, it will go back to digging randomly, but the counter will stay at 0.
            -- TODO: Moles trapped in a single tile do not move randomly. When a player is in range, they ignore countdown_for_appearing and try to emerge towards the player immediately. They do not create any dirt particles while not moving, so this is why this kind of mole seems to appear with no warning.
            shape = geometry.create_circle_shape(8),
            is_visible = function(ent)
                return ent.move_state == 9 and ent.digging_state == 2
            end,
            is_active = function(ent)
                return ent.countdown_for_appearing == 0
            end,
            label = "Emerge"
        }
    }
})
