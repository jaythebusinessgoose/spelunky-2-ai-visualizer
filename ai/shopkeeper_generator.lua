return Entity_AI:new({
    id = "shopkeeper_generator",
    name = "Shopkeeper generator",
    ent_type = ENT_TYPE.FLOOR_SHOPKEEPER_GENERATOR,
    ranges = {
        { -- Spawn
            shape = geometry.create_circle_shape(8),
            is_active = function(ent)
                return ent.timer == 0 and ent.spawned_uid == -1
            end,
            label = "Spawn"
        }
    }
})
