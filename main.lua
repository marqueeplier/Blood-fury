require 'player'
require 'enemy'
require 'levels'
require 'camera'

function love.load()
	bg = love.graphics.newImage("assets/maps/map_2.png")
	player:load()
	enemy:load()
	levels:load()
end

function love.update(dt)
	player:update(dt)
	enemy:update(dt)
	levels:update(dt)
end

function love.draw()
	-- love.graphics.draw(bg)
	camera:set()
	
	levels:draw()
	player:draw()
	enemy:draw()

	camera:unset()
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	player:game_reset(key)
end

function love.keyreleased(key)
	player:state_manager_release(key)
end

function love.mousereleased(x, y, b, istouch)
	if b == "l" and player.current_state ~= player.states.death then 
		player.current_state = player.states.walk
	end
end	

function CheckCollisions(a, b)
	return a.x < b.x + b.width and
		   b.x < a.x + a.width and
		   a.y < b.y + b.height and
		   b.y < a.y + a.height
end

function CheckCollision(a, b)
  return a.x < b.x + b.width and
         b.x < a.x + a.width and
         a.y < b.y + b.height and
         b.y < a.y + a.height
end