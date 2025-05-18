return Entity_AI:new({
    id = "giant_spider",
    name = "Giant spider",
    ent_type = ENT_TYPE.MONS_GIANTSPIDER,
    ranges = {
        { -- Aggro
            -- TODO: Width is controlled by trigger_distance field, which defaults to 0.95 for this entity type.
            shape = geometry.create_box_shape(-0.95, -7, 0.95, 0),
            is_visible = function(ent)
                return ent.state == CHAR_STATE.HANGING
            end,
            label = "Aggro",
        },
        { -- Small Jump
            shape = geometry.create_box_shape(-1000, -1000, 1000, 0),
            is_visible = function(ent)
                return ent.state ~= CHAR_STATE.HANGING and ent.move_state == 0
            end,
            is_active = function(ent)
                return ent.jump_timer == 0
            end,
            label = "Small Jump",
        }
    }
})
