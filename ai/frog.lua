return Entity_AI:new({
    id = "frog",
    name = "Frog & fire frog",
    ent_type = { ENT_TYPE.MONS_FROG, ENT_TYPE.MONS_FIREFROG },
    ranges = {
        { -- Jump
            -- TODO: Can it jump while eating a grub?
            shape = geometry.create_circle_shape(8),
            is_active = function(ent)
                return ent.state == CHAR_STATE.STANDING and ent.jump_timer == 0
            end,
            label = "Jump"
        }
    }
})
