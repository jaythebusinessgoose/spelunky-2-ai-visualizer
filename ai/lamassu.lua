-- TODO: Show attack range. It's within 45 degrees up and down, with the shot spawning from (0.75, 0.3) relative to the origin.
return Entity_AI:new({
    id = "lamassu",
    name = "Lamassu",
    ent_type = ENT_TYPE.MONS_LAMASSU,
    ranges = {
        { -- Attack
            shape = geometry.create_circle_shape(10):clip_box(0, -1, nil, 1),
            flip_with_ent = true,
            is_active = function(ent)
                -- TODO
                return true
            end,
            label = "Attack"
        },
        { -- Turn
            shape = geometry.create_circle_shape(10):clip_box(nil, -1, 0, 1),
            flip_with_ent = true,
            is_active = function(ent)
                -- TODO
                return true
            end,
            label = "Turn"
        }
    }
})
