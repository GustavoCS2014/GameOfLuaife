function ToString(color)
    return "(" .. color[1] .. ", " .. color[2] .. ", " .. color[3] .. ", " .. color[4] .. ")"
end

function NewColor(r,g,b,a)
    local tmpColor = {}
    tmpColor[1] = r
    tmpColor[2] = g
    tmpColor[3] = b
    tmpColor[4] = a
    return tmpColor
end

function SetColor(color)
    local tmpColor = {}
    tmpColor[1] = color[1]
    tmpColor[2] =  color[2]
    tmpColor[3] =  color[3]
    tmpColor[4] =  color[4]
    return tmpColor
end

function CompareColors(color1, color2)
    if color1[1] ~= color2[1] then
        return false
    end
    if color1[2] ~= color2[2] then
        return false
    end
    if color1[3] ~= color2[3] then
        return false
    end
    if color1[4] ~= color2[4] then
        return false
    end

    return true
end

function FindMostFrecuentColor(colorList)
    local colors = {}
    local colorCounts = {}
    
    for i = 1, #colorList do
        match, index = FindColorInTable(colors, colorList[i])
        if(match) then
            colorCounts[colors[index]] = colorCounts[colors[index]]+1
        else
            colors[#colors+1] = colorList[i]
            colorCounts[colors[#colors]] = 1
        end
    end

    -- Find the most frequent color
    local mostFrequentColor = nil
    local maxCount = 0
    for color, count in pairs(colorCounts) do
        -- print(ToString(color) .. ", " .. count)
        if count > maxCount then
            mostFrequentColor = color
            maxCount = count
        end
    end

    return mostFrequentColor, maxCount

end

function FindColorInTable(table, color)
    local found = false
    for i = 1, #table do
        
        if(CompareColors(table[i], color)) then
            found = true
            return found, i
        end
    end
    return found, 0
end
