function love.load()
	screen = "load" --load, game, gameover
	gamestate = "load" --load, playing, lose, win
	height,width = 800,900
	tileSize = 60
	relh = (height-200)/tileSize
	relw = math.floor((width-2/math.sqrt(3))/(tileSize/math.sqrt(3)))
	love.window.setMode(width,height)
	love.window.setTitle("Minesweeper")
	board = {}
	minelist = {}
	mines = math.ceil(relh*relw*.14)--14%
	flags = mines
	uncoveredCount = 0
	coins = 0
	price = 200
	active = 'l'
	flag = 'r'
	require "class"
	require "tile"
	font = love.graphics.newFont(18)
	endfont = love.graphics.newFont(50)
	tilefont = love.graphics.newFont(12)--12
	ratio = math.sqrt(3)
	init()
end

function init()
	math.randomseed(os.time())
	for i = 0, relw-1 do
		row = {}
		for j = 0, relh-1 do
			row[j] = tile:new(i,j,tileSize,(i+j)%2==0 and true or false)
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
		if board[tryx][tryy]:getValue()~=13 and board[tryx][tryy]:isCovered() then
			setMine(tryx,tryy)
			minelist[left] = board[tryx][tryy]--{tryx,tryy}
			left = left - 1
		end
	end
end

function reset()
	minelist = {}
	uncoveredCount = 0
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
--bottom
adj[1] = {-2,1}
adj[2] = {-1,1}
adj[3] = {0,1}
adj[4] = {1,1}
adj[5] = {2,1}
--side
adj[6] = {-1,0}
adj[7] = {-2,0}
adj[8] = {1,0}
adj[9] = {2,0}
--top
adj[10] = {-1,-1}
adj[11] = {0,-1}
adj[12] = {1,-1}
function setMine(x,y)
	board[x][y]:setValue(13)
	local swap = board[x][y]:isUp() and 1 or -1
	for a = 1, 12 do
		tx = x+adj[a][1]
		ty = y+adj[a][2]*swap
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
	local swap = board[x][y]:isUp() and 1 or -1
	for a = 1, 12 do
		tx = x+adj[a][1]
		ty = y+adj[a][2]*swap
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
	local swap = board[x][y]:isUp() and 1 or -1
	for a = 1, 12 do
		tx = x+adj[a][1]
		ty = y+adj[a][2]*swap
		if tx>=0 and tx < relw and ty>=0 and ty< relh then --is a real tile
			if not board[tx][ty]:isFlagged() then
				board[tx][ty]:uncover()
				uncoveredCount = uncoveredCount + 1
				coins = coins + 1
			end
		end
	end
	placemines(mines)
	for a = 1, 12 do
		tx = x+adj[a][1]
		ty = y+adj[a][2]*swap
		if tx>=0 and tx < relw and ty>=0 and ty< relh then --is a real tile
			if board[tx][ty]:getValue() == 0 and not board[tx][ty]:isFlagged() then
				uncoverAround(tx,ty)
			end
		end
	end
	checkWin()
end

function love.mousepressed( x, y, button, istouch )
	if x>=0 and x<relw*tileSize and y>=0 and y<relh*tileSize then--inside board
		if screen == "gameover" then
			reset()
			return
		end
		local a = math.floor((y-ratio*(x-tileSize/ratio))/(2*tileSize))
		local b = math.floor((y+ratio*(x-tileSize/ratio))/(2*tileSize))
		local x = b-a
		if x<0 or x>=relw then
			return
		end
		local y = math.floor((y)/tileSize)
		if gamestate == "load" and button == active then
				firstClick(x,y)
		end
		local tile = board[x][y]
		if (button == active or (istouch and active == 'l')) and screen == "game" then --click
			if not tile:isFlagged() and tile:isCovered() then
				tile:uncover()
				uncoveredCount = uncoveredCount + 1
				coins = coins + 1--------------------------------------
				if tile:getValue() == 0 then
					uncoverAround(x,y)
				elseif tile:getValue() == 13 then
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
		elseif (button == flag or (istouch and flag == 'r')) and screen == "game"  then --flag mine
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
	else
		toggleLR()
	end
end

function love.keypressed(key)
	if key == "r" then
		reset()
	end
	if key == "s" then
		toggleLR()
	end
end

function toggleLR()
	active,flag=flag,active
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
	love.graphics.printf("Touch: "..(active == 'l' and "Uncover" or "Flag"),20,relh*tileSize+80,200,"left")
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