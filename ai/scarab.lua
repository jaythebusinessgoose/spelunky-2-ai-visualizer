-- AI bug: Scarabs have a 60 frame targetting timer, but they only decrement it for one frame between movement cycles, so they only check for a new target after moving 60 times.
return Entity_AI:new({
    id = "scarab",
    name = "Scarab",
    ent_type = ENT_TYPE.MONS_SCARAB,
    ranges = {
        { -- Move away
            shape = geometry.create_circle_shape(6):clip_top(-0.2),
            is_active = function(ent)
                -- TODO: Timer jumps from 1 to the reset value without ever staying at 0 for a frame.
                return ent.timer <= 1
            end,
            label = "Move away"
        }
    }
})
