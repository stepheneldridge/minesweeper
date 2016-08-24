function love.load()
	screen = "load" --load, game, gameover
	gamestate = "load" --load, playing, lose, win
	height,width = 800,900
	tileSize = 20
	relh = height/tileSize-10
	relw = width/tileSize
	love.window.setMode(width,height)
	love.window.setTitle("Minesweeper")
	board = {}
	minelist = {}
	mines = math.ceil(relh*relw*.2)
	flags = mines
	uncoveredCount = 0
	coins = 0
	price = 200
	require "class"
	require "tile"
	font = love.graphics.newFont(18)
	endfont = love.graphics.newFont(50)
	tilefont = love.graphics.newFont(12)
	init()
end

function init()
	math.randomseed(os.time())
	for i = 0, relw-1 do
		row = {}
		for j = 0, relh-1 do
			row[j] = tile:new(i,j,tileSize)
		end
		board[i] = row
	end
end

function placemines(minecount)
	screen = "game"
	local left = minecount
	while left > 0 do
		tryx = math.random(0,relw-1)
		tryy = math.random(0,relh-1)
		if board[tryx][tryy]:getValue()~=9 and board[tryx][tryy]:isCovered() then
			setMine(tryx,tryy)
			minelist[left] = board[tryx][tryy]--{tryx,tryy}
			left = left - 1
		end
	end
end

function reset()
	minelist = {}
	uncoveredCount = 0;
	coins = 0;
	flags = mines
	gamestate = "load"
	screen = "game"
	for i = 0, relw-1 do
		for j = 0, relh-1 do
			board[i][j]:reset()
		end
	end
end

adj = {}
adj[1] = {1,1}
adj[2] = {1,0}
adj[3] = {1,-1}
adj[4] = {0,-1}
adj[5] = {0,1}
adj[6] = {-1,-1}
adj[7] = {-1,0}
adj[8] = {-1,1}
function setMine(x,y)
	board[x][y]:setValue(9)
	for a = 1, 8 do
		tx = x+adj[a][1]
		ty = y+adj[a][2]
		if tx>=0 and tx < relw and ty>=0 and ty< relh then --is a real tile
			if not board[tx][ty]:isMine() then 
				board[tx][ty]:increment()
			end
		end
	end
end

function love.update(dt)
	if gamestate == "playing" then
		--increment timer
	end
end

function uncoverAround(x,y)
	for a = 1, 8 do
		tx = x+adj[a][1]
		ty = y+adj[a][2]
		if tx>=0 and tx < relw and ty>=0 and ty< relh then --is a real tile
			if board[tx][ty]:isCovered() and not board[tx][ty]:isFlagged() then 
				board[tx][ty]:uncover()
				uncoveredCount = uncoveredCount +1
				coins = coins + 1-----------------------------------------------------------------
				if board[tx][ty]:getValue() == 0 then
					uncoverAround(tx,ty)
				end
			end
		end
	end
end

function showBombs()
	for i=1,#minelist do
		minelist[i]:uncover()
	end
end

function checkWin()
	if uncoveredCount >= (relh*relw)-mines then
		screen = "gameover"
		gamestate = "win"
		return
	end
	if #minelist == 0 then
		return
	end
	for i = 1, #minelist do
		if not minelist[i]:isFlagged() then
			return
		end
	end
	screen = "gameover"
	gamestate = "win"
end

function firstClick(x,y)
	gamestate = "playing"
	board[x][y]:uncover()
	uncoveredCount = uncoveredCount + 1
	coins = coins + 1
	for a = 1, 8 do
		tx = x+adj[a][1]
		ty = y+adj[a][2]
		if tx>=0 and tx < relw and ty>=0 and ty< relh then --is a real tile
			board[tx][ty]:uncover()
			uncoveredCount = uncoveredCount + 1
			coins = coins + 1
		end
	end
	placemines(mines)
	for a = 1, 8 do
		tx = x+adj[a][1]
		ty = y+adj[a][2]
		if tx>=0 and tx < relw and ty>=0 and ty< relh then --is a real tile
			if board[tx][ty]:getValue() == 0 then
				uncoverAround(tx,ty)
			end
		end
	end
	checkWin()
end

function love.mousepressed( x, y, button, istouch )
	if x>=0 and x<relw*tileSize and y>=0 and y<relh*tileSize then--inside board
		
		local x = math.floor(x/tileSize)
		local y = math.floor(y/tileSize)
		if gamestate == "load" and button == 'l' then
				firstClick(x,y)
		end
		local tile = board[x][y]
		if (button == 'l' or istouch) and screen == "game" then --click
			
			if not tile:isFlagged() and tile:isCovered() then
				tile:uncover()
				uncoveredCount = uncoveredCount + 1
				coins = coins + 1--------------------------------------
				if tile:getValue() == 0 then
					uncoverAround(x,y)
				elseif tile:getValue() == 9 then
					coins = coins - 1 ----------------
					uncoveredCount = uncoveredCount - 1
					if coins <price then
						showBombs() --end game
						screen = "gameover"
						gamestate = "lose"
					else
						coins = coins - price ----------------------
						tile:toggleFlag()
						flags = flags -1
					end
				end
				checkWin()
			end
		elseif button == 'r' and screen == "game" then --flag mine
			if tile:isCovered() then
				if tile:toggleFlag() then
					flags = flags -1
					if flags<0 then
						tile:toggleFlag()
						flags = flags +1
					end
				else
					flags = flags +1
				end
				checkWin()
			end
		end
	end
end

function love.keypressed(key)
	if key == "r" then
		reset()
		--placemines(mines)
	end
end

function love.draw()
	love.graphics.setFont(tilefont)
	for i = 0, relw-1 do
		column = board[i]
		for j = 0, relh-1 do
			column[j]:draw()
		end
	end
	love.graphics.setFont(font)
	love.graphics.setColor(200,200,200)
	love.graphics.printf("Flags: "..flags,20,relh*tileSize+20,100,"left")
	love.graphics.printf("Coins: "..coins,20,relh*tileSize+50,100,"left")
	local textw = font:getWidth("Press 'r' for new game")
	love.graphics.printf("Press 'r' for new game",width/2-textw/2,relh*tileSize+80,textw,"center")
	if screen=="gameover" then 
		love.graphics.setColor(100,100,100,150)
		love.graphics.rectangle("fill",0,0,relw*tileSize,relh*tileSize)
		love.graphics.setFont(endfont)
		local text = "You ".. gamestate.."!"
		local texth = endfont:getHeight()
		love.graphics.setColor(200,200,200)
		love.graphics.printf(text,width/2,(relh*tileSize)/2-texth,0,"center")
	end
end