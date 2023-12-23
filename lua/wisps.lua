return function(mod)
    local sfx = SFXManager()
    local music = MusicManager()
    local Isaac = Isaac
    local game = Game()
    local Wtr = 20/13

    function WarpZone.WispDead(_, ent)
        if ent.Type == EntityType.ENTITY_FAMILIAR and ent.Variant == FamiliarVariant.WISP then
            if ent.SubType == WarpZone.WarpZoneTypes.COLLECTIBLE_REAL_LEFT then
                if ent:GetDropRNG():RandomFloat() > .5 then
                    if ent:GetDropRNG():RandomFloat() > .65 then
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, ent.Position, Vector(0,0), ent)
                    else
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, 0, ent.Position, Vector(0,0), ent)
                    end
                end
            end
        end
    end

    WarpZone:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, WarpZone.WispDead)

end