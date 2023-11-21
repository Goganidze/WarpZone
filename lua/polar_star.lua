return function(mod)
    
    local function swapOutActive(activeToAdd, slot, player, charge)
        local activeToRemove = player:GetActiveItem(slot)
        player:RemoveCollectible(activeToRemove, true, slot, true)
        player:AddCollectible(activeToAdd, charge, false, slot)
    end


    function WarpZone.PolarStar_Use(collectible, rng, player, useflags )
        --swapOutActive(WarpZone.WarpZoneTypes.COLLECTIBLE_BOOSTERV2, slot, player, charge)
    end
    WarpZone:AddCallback(ModCallbacks.MC_USE_ITEM, WarpZone.PolarStar_Use, WarpZone.WarpZoneTypes.COLLECTIBLE_POLARSTAR)

end