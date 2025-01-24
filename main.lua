---@diagnostic disable: duplicate-set-field

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	---@type event_system
	EVENT = require("event")

	EVENT:newBuffer("player")
	EVENT:newBuffer("player2")
	EVENT:newBuffer("ball")

	PLAYER_BUFFER = EVENT:getBuffer("player")
	PLAYER2_BUFFER = EVENT:getBuffer("player2")
	BALL_BUFFER = EVENT:getBuffer("ball")

	PLAYER = {
		x = 10,
		y = 10,
		w = 30,
		h = 80,
		speed = 350,
		color = { 0.25, 0.25, 0.75 },
		buffer_locked = false,
		score = 0,
	}
	PLAYER.collider = {
		x1 = PLAYER.x,
		y1 = PLAYER.y,
		x2 = PLAYER.x + PLAYER.w,
		y2 = PLAYER.y + PLAYER.h,
		w = PLAYER.w,
		h = PLAYER.h,
	}
	PLAYER_BUFFER:newEventType("move_up", function()
		PLAYER.y = PLAYER.y - PLAYER.speed * love.timer.getDelta()
	end)
	PLAYER_BUFFER:newEventType("move_down", function()
		PLAYER.y = PLAYER.y + PLAYER.speed * love.timer.getDelta()
	end)

	PLAYER2 = {
		x = love.graphics.getWidth() - 40, --40: 10 - PLAYER2.w
		y = 10,
		w = 30,
		h = 80,
		speed = 350,
		color = { 0.75, 0.25, 0.25 },
		direction = -1,
		score = 0,
	}
	PLAYER2.collider = {
		x1 = PLAYER2.x,
		y1 = PLAYER2.y,
		x2 = PLAYER2.x + PLAYER2.w,
		y2 = PLAYER2.y + PLAYER2.h,
		w = PLAYER2.w,
		h = PLAYER2.h,
	}

	BALL = {
		x = 200,
		y = 200,
		r = 10,
		speed = 200,
		color = { 0.6, 0.6, 0.6 },
		x_dir = 1,
		y_dir = 1,
	}

	SHOW_DEBUG = false
end

function love.update(dt)
	BALL.collider = {
		x1 = BALL.x - BALL.r,
		y1 = BALL.y - BALL.r,
		x2 = BALL.x + BALL.r * 2,
		y2 = BALL.y + BALL.r * 2,
		w = BALL.r * 2,
		h = BALL.r * 2,
	}
	PLAYER.collider.y1 = PLAYER.y
	PLAYER.collider.y2 = PLAYER.y + PLAYER.h
	PLAYER2.collider.y1 = PLAYER2.y
	PLAYER2.collider.y2 = PLAYER2.y + PLAYER.h

	PLAYER2.direction = GetRequiredYDirection(PLAYER2, BALL)
	PLAYER2.y = PLAYER2.y + (PLAYER2.speed * PLAYER2.direction) * love.timer.getDelta()

	if love.keyboard.isDown("w") then
		PLAYER_BUFFER:addEvent("move_up")
	elseif love.keyboard.isDown("s") then
		PLAYER_BUFFER:addEvent("move_down")
	end

	if PLAYER.y < 10 then
		PLAYER.y = 10
	elseif (PLAYER.y + PLAYER.h) > love.graphics.getHeight() - 10 then
		PLAYER.y = love.graphics.getHeight() - (10 + PLAYER.h)
	end

	if PLAYER2.y < 10 then
		PLAYER2.y = 10
	elseif (PLAYER2.y + PLAYER2.h) > love.graphics.getHeight() - 10 then
		PLAYER2.y = love.graphics.getHeight() - (10 + PLAYER2.h)
	end

	if #PLAYER_BUFFER.buffer > 0 and not PLAYER.buffer_locked then
		PLAYER_BUFFER:popEvent()
	end

	BALL.x = BALL.x - (BALL.speed * BALL.x_dir) * dt
	BALL.y = BALL.y - (BALL.speed * BALL.y_dir) * dt

	if BALL.x - (BALL.r * 2) < PLAYER.collider.x2 and BALL.y > PLAYER.collider.y1 and BALL.y < PLAYER.collider.y2 then
		print("Ball collided with player")
		BALL.x_dir = -BALL.x_dir
		if BALL.speed < 450 then
			BALL.speed = BALL.speed + 10
		end
		BALL.y_dir = math.floor(math.random(-1, 1))
	elseif
		BALL.x + (BALL.r * 2) > PLAYER2.collider.x1
		and BALL.y > PLAYER2.collider.y1
		and BALL.y < PLAYER2.collider.y2
	then
		print("Ball coliided with player2")
		BALL.x_dir = -BALL.x_dir
		if BALL.speed < 450 then
			BALL.speed = BALL.speed + 10
		end
		BALL.y_dir = math.floor(math.random(-1, 1))
	end

	if BALL.y + BALL.r > love.graphics.getHeight() then
		BALL.y_dir = -BALL.y_dir
	elseif BALL.y - BALL.r < 0 then
		BALL.y_dir = -BALL.y_dir
	elseif BALL.x < 0 then
		BALL.x = love.graphics.getWidth() / 2
		BALL.y = love.graphics.getHeight() / 2
		PLAYER2.score = PLAYER2.score + 1
	elseif BALL.x > love.graphics.getWidth() then
		BALL.x = love.graphics.getWidth() / 2
		BALL.y = love.graphics.getHeight() / 2
		PLAYER.score = PLAYER.score + 1
	end

	if PLAYER.score > 6 then
		print("player 1 won")
		love.event.quit()
	elseif PLAYER2.score > 6 then
		print("player 2 won")
		love.event.quit()
	end
end

function love.draw()
	SetColor(PLAYER.color)
	love.graphics.rectangle("fill", PLAYER.x, PLAYER.y, PLAYER.w, PLAYER.h)
	SetColor({ 1, 1, 1 })
	love.graphics.print(tostring(PLAYER.score), 300, 50, 0, 2, 2)
	if SHOW_DEBUG then
		SetColor({ 0, 1, 0 })
		local collider = PLAYER.collider
		love.graphics.rectangle("line", collider.x1, collider.y1, collider.w, collider.h)
	end

	SetColor(PLAYER2.color)
	love.graphics.rectangle("fill", PLAYER2.x, PLAYER2.y, PLAYER2.w, PLAYER2.h)
	SetColor({ 1, 1, 1 })
	love.graphics.print(tostring(PLAYER2.score), love.graphics.getWidth() - 300, 50, 0, 2, 2)
	if SHOW_DEBUG then
		SetColor({ 0, 1, 0 })
		local collider = PLAYER2.collider
		love.graphics.rectangle("line", collider.x1, collider.y1, collider.w, collider.h)
	end

	SetColor(BALL.color)
	love.graphics.circle("fill", BALL.x, BALL.y, BALL.r)
	if SHOW_DEBUG then
		SetColor({ 0, 1, 0 })
		local collider = BALL.collider
		love.graphics.rectangle("line", collider.x1, collider.y1, collider.w, collider.h)

		love.graphics.print("Speed: " .. BALL.speed, BALL.x + (BALL.r * 3), BALL.y)
	end

	SetColor({ 1, 1, 1 })
	local screen_center = love.graphics.getWidth() / 2
	love.graphics.line(screen_center, 0, screen_center, love.graphics.getHeight())
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit(0)
	elseif key == "return" then
		love.event.quit("restart")
	elseif key == "f1" then
		if not PLAYER.buffer_locked then
			PLAYER.color = { 0.6, 0.6, 0.6 }
		else
			PLAYER.color = { 0.25, 0.25, 0.75 }
		end

		PLAYER.buffer_locked = not PLAYER.buffer_locked
	elseif key == "f2" then
		SHOW_DEBUG = not SHOW_DEBUG
	elseif key == "r" then
		BALL.x = love.graphics.getWidth() / 2
		BALL.y = love.graphics.getHeight() / 2
	end
end

function UnpackColor(color)
	if #color == 3 then
		return color[1], color[2], color[3]
	else
		return color[1], color[2], color[3], color[4]
	end
end

function SetColor(color)
	love.graphics.setColor(UnpackColor(color))
end

function GetRequiredYDirection(a, b)
	local center = a.y + (a.h / 2)

	if b.y > center then
		return 1
	elseif b.y < center then
		return -1
	else
		return 0
	end
end
