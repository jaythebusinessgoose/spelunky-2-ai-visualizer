-- If a caveman is riding the rock dog, then the caveman's aggro_timer controls when the rock dog stops running around after attacking.
return Entity_AI:new({
    id = "rock_dog",
    name = "Rock dog",
    ent_type = ENT_TYPE.MOUNT_ROCKDOG,
    preprocess = function(ent, ctx)
        local rider_ent = get_entity(ent.rider_uid)
        if rider_ent and rider_ent.type.id == ENT_TYPE.MONS_CAVEMAN then
            ctx.hostile_rider_ent = rider_ent
        end
    end,
    ranges = {
        { -- Attack
            shape = geometry.create_box_shape(0, -0.4, 6, 0.4),
            flip_with_ent = true,
            is_blocked_by_solids = true,
            is_visible = function(ent, ctx)
                return not ent.tamed or ctx.hostile_rider_ent
            end,
            is_active = function(ent, ctx)
                -- Rock dogs have a simulated attack input which they press and hold down while a target is in range. The attack only happens once on the first frame that the input is pressed, unless the rock dog has a hostile rider. The rock dog can't attack again until no targets are in range and it releases its attack input for at least one frame.
                -- TODO: They seem to sometimes release their attack when the target is close to a wall.
                return ent.attack_cooldown == 0 and (ctx.hostile_rider_ent or not test_flag(ent.buttons, BUTTON.WHIP))
            end,
            label = "Attack"
        }
    }
})
