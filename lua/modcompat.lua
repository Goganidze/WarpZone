return function()

    local delayfuncs = {}

    if FiendFolio then
        local tab = FiendFolio.PocketObjectMimicCharges

        local mimiccharge = {
            [WarpZone.WarpZoneTypes.CARD_COW_TRASH_FARM] = 1,
            [WarpZone.WarpZoneTypes.CARD_JESTER_CUBE] = 6,
            [WarpZone.WarpZoneTypes.CARD_WITCH_CUBE] = 5,
            [WarpZone.WarpZoneTypes.CARD_BLANK] = 3,
            [WarpZone.WarpZoneTypes.CARD_BLANK_2] = 3,
            [WarpZone.WarpZoneTypes.CARD_BLANK_3] = 3,
            [WarpZone.WarpZoneTypes.CARD_AMBER_CHUNK] = 4,
        }

        delayfuncs[#delayfuncs + 1] = function()
            for card, charge in pairs(mimiccharge) do
                tab[card] = charge
            end
        end
    end

    if not Isaac.GetPlayer() then
        local once = false
        WarpZone:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
            if not once then
                for _, func in ipairs(delayfuncs) do
                    func()
                end
                once = true
            end
        end)
    else
        for _, func in ipairs(delayfuncs) do
            func()
        end
    end


end