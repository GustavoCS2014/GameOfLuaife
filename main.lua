require('utilities')

CANVAS_WIDTH = 50
CANVAS_HEIGHT = 50
WINDOW_WIDTH = 500  
WINDOW_HEIGHT = 500
FPS = 30

local currentColor = {}

local simulationGrid = {}


local simulationCanvas
local PreviousSimulation
local finalCanvas
local started = false
local mousePos = {}


function CreateGrid(array)
    array = {}
    for i = 0, CANVAS_WIDTH-1 do
        array[i] = {}
        for j = 0, CANVAS_HEIGHT-1 do
            array[i][j] = {
                alive = 0,
                color = {}
            }
            array[i][j].color[1] = 0
            array[i][j].color[2] = 0
            array[i][j].color[3] = 0
            array[i][j].color[4] = 0

        end
    end
    return array
end

function DisplayGrid(grid, canvasData)

    for i = 0, CANVAS_WIDTH-1 do
        for j = 0, CANVAS_HEIGHT-1 do
            -- print(i.. ", " .. j)
            if(grid[i][j].alive == 1) then
                canvasData:setPixel(i,j,grid[i][j].color)
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
            local aliveNeighbours, averageColor = ScanNeighbours(x,y)

            -- Stay
            if aliveNeighbours == 2  and grid[x][y].alive == 1 then
                if(x == 1 and y == 2) then print("stayed 2") end
                newGrid[x][y].alive = 1
                newGrid[x][y].color = averageColor
                goto nextLoop
            end

            if aliveNeighbours == 3  and grid[x][y].alive == 1 then
                if(x == 1 and y == 2) then print("stayed 3") end
                newGrid[x][y].alive = 1
                newGrid[x][y].color = averageColor
                goto nextLoop
            end

            -- birth
            if aliveNeighbours == 3 and grid[x][y].alive == 0 then
                if(x == 1 and y == 2) then print("Brithed") end
                newGrid[x][y].alive = 1
                newGrid[x][y].color = averageColor
                goto nextLoop
            end

            -- under population
            if aliveNeighbours < 2 and grid[x][y].alive == 1 then
                if(x == 1 and y == 2) then print("Underpopulated") end
                newGrid[x][y].alive = 0
                newGrid[x][y].color[1] = 0
                newGrid[x][y].color[2] = 0
                newGrid[x][y].color[3] = 0
                newGrid[x][y].color[4] = 0
                goto nextLoop 
            end
            -- over population
            if aliveNeighbours > 3 and grid[x][y].alive == 1 then
                if(x == 1 and y == 2) then print("Overpopulated") end
                newGrid[x][y].alive = 0
                newGrid[x][y].color[1] = 0
                newGrid[x][y].color[2] = 0
                newGrid[x][y].color[3] = 0
                newGrid[x][y].color[4] = 0
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
    local averageColor = {}
    averageColor[1] = 0
    averageColor[2] = 0
    averageColor[3] = 0
    averageColor[4] = 0
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

            aliveNeighbours = aliveNeighbours + simulationGrid[tempX][tempY].alive
            if(simulationGrid[tempX][tempY].alive > 0)then
                averageColor[1] = averageColor[1] + simulationGrid[tempX][tempY].color[1]
                averageColor[2] = averageColor[2] + simulationGrid[tempX][tempY].color[2]
                averageColor[3] = averageColor[3] + simulationGrid[tempX][tempY].color[3]
                averageColor[4] = averageColor[4] + simulationGrid[tempX][tempY].color[4]
            end
            
            ::nextNeighbour::
        end
    end
    
    if(aliveNeighbours > 0) then
        averageColor[1] = averageColor[1]/aliveNeighbours
        averageColor[2] = averageColor[2]/aliveNeighbours
        averageColor[3] = averageColor[3]/aliveNeighbours
        averageColor[4] = averageColor[4]/aliveNeighbours
    else
        averageColor[1] = 0
        averageColor[2] = 0
        averageColor[3] = 0
        averageColor[4] = 0    
    end

    return aliveNeighbours, averageColor

end

--!-------------------------------------------------------------------
--!                      LOAD METHOD
--!-------------------------------------------------------------------

function love.load()
    --! Importan Variables
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {resizable = false})
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.filesystem.setIdentity("Game Of Life", false)
    

    currentColor = newColor(1,1,1,1)

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

    if(started) then
        if(FPS ~= 0) then 
            local frameTime = 1/FPS
            local sleepTime = frameTime-dt
            if(sleepTime > 0) then
                love.timer.sleep(sleepTime)
            end
        end
    end
    
    --! Getting mouse pos
    mousePos.x, mousePos.y = love.mouse.getPosition()
    -- if(mousePos.x > )
    mpx = math.floor((mousePos.x)/(WidthRatio) )
    mpy = math.floor((mousePos.y)/(HeightRatio))


        
    if not started then 
        --!Draw shortcut
        if(love.mouse.isDown(1)) then
            simulationGrid[mpx][mpy].alive = 1
            simulationGrid[mpx][mpy].color = setColor(currentColor)
        end
    
        --!Erase shortcut
        if(love.mouse.isDown(2)) then
            simulationGrid[mpx][mpy].alive = 0
            simulationGrid[mpx][mpy].color = newColor(0,0,0,0)
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
    HeightRatio = WINDOW_HEIGHT/CANVAS_HEIGHT
    
    finalCanvas = love.graphics.newCanvas(w,h)
    print(WidthRatio..", " .. HeightRatio)
    SimulationTransform:scale(WidthRatio, HeightRatio)
end


--!-------------------------------------------------------------------
--!                      DRAW LOOP
--!-------------------------------------------------------------------

function love.draw()

    local simulationImage = love.graphics.newImage(SimulationData)

    --! First Render pass
    love.graphics.setBackgroundColor(0.1, 0.1, 0.12,1)
    love.graphics.setCanvas(finalCanvas)
    love.graphics.clear()--clear display
    --draw any stuff here
    
    
    
    if(not started) then
        
        love.graphics.setColor(.3,.3,.3,.3)
        -- if not showFinalGraphic then
        for x = 1, CANVAS_WIDTH do
            love.graphics.line(x * (WidthRatio), 0,x * (WidthRatio),CANVAS_HEIGHT*HeightRatio)
        end
    
        for y = 1, CANVAS_HEIGHT do
            love.graphics.line(0, y * (HeightRatio), CANVAS_WIDTH*WidthRatio, y * (HeightRatio))
        end
    end

    if(PreviousSimulation~= nil) then
        love.graphics.setColor(1,1,1,0.96)
        love.graphics.draw(PreviousSimulation)        
    end
    
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(simulationImage, SimulationTransform)        
    -- love.graphics.draw(pixelCanvas, 0,0, 0, CanvasScaling)
    love.graphics.setCanvas()  
    PreviousSimulation = love.graphics.newImage(finalCanvas:newImageData())
    
    --! Final Render Pass
    love.graphics.draw(finalCanvas)

    love.graphics.print("mp" .. mpx .. ", " .. mpy, 10 , 10)
    love.graphics.draw(simulationImage, 100, 0)
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
        return
    end
    if(key == "1") then
        currentColor = newColor(1,1,1,1)
        return
    end
    if(key == "2") then
        currentColor = newColor(0.949, 0.69, 0.165,1)
        return
    end
    if(key == "3") then
        currentColor = newColor(0.812, 0.49, 0.129,1)
        return
    end
    if(key == "4") then
        currentColor = newColor(0.545, 0.788, 0.106,1)
        return
    end
    if(key == "5") then
        currentColor = newColor(0.325, 0.42, 0.153,1)
        return
    end
    if(key == "6") then
        currentColor = newColor(0,0,1,1)
        return
    end
    if(key == "7") then
        currentColor = newColor(1,1,1,1)
        return
    end
    if(key == "8") then
        currentColor = newColor(1,1,1,1)
        return
    end
    if(key == "9") then
        currentColor = newColor(1,1,1,1)
        return
    end
    if(key == "0") then
        currentColor = newColor(1,1,1,1)
        return
    end
end
