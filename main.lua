
CANVAS_WIDTH = 100
CANVAS_HEIGHT = 100
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 800

local simulationGrid = {}


local simulationCanvas
local finalCanvas
local started = false
local mousePos = {}


function CreateGrid(array)
    array = {}
    for i = 0, CANVAS_WIDTH-1 do
        array[i] = {}
        for j = 0, CANVAS_HEIGHT-1 do
            array[i][j] = 0
        end
    end
    return array
end

function DisplayGrid(grid, canvasData)

    for i = 0, CANVAS_WIDTH-1 do
        for j = 0, CANVAS_HEIGHT-1 do
            -- print(i.. ", " .. j)
            if(grid[i][j] == 1) then
                canvasData:setPixel(i,j,1,1,1,1)
            else
                canvasData:setPixel(i,j,0,0,0,0)
            end
        end
    end

end

function lifeCalculation(grid)
    local newGrid = {}
    newGrid = CreateGrid(newGrid)
    local cellsAlive = 0
    for x = 0, CANVAS_WIDTH - 1 do
        for y = 0, CANVAS_HEIGHT - 1 do
            local aliveNeighbours = ScanNeighbours(x,y)

            -- Stay
            if aliveNeighbours == 2  and grid[x][y] == 1 then
                newGrid[x][y] = 1
                if(x == 1 and y == 2) then print("stayed 2, " .. newGrid[x][y]) end
                goto nextLoop
            end

            if aliveNeighbours == 3  and grid[x][y] == 1 then
                if(x == 1 and y == 2) then print("stayed 3") end
                newGrid[x][y] = 1
                goto nextLoop
            end


            -- under population
            if aliveNeighbours < 2 and grid[x][y] == 1 then
                if(x == 1 and y == 2) then print("Underpopulated") end
                newGrid[x][y] = 0
                goto nextLoop 
            end
            -- over population
            if aliveNeighbours > 3 and grid[x][y] == 1 then
                if(x == 1 and y == 2) then print("Overpopulated") end
                newGrid[x][y] = 0
                goto nextLoop
            end
            -- birth
            if aliveNeighbours == 3 and grid[x][y] == 0 then
                if(x == 1 and y == 2) then print("Brithed") end
                newGrid[x][y] = 1
                goto nextLoop
            end

            ::nextLoop::
            -- print("( " .. x .. ", " .. y .. " ) " .. " - " .. grid[x][y] .." ngbrs = " .. aliveNeighbours .. " => " .. newGrid[x][y])

            -- cellsAlive = cellsAlive + newGrid[x][y]
        end
    end
    -- print(cellsAlive)
    return newGrid
end

function ScanNeighbours(x,y)
    local aliveNeighbours = 0

    for i = x-1, x+1 do
        for j = y-1, y+1 do

            local tempX = i
            local tempY = j
            
            if(tempX == x and tempY == y) then goto nextNeighbour end
            if(tempX < 0) then
                tempX = tempX + CANVAS_WIDTH 
            elseif(tempX >= CANVAS_WIDTH) then
                tempX = tempX - (CANVAS_WIDTH)
            end
            if(tempY < 0) then
                tempY = tempY + CANVAS_HEIGHT
            elseif(tempY >= CANVAS_HEIGHT) then
                tempY = tempY - (CANVAS_HEIGHT)
            end

            aliveNeighbours = aliveNeighbours + simulationGrid[tempX][tempY]
            if(x == 1 and y == 2)then
                print(tempX..", " .. tempY .. "-> " .. simulationGrid[tempX][tempY])
            end
            
            ::nextNeighbour::
        end
    end
    
    if(x == 1 and y == 2)then
        print(aliveNeighbours)
    end
    return aliveNeighbours

end

--!-------------------------------------------------------------------
--!                      LOAD METHOD
--!-------------------------------------------------------------------

function love.load()
    --! Importan Variables
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {resizable = true})
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.filesystem.setIdentity("Game Of Life", false)
    

    simulationCanvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
    SimulationData = simulationCanvas:newImageData()

    simulationGrid = CreateGrid(simulationGrid);

    
    --! Setting Canvas
    SimulationTransform = love.math.newTransform()
    SimulationTransform:scale(1,1)
    
    finalCanvas = love.graphics.newCanvas()

    --! Shaders
    local fragdir = love.filesystem.read('shader.frag')
    
    love.resize(WINDOW_WIDTH, WINDOW_HEIGHT)
end

--!-------------------------------------------------------------------
--!                      UPDATE LOOP
--!-------------------------------------------------------------------

function love.update(dt)

    --! Getting mouse pos
    mousePos.x, mousePos.y = love.mouse.getPosition()
    -- if(mousePos.x > )
    mpx = math.floor((mousePos.x)/(WidthRatio) )
    mpy = math.floor((mousePos.y)/(HeightRatio))


        
    if not started then 
        --!Draw shortcut
        if(love.mouse.isDown(1)) then
            simulationGrid[mpx][mpy] = 1
        end
    
        --!Erase shortcut
        if(love.mouse.isDown(2)) then
            simulationGrid[mpx][mpy] = 0
        end
    end

    if started then
        simulationGrid = lifeCalculation(simulationGrid)
    end

    DisplayGrid(simulationGrid, SimulationData)

    
end 

--!-------------------------------------------------------------------
--!                   WINDOW RESIZE CALLBACK
--!-------------------------------------------------------------------
function love.resize(w, h)
    --! Checking the biggest size for the canvas.
    WINDOW_HEIGHT = h
    WINDOW_WIDTH = w
    
    WidthRatio = WINDOW_WIDTH/CANVAS_WIDTH
    HeightRatio = WINDOW_HEIGHT  /CANVAS_HEIGHT
    
    finalCanvas = love.graphics.newCanvas(w,h)
    SimulationTransform:scale(WidthRatio, HeightRatio)
end


--!-------------------------------------------------------------------
--!                      DRAW LOOP
--!-------------------------------------------------------------------

function love.draw()

    local simulationImage = love.graphics.newImage(SimulationData)

    --! First Render pass
    love.graphics.setCanvas(finalCanvas)
    love.graphics.clear()--clear display
    love.graphics.setBackgroundColor(0.286, 0.31, 0.31,1)
    --draw any stuff here
    
    
    
    
    
    love.graphics.setColor(.3,.3,.3,.3)
    -- if not showFinalGraphic then
    for x = 1, CANVAS_WIDTH do
        love.graphics.line(x * (WidthRatio), 0,x * (WidthRatio),CANVAS_HEIGHT*HeightRatio)
    end

    for y = 1, CANVAS_HEIGHT do
        love.graphics.line(0, y * (HeightRatio), CANVAS_WIDTH*WidthRatio, y * (HeightRatio))
    end

    love.graphics.setColor(1,1,1,1)

    love.graphics.draw(simulationImage, SimulationTransform)        
    -- love.graphics.draw(pixelCanvas, 0,0, 0, CanvasScaling)

    love.graphics.setCanvas()  

    --! Final Render Pass

    love.graphics.draw(finalCanvas)

    love.graphics.print("mp" .. mpx .. ", " .. mpy, 10 , 10)

end

-- ! -----------------------------------------------------------------------------
-- !                    INPUT HANDLING
-- ! -----------------------------------------------------------------------------

function love.keypressed(key, scancode, isrepeat)
    if(key == "backspace") then
        return;
    end
    if(key == "escape") then
        love.event.quit()
        return;
    end
    if(key == "return") then
        started = true
        return;
    end
    if(key == "space") then
        if(started) then
            simulationGrid = lifeCalculation(simulationGrid)
        end
    end
end
