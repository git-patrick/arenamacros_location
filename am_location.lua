am_location = { }

function am_location.select(self, arg1, arg2, checked)
    am_location.button.am_data[self.value] = checked or nil
    
    am_location.setmenuchecks(am_location.menu, am_location.button.am_data)
end

-- this takes a table called where the existence of a key tells the
function am_location.setmenuchecks(menu, data)
    for i, v in ipairs(menu) do
        if (v.value and data[v.value]) then
            v.checked = "true"
        else
            v.checked = nil
        end
        
        if (v.menuList) then
            am_location.setmenuchecks(v.menuList, data)
        end
    end
end

function am_location.set_text(button)
    if (type(button.am_data) == "table") then
        button:SetText("...")
    else
        button:SetText(button.am_data)
    end
end

-- value_init and relation_init may to exist, and if they do, are called when the condition is selected
function am_location.relation_init(button)
    button.am_data = "is"
    
    am_location.set_text(button)
end

function am_location.value_init(button)
    button.am_data = { ["none"] = true }
    
    am_location.set_text(button)
end


-- value_onclick and relation_onclick are required to exist, and are called when the value and relation buttons are pressed with your addon selected
function am_location.value_onclick(button)
    am_location.setmenuchecks(am_location.menu, button.am_data)
    am_location.button = button

    AMConditionMenuFrame:SetPoint("CENTER", button, "CENTER")
                        
    EasyMenu(am_location.menu, AMConditionMenuFrame, AMConditionMenuFrame, 0, 0, "MENU", 1)
end
function am_location.relation_onclick(button)
    if (button.am_data == "is") then
        button.am_data = "is not"
    else
        button.am_data = "is"
    end
    
    am_location.set_text(button)
end



-- .test() is required for all addons, it is used to test the state of the condition.  should return true / false!  .init() is called if it exists once the parent addon is setup
function am_location.test(relation, value)
    local inst, type = IsInInstance()
    
    local ret
    
    if (type ~= "arena") then
        if (value.data[type]) then
            ret = true
        else
            ret = false
        end
    else
        local num = GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE)

        print(type .. " " .. num .. "v" .. num)
        
        if (value.data[type .. " - " .. num .. "v" .. num]) then
            ret = true
        else
            ret = false
        end
    end

    if (relation.data ~= "is") then
        ret = not ret
    end

    return ret
end

function am_location.init()
    AMConditionTriggerFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

    AMConditionTriggerFrame:RegisterEvent("ZONE_CHANGED");
    AMConditionTriggerFrame:RegisterEvent("ZONE_CHANGED_INDOORS");
    AMConditionTriggerFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
end

am_location.main_menu = { text = "Location", value = "Location", func = am.addons.select, leftPadding="10", notCheckable = true }

am_location.menu = {
    {   text = "Locations",
        isTitle = "true",
        notCheckable = true
    },
    {
        text = "Arena",
        hasArrow = true,
        notCheckable = true,

        menuList = {
            { text = "2v2", value = "arena - 2v2", func = am_location.select, leftPadding="5", keepShownOnClick="1" },
            { text = "3v3", value = "arena - 3v3", func = am_location.select, leftPadding="5", keepShownOnClick="1" },
            { text = "5v5", value = "arena - 5v5", func = am_location.select, leftPadding="5", keepShownOnClick="1" }
        }
    },
    { text = "World", value = "none", func = am_location.select, leftPadding="5", keepShownOnClick="1" },
    { text = "Battleground", value = "battleground", func = am_location.select, leftPadding="5", keepShownOnClick="1" },
    { text = "Instance", value = "party", func = am_location.select, leftPadding="5", keepShownOnClick="1" },
    { text = "Raid Instance", value = "raid", func = am_location.select, leftPadding="5", keepShownOnClick="1" }
}

am.addons.add("Location", am_location)