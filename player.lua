player = {}

function player:load()
	love.mouse.setVisible(false)
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()

	love.graphics.setBackgroundColor(100, 100, 255)
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	self.assets = {	walk_spr = love.graphics.newImage("assets/player/player-walk_spr.png"),
					with_mask = love.graphics.newImage("assets/player/player-with mask.png"),
					without_mask = love.graphics.newImage("assets/player/player-no mask.png"),
					bullets = love.graphics.newImage("assets/player/player_bullets.png")
					}

	self.width = 64
	self.height = 64
	self.x = (screenWidth - self.width) / 2
	self.y = (screenHeight - self.height) / 2
	self.speed = 10
	self.xvel = 0
	self.yvel = 0
	self.friction = 2
	self.rotation = math.atan2( love.mouse.getX() - self.x, self.y - love.mouse.getY() ) - math.pi / 2
	self.guns = {
				 love.graphics.newImage("assets/player/guns/pistol.png"),
				 love.graphics.newImage("assets/player/guns/uzi.png")
				}
	self.gun_no = 1

	self.current_gun = self.guns[self.gun_no]

	self.gun_table = {
					   {x = 0, y = 0, width = 64, height = 64, 
					   img = love.graphics.newImage("assets/player/guns/pistol_g.png"), 
					   bullets = 15, total = "15", speed = 100},
					   {x = 0, y = 0, width = 64, height = 64, 
					   img = love.graphics.newImage("assets/player/guns/uzi_g.png"),
					   bullets = 20, total = "20", speed = 200}
					 }
	self.current_gun_t = self.gun_table[self.gun_no]

	self.states = { 
					idle = "idle",
					walk = "walk",
					shoot = "shoot",
					death = "death"
				  }

	self.current_state = self.states.idle
	self.walk_xoff = 0
	self.shoot_xoff = 0
	self.crosshair_xoff = 0
	self.fps = 5
	self.anim_timer = 1 / self.fps
	self.bullets = {}
	self.bullet_speed = 350
	self.bullet_timer = 25
	self.walking =  {left = "left",
					 right = "right",
					 up = "up",
					 down = "down"}
	self.current_w = self.walking 

	_walk_spr = self.assets.walk_spr
	_with_mask = self.assets.with_mask
	_without_mask = self.assets.without_mask
	_bullets = self.assets.bullets
	_shoot_spr = self.assets.shoot_spr
	
	self.crosshair_img = love.graphics.newImage("assets/player/crosshair.png")
	self.current_walk = love.graphics.newQuad(self.walk_xoff, 0, 64, 64, _walk_spr:getDimensions())
	self.current_shoot = love.graphics.newQuad(self.shoot_xoff, 0, 64, 64, self.current_gun:getDimensions())
	self.current_crosshair = love.graphics.newQuad(self.shoot_xoff, 0, 100, 50, self.crosshair_img:getDimensions())
	self.gun_sounds = {love.audio.newSource("assets/sounds/pistol.wav"),
					   love.audio.newSource("assets/sounds/uzi_2.wav")}
	self.gun_blank = love.audio.newSource("assets/sounds/blank.wav")
	self.gun_idle = love.graphics.newQuad(0, 0, 59, 64, self.current_gun:getDimensions())
	self.death_sprite = love.graphics.newImage("assets/player/player-death_spr.png")
	self.death_xoff = 0
	self.current_death = love.graphics.newQuad(self.death_xoff, 0, 64, 64, self.death_sprite:getDimensions())
	self.current_sound = self.gun_sounds[self.gun_no]
end

function player:update(dt)
	player:movement(dt)
	player:wall_collide()
	player:gun_u()
	player:death_u()
	-- player:p_camera()
-- Animations
	player:walk_animations(dt)	
	player:shoot_animations(dt)
	player:death_animations(dt)
-- Player bullets
	player:bullet_u(dt)
	player:bullet_add(dt)
	player:bullet_dissp(dt)
	player:b_collide(dt)
	player:crosshair(dt)
end

function player:draw()
-- legs
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(_walk_spr, self.current_walk, self.x + 32, self.y + 32, self.rotation, 1, 1, 32, 32)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.rotation, 1, 1, 32, 32)
-- torso
	if self.current_state == self.states.walk or self.current_state == self.states.idle then
		love.graphics.draw(self.current_gun, self.gun_idle, self.x + 32, self.y + 32, self.rotation, 1, 1, 32, 32)
	end
	player:gun_d()
	player:death_d()
-- bullet
	player:bullet_d()

	love.graphics.print("current_state : "..self.current_state, 200, 0)
end

function player:movement(dt)
	self.xvel = self.xvel * (1 - math.min(dt * self.friction, 1))	
	self.yvel = self.yvel * (1 - math.min(dt * self.friction, 1))

	if self.current_state ~= self.states.death then
		if love.keyboard.isDown("a", "left") and self.xvel > -100 then
			self.xvel = self.xvel - self.speed * dt
			self.current_state = self.states.walk
			self.current_w = self.walking.left
		end
		
		if love.keyboard.isDown("d", "right") and self.xvel < 100 then
			self.xvel = self.xvel + self.speed * dt
			self.current_state = self.states.walk 
			self.current_w = self.walking.right
		end

		if love.keyboard.isDown("w", "up") and self.yvel > -100 then
			self.yvel = self.yvel - self.speed * dt
			self.current_state = self.states.walk
			self.current_w = self.walking.up
		end
		
		if love.keyboard.isDown("s", "down") and self.yvel < 100 then
			self.yvel = self.yvel + self.speed * dt
			self.current_state = self.states.walk
			self.current_w = self.walking.down
		end
		self.rotation = math.atan2( love.mouse.getX() - self.x, self.y - love.mouse.getY() ) - math.pi / 2
	end

	self.x = self.x + self.xvel
	self.y = self.y + self.yvel
end

function player:walk_animations(dt)
	self.anim_timer = self.anim_timer - dt

	if self.current_state == self.states.walk then
		if self.anim_timer <= 0 then
			self.anim_timer = 1 / (self.fps + 2)
			self.walk_xoff = self.walk_xoff + 64
		
			if self.walk_xoff >= 320 then
				self.walk_xoff = 0
			end
		
			self.current_walk = love.graphics.newQuad(self.walk_xoff, 0, 64, 64, 
													_walk_spr:getDimensions())
		end 
	end
end

function player:shoot_animations(dt)
	self.anim_timer = self.anim_timer - dt

	if self.current_state == self.states.shoot then
		if self.anim_timer <= 0 then
			self.anim_timer = 1 / self.fps
			self.shoot_xoff = self.shoot_xoff + 64
		
			if self.shoot_xoff >= self.current_gun:getWidth() then
				self.shoot_xoff = 0
			end
		
			self.current_shoot = love.graphics.newQuad(self.shoot_xoff, 0, 64, 64, 
													self.current_gun:getDimensions())
		end 
	end
end

function player:death_animations(dt)
	self.anim_timer = self.anim_timer - dt

	if self.current_state == self.states.death then
		if self.anim_timer <= 0 then
			self.anim_timer = 1 / self.fps
			self.death_xoff = self.death_xoff + 64
		
			if self.death_xoff >= self.death_sprite:getWidth() then
				self.death_xoff = self.death_sprite:getWidth() - 64
			end
		
			self.current_death = love.graphics.newQuad(self.death_xoff, 0, 64, 64, 
													self.death_sprite:getDimensions())
		end 
	end
end

function player:bullet_add(dt)
	self.bullet_timer = self.bullet_timer - self.current_gun_t.speed * dt
	
	if self.current_state ~= self.states.death then
		if love.mouse.isDown("l") and 
			self.bullet_timer <= 0 and self.current_gun_t.bullets > 0 then

			self.current_gun_t.bullets = self.current_gun_t.bullets - 1
			self.current_state = self.states.shoot
			self.bullet_timer = 25

			love.audio.play(self.current_sound)

			local startX = self.x + self.width / 2
			local startY = self.y + self.height / 2 
			local mouseX = love.mouse.getX()
			local mouseY = love.mouse.getY()

			local angle = math.atan2(mouseY - startY, mouseX - startX)

			local bulletDx = self.bullet_speed * math.cos(angle)
			local bulletDy = self.bullet_speed * math.sin(angle)

			table.insert(self.bullets, {x = startX - 15, y = startY - 25, dx = bulletDx, dy = bulletDy,
								    timer = 100, br_timer = 0, width = 5, height = 5})
			table.insert(self.bullets, {x = startX + 30, y = startY, dx = bulletDx, dy = bulletDy,
								    timer = 100, br_timer = 0, width = 5, height = 5})
		end
	end

	if love.mouse.isDown("l") and self.current_state ~= self.states.death then 
		if self.current_gun_t.bullets <= 0 then 
			love.audio.play(self.gun_blank)
		end 
	end
end

function player:bullet_u(dt)
	for i, b in pairs(self.bullets) do 
		b.x = b.x + (b.dx * dt)
		b.y = b.y + (b.dy * dt)
	end
end

function player:bullet_d()
	love.graphics.setColor(255, 255, 255)
	for i, b in pairs(self.bullets) do 
		love.graphics.rectangle("fill", b.x, b.y, 5, 5, self.rotation)
		love.graphics.draw(_bullets, b.x, b.y, self.rotation)
	end
end

function player:bullet_dissp(dt)
	for i, b in pairs(self.bullets) do 
		b.timer = b.timer - 100 * dt

		if b.timer <= 0 then 
			b.br_timer = b.br_timer + 1
		end

		if b.br_timer >= 15 then 
			b.br_timer = 0
			table.remove(self.bullets, i)
		end
	end
end

function player:state_manager_release(key)
	local function anim_reset()
		if self.current_state ~= self.states.death then
			self.walk_xoff = 0
			self.current_state = self.states.idle
		end
	end

	if self.current_state ~= self.states.death then
		if key == "a" then 
			anim_reset()
		end

		if key == "s" then 
			anim_reset()
		end

		if key == "d" then 
			anim_reset()
		end

		if key == "w" then 
			anim_reset()
		end
	end
end

function player:b_collide(dt)
	for i1, b in pairs(self.bullets) do 
		for i2, e in pairs(enemy.enemies) do
			if CheckCollisions(b, e) then
				e.current_state = e.states.death
				enemy:drop_weapon_u(dt)
			end
		end
	end
end

function player:crosshair(dt)
	self.anim_timer = self.anim_timer - dt
		if self.anim_timer <= 0 then
			self.anim_timer = 1 / (self.fps - 2)
			self.crosshair_xoff = self.crosshair_xoff + 50
		
		if self.crosshair_xoff >= self.crosshair_img:getWidth() then
			self.crosshair_xoff = 0
		end
		
		self.current_crosshair = love.graphics.newQuad(self.crosshair_xoff, 0, 50, 50, 
													   self.crosshair_img:getDimensions())
	end 
end

function player:p_camera()
	if self.x > screenWidth / 2 then 
		camera.x = self.x - screenWidth / 2
	end

	if self.y > screenHeight / 2 then 
		camera.y = self.y - screenHeight / 2
	end
end

function player:wall_collide()
	for i, wall in pairs(levels.lvls) do 
		if CheckCollisions(self, wall) then 
         	if self.current_w == self.walking.left then 
				self.x = wall.x + wall.width
				self.yvel = 0
				self.xvel = 0
			end
			if self.current_w == self.walking.right then 
				self.x = wall.x - self.width
				self.yvel = 0
				self.xvel = 0
			end
			if self.current_w == self.walking.up then 
				self.y = wall.y + wall.height
				self.yvel = 0
				self.xvel = 0
			end
			if self.current_w == self.walking.down then 
				self.y = wall.y - self.height
				self.yvel = 0
				self.xvel = 0
			end
		end
	end
end

function player:gun_u()
	for i, g in pairs(enemy.dropped_weapons) do 
		if CheckCollisions(player, g) then 
			self.gun_no = g.index
			table.remove(enemy.dropped_weapons, i)
			self.current_gun = self.guns[self.gun_no]
			self.current_gun_t.bullets = g.bullets
			self.current_gun_t.total = g.total
			self.current_sound = self.gun_sounds[self.gun_no]
		end
	end
end

function player:gun_d()
	if self.current_state == self.states.shoot then
		love.graphics.draw(self.current_gun, self.current_shoot, self.x + 32, self.y + 32 , self.rotation, 1, 1, 32, 32) 
	end

	love.graphics.draw(self.crosshair_img, self.current_crosshair, 
											love.mouse.getX(), love.mouse.getY())

	love.graphics.print(self.current_gun_t.total.."/"..self.current_gun_t.bullets, 600, 400)
	
	love.graphics.print(self.gun_no, 0, 0)
end

function player:death_u()
	for i1, e in pairs(enemy.enemies) do 
		for i2, b in pairs(e.bullets) do 
			if CheckCollisions(b, player) then 
				self.current_state = self.states.death
			end
		end
	end
end

function player:death_d()
	love.graphics.setColor(255, 255, 255)
	if self.current_state == self.states.death then
		love.graphics.draw(self.death_sprite, self.current_death, self.x + 32, self.y + 32, self.rotation, 1, 1, 32, 32)
	end
end

function player:game_reset(key)
	if key == "r" and self.current_state == self.states.death then 
		self.current_state = self.states.idle
		self.gun_no = 1
		self.xvel = 0
		self.yvel = 0
		self.death_xoff = 0
		self.current_gun_t.bullets = tonumber(self.current_gun_t.total) 
		levels:player_offset()
	end
end