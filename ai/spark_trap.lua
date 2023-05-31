return Entity_AI:new({
    id = "spark_trap",
    name = "Spark trap",
    ent_type = ENT_TYPE.FLOOR_SPARK_TRAP,
    ranges = {
        { -- Activate
            shape = geometry.create_box_shape(-8, -8, 8, 8),
            type = Entity_AI.RANGE_TYPE.HITBOX_OVERLAP,
            label = "Activate"
        }
    }
})
