-- TODO: Monkeys sometimes attack other monsters. I can't figure out the conditions for this, but it seems to have the same range. They'll only target monsters when they're not on a vine. It's like there are a few specific entities that the monkeys are allowed to attack. The level can generate two seemingly identical mantraps, but the monkeys will only ever target one of them. They never attack anything I spawn myself. Newly spawned monkeys only attack the same enemies as the naturally spawned monkeys.
return Entity_AI:new({
    id = "monkey",
    name = "Monkey",
    ent_type = ENT_TYPE.MONS_MONKEY,
    targetting = {
        -- TODO: Monkeys use the target_selection_timer field, but it gets reset upon landing. Does it actually have any function if it has time to count down? When do they switch targets? Seems to be as often as once per frame.
        id_field = "chased_target_uid"
    },
    ranges = {
        { -- Jump
            shape = geometry.create_circle_shape(4),
            is_active = function(ent)
                return ent.move_state == 0 and ent.jump_timer == 0 and ent.falling_timer == 0
            end,
            label = "Jump"
        }
    }
})
