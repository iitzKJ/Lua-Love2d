-- Import required modules
local love = require "love"
local enemy = require "Enemy" -- Assuming you have an "Enemy" module
local button = require "Button" -- Assuming you have a "Button" module

math.randomseed(os.time()) -- Randomize the spawn location

-- Game state and player data
local game = {
    difficulty = 1, 

    state = {
        menu = true, 
        paused = false,
        running = false, 
        ended = false, 
    },
    points = 0,
    levels = {15, 30, 60, 120}
}

local fonts = {
    medium = {
        font = love.graphics.newFont(16),
        size = 16,
    },
    large = {
        font = love.graphics.newFont(24),
        size = 24,
    },
    massive = {
        font = love.graphics.newFont(60),
        size = 60,
    },
}


local player = {
    radius = 20,
    x = 30,
    y = 30
}

-- Menu buttons
local buttons = {
    menu_state = {},
    ended_state = {},

}

-- Enemy data
local enemies = {}


local function changeGameState(state)
    game.state["menu"] = state == "menu"
    game.state["paused"] = state == "paused"
    game.state["running"] = state =="running"
    game.state["ended"] = state =="ended"


end

-- Function to start a new game
local function startNewGame()
    changeGameState("running")
    game.points = 0

    enemies = { 
        enemy(1)
    }
end

-- Mouse click event handler
function love.mousepressed(x, y, button, istouch, presses)
    if not game.state["running"] then
        if button == 1 then
            if game.state["menu"] then
                for _, btn in pairs(buttons.menu_state) do
                    btn:checkPressed(x, y, player.radius)
                end
            elseif game.state["ended"] then
                    for _, btn in pairs(buttons.ended_state) do
                        btn:checkPressed(x, y, player.radius)
                    end
            end
        end
    end
end


-- Load function
function love.load()
    love.window.setTitle("Save The Ball")
    love.mouse.setVisible(false)

    -- Create menu buttons
    buttons.menu_state.play_game = button("Play Game", startNewGame, nil, 120, 40)
    buttons.menu_state.settings = button("Settings", nil, nil, 120, 40)
    buttons.menu_state.exit_game = button("Quit", love.event.quit, nil, 120, 40)


    -- Ended state
    buttons.ended_state.replay_game = button("Replay", startNewGame, nil, 100, 50)
    buttons.ended_state.menu = button("Menu", changeGameState, "menu", 100, 50)
    buttons.ended_state.exit_game = button("Quit", love.event.quit, nil, 100, 50)



end

-- Add a variable to keep track of the current level
local currentLevel = 1

-- Update function
function love.update(dt)
    player.x, player.y = love.mouse.getPosition()
    if game.state["running"] then
        for i = 1, #enemies do
            if not enemies[i]:checkTouched(player.x, player.y, player.radius) then
                enemies[i]:move(player.x, player.y)

                -- Check if the points reach the current level threshold
                if math.floor(game.points) == game.levels[currentLevel] then
                    -- Spawn an enemy for the next level
                    currentLevel = currentLevel + 1
                    table.insert(enemies, 1, enemy(game.difficulty * (1 + 1)))
                end
            else
                changeGameState("ended")
            end
        end
        game.points = game.points + dt
    end
end


-- Draw function
function love.draw()
    love.graphics.setFont(fonts.medium.font)
    -- Display FPS
    love.graphics.printf("FPS: " .. love.timer.getFPS(), fonts.medium.font, 10, love.graphics.getHeight() - 30, love.graphics.getWidth())

    if game.state["running"] then 
        love.graphics.printf(math.floor(game.points),fonts.large.font, 0, 10, love.graphics.getWidth(),  "center") -- Displays the points

        -- Draw enemies
        for i = 1, #enemies do
            enemies[i]:draw()
        end

        -- Draw the player's circle
        love.graphics.circle("fill", player.x, player.y, player.radius)
    elseif game.state["menu"] then
        -- Draw menu buttons
        buttons.menu_state.play_game:draw(10, 20, 17, 10)
        buttons.menu_state.settings:draw(10, 70, 17, 10)
        buttons.menu_state.exit_game:draw(10, 120, 17, 10)
    elseif game.state["ended"] then -- ended menu buttons
        love.graphics.setFont(fonts.large.font)

        buttons.ended_state.replay_game:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight()/1.8, 10, 10)
        buttons.ended_state.menu:draw(love.graphics.getWidth() / 2.25,  love.graphics.getHeight()/1.53, 17, 10)
        buttons.ended_state.exit_game:draw(love.graphics.getWidth() / 2.25,  love.graphics.getHeight()/1.33, 22, 10)

        love.graphics.printf(math.floor(game.points), fonts.massive.font, 0, love.graphics.getHeight() / 2 - fonts.massive.size, love.graphics.getWidth(), "center" )
    end

    if not game.state["running"] then 
        -- Draw a smaller circle when not in the running state
        love.graphics.circle("fill", player.x, player.y, player.radius / 2)
    end
end
