return Entity_AI:new({
    id = "sun_challenge_generator",
    name = "Sun challenge generator",
    ent_type = ENT_TYPE.FLOOR_SUNCHALLENGE_GENERATOR,
    ranges = {
        { -- Spawn
            shape = geometry.create_circle_shape(8),
            is_active = function(ent)
                return ent.timer == 0 and ent.spawned_uid == -1 and ent.on_off
            end,
            label = "Spawn"
        }
    }
})
