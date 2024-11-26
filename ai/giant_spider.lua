return Entity_AI:new({
    id = "giant_spider",
    name = "Giant spider",
    ent_type = ENT_TYPE.MONS_GIANTSPIDER,
    ranges = {
        { -- Aggro
            -- TODO: Width is controlled by trigger_distance field, which defaults to 0.95 for this entity type.
            shape = geometry.create_circle_shape(7):clip_box(-0.95, nil, 0.95, 0),
            is_visible = function(ent)
                return ent.state == CHAR_STATE.HANGING
            end,
            label = "Aggro",
        }
    }
})
