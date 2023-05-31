return Entity_AI:new({
    id = "spider",
    name = "Spider",
    ent_type = ENT_TYPE.MONS_SPIDER,
    ranges = {
        { -- Aggro
            -- TODO: Width is controlled by trigger_distance field, which defaults to 0.4 for this entity type.
            shape = geometry.create_box_shape(-0.4, -7, 0.4, 0),
            is_visible = function(ent)
                return ent.state == CHAR_STATE.HANGING
            end,
            label = "Aggro"
        }
    }
})
