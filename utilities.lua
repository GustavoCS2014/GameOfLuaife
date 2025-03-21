function ToString(color)
    return "(" .. color[1] .. ", " .. color[2] .. ", " .. color[3] .. ", " .. color[4] .. ")"
end

function printGrid(grid, width, height)
    for x = 0, width-1 do
        for y = 0, height -1 do
            
        end
    end
end

function newColor(r,g,b,a)
    local tmpColor = {}
    tmpColor[1] = r
    tmpColor[2] = g
    tmpColor[3] = b
    tmpColor[4] = a
    return tmpColor
end

function setColor(color)
    local tmpColor = {}
    tmpColor[1] = color[1]
    tmpColor[2] =  color[2]
    tmpColor[3] =  color[3]
    tmpColor[4] =  color[4]
    return tmpColor
end