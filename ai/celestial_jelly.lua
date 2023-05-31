return Entity_AI:new({
    id = "celestial_jelly",
    name = "Celestial jelly",
    ent_type = ENT_TYPE.MONS_MEGAJELLYFISH,
    targetting = {
        id_field = "chased_target_uid"
    }
})
