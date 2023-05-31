return Entity_AI:new({
    id = "eggplant_king",
    name = "Eggplant king",
    ent_type = ENT_TYPE.MONS_YAMA,
    ranges = {
        { -- Dialog
            shape = geometry.create_circle_shape(4),
            is_visible = function(ent)
                return not ent.message_shown
            end,
            label = "Dialog"
        }
    }
})
