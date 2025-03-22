local startTime = love.timer.getTime()
local crtShader
local canvas

local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
function love.load()

    wf = require('libraries/windfield')
    world = wf.newWorld(0, 10000)

    camera = require('libraries/camera')
    cam = camera()
    --to import anim8 lib
    anim8 = require('libraries/anim8')

    --to make the filter work properly
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require('libraries/sti')-- to import tileset support
    gamemap = sti('sprites/tileset/tileset.lua')

    crtShader = love.graphics.newShader('shaders/crt.glsl')
    canvas = love.graphics.newCanvas(screenWidth, screenHeight, { type = '2d', readable = true })

    sound = {}
    sound.mainMusic = love.audio.newSource('music/MainMusic.mp3', 'stream')
    sound.walkSFX = love.audio.newSource('music/Walk.mp3', 'static')
    sound.mainMusic:setVolume(0.25)
    sound.mainMusic:setLooping(true)
    sound.mainMusic:play()

    --Player Basic Attributes
    player = {}
    player.x = 300
    player.y = 280
    player.speed = 300
    player.jumpSpeed = -1000
    player.facing = "right"
    player.collision = world:newBSGRectangleCollider(300, 240, 30, 75, 10)
    player.collision:setFixedRotation(true)

    player.spriteSheetRightRun = love.graphics.newImage('sprites/runRight.png') --assigning the spritesheet
    player.gridRunRight = anim8.newGrid(48, 48, player.spriteSheetRightRun:getWidth(), player.spriteSheetRightRun:getHeight()) --assigning the grid using the given spritesheet (size of the sprite and size of the canvas)

    player.spriteSheetRunLeft = love.graphics.newImage('sprites/runLeft.png')
    player.gridRunLeft = anim8.newGrid(48, 48, player.spriteSheetRunLeft:getWidth(), player.spriteSheetRunLeft:getHeight())
    
    player.spriteSheetIdle = love.graphics.newImage('sprites/idle.png')
    player.gridIdle = anim8.newGrid(48, 48, player.spriteSheetIdle:getWidth(), player.spriteSheetIdle:getHeight())

    player.spriteSheetAttack = love.graphics.newImage('sprites/attack.png')
    player.gridAttack = anim8.newGrid(80, 48, player.spriteSheetAttack:getWidth(), player.spriteSheetAttack:getHeight())

    player.animation = {}
    player.animation.runRight = anim8.newAnimation(player.gridRunRight('1-10', 1), 0.075) --setting up animation using the grid and the frames inside the grid with starting index and speed of next frame transition
    player.animation.runLeft = anim8.newAnimation(player.gridRunLeft('1-10', 1), 0.075)
    player.animation.idle = anim8.newAnimation(player.gridIdle('1-10', 1), 0.25)
    player.animation.attack = anim8.newAnimation(player.gridAttack('1-4', 1), 0.1)

    player.spriteSheet = player.spriteSheetIdle
    player.anim = player.animation.idle

    Colliders = {}
    if gamemap.layers['Collisions'] then
        for i, obj in pairs(gamemap.layers['Collisions'].objects) do
            local platform = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            platform:setType('static')
            table.insert(Colliders, collider)
        end
    end


end

function love.update(dt)
    local isMoving = false
    local isAttacking = false

    player.spriteSheet = player.spriteSheetIdle
    player.anim = player.animation.idle

    local velX = 0
    local velY = 0

    sound.walkSFX:setLooping(false)

    if love.keyboard.isDown("d") then
        velX = player.speed
        sound.walkSFX:setLooping(true)
        sound.walkSFX:play()
        player.facing = "right"
        player.spriteSheet = player.spriteSheetRightRun
        player.anim = player.animation.runRight
        isMoving = true
    end
    if love.keyboard.isDown("a") then
        velX = player.speed * -1
        sound.walkSFX:setLooping(true)
        sound.walkSFX:play()
        player.facing = "left"
        player.spriteSheet = player.spriteSheetRunLeft
        player.anim = player.animation.runLeft
        isMoving = true
    end


    player.collision:setLinearVelocity(velX, 0)
    player.anim:update(dt)
    world:update(dt)
    player.x = player.collision:getX()
    player.y = player.collision:getY()

    cam:lookAt(player.x, player.y)

    -- Get screen and tilemap dimensions
    local mapW = gamemap.width * gamemap.tilewidth

    -- Adjust camera bounds dynamically
    local minX = mapW - (screenWidth * 1.52)  -- Leftmost boundary (player should not see outside the map)
    local maxX = mapW - (screenWidth * -0.72)
    
    if cam.x < minX then
        cam.x = minX
    end

    if cam.x > maxX then
        cam.x = maxX
    end

    cam.y = player.y + 150
end

function love.draw()
    love.graphics.setCanvas(canvas)
    cam:attach()
        gamemap:drawLayer(gamemap.layers['BG'])
        gamemap:drawLayer(gamemap.layers['BG1'])
        gamemap:drawLayer(gamemap.layers['BG2'])
        gamemap:drawLayer(gamemap.layers['BG3'])
        gamemap:drawLayer(gamemap.layers['BG4'])
        gamemap:drawLayer(gamemap.layers['Platform'])
        gamemap:drawLayer(gamemap.layers['Trees'])
        gamemap:drawLayer(gamemap.layers['Grass'])
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2, nil, 24, 30)
        --world:draw()
    cam:detach()
    love.graphics.setCanvas()
    crtShader:send('millis', love.timer.getTime() - startTime)
    love.graphics.setShader(crtShader)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()

end
