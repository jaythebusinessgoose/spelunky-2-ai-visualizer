return Entity_AI:new({
    id = "crab",
    name = "Crab",
    ent_type = ENT_TYPE.MONS_CRITTERCRAB,
    ranges = {
        { -- Move away or approach
            -- TODO: Friendly crab only approaches if within the 3 tile semicircle AND greater than 0.1 tiles from the player horizontally (height doesn't matter). This makes it jitter back and forth at the player's feet when it is very close.
            shape = geometry.create_circle_shape(3):clip_bottom(0),
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING
            end,
            label = function(ent)
                return ent.unfriendly and "Move away" or "Approach"
            end
        }
    }
})
