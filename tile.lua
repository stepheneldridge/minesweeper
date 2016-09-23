tile = class:new()
color = {}
color[-1] = {200,200,200}
color[0] = {100,100,100}
color[1] = {0,0,255}
color[2] = {100,200,255}
color[3] = {0,255,0}
color[4] = {255,255,0}
color[5] = {255,150,40}
color[6] = {255,0,0}
color[7] = {255,50,150}
color[8] = {180,0,255}
color[9] = {180,0,255}
color[10] = {180,0,255}
color[11] = {180,0,255}
color[12] = {180,0,255}
color[13] = {0,0,0}
border = 0
function tile:init( x, y , size, up)--centroid, side length, orientation
	self.x = x
	self.y = y
	self.size = size
	self.covered = true
	self.value = 0
	self.flagged = false
	self.up = up
	self.vertices = self:getVertices(up)
	self:scaleAndShift(size,(x+1)*math.sqrt(1/3)*size,(y+0.5)*size)--+1,+0.5
	
end
function tile:scaleAndShift(scalar, sx, sy)
	for i = 1, #self.vertices do
		self.vertices[i] = self.vertices[i]*scalar+(i%2==1 and sx or sy)
	end
end
function tile:getVertices(up)
	local x = math.sqrt(1/3)
	if up then 
		return {0,-0.5,x,0.5,-x, 0.5}
	else
		return {0,0.5,x,-0.5,-x, -0.5}
	end
end
function tile:uncover()
	self.covered=false
end

function tile:isCovered()
	return self.covered
end

function tile:isMine()
	return self.value >= 13
end

function tile:setValue(i)
	self.value = i;
end

function tile:getValue()
	return self.value
end

function tile:increment()
	self.value = self.value+1
end

function tile:reset()
	self.value = 0
	self.covered = true
	self.flagged = false
end

function tile:toggleFlag()
	self.flagged = not self.flagged
	return self.flagged
end

function tile:isFlagged()
	return self.flagged
end

function tile:isUp()
	return self.up
end

function tile:draw()
	love.graphics.setColor(50,50,50)
	love.graphics.polygon("line", self.vertices)
	love.graphics.setColor(self:getColor())
	love.graphics.polygon("fill", self.vertices)
	if self.value > 0 and not self:isCovered() then
		love.graphics.setColor(0,0,0)
		love.graphics.printf(self.value,(self.x+1)*math.sqrt(1/3)*self.size,(self.y+0.5)*self.size-6+(self.up and self.size/6 or -self.size/6),0,"center")
	end
	if self:isFlagged() then
		love.graphics.setColor(255,0,0)
		love.graphics.circle("line",(self.x+1)*math.sqrt(1/3)*self.size,(self.y+0.5)*self.size+(self.up and self.size/6 or -self.size/6),self.size/6,6)
	end
end

function tile:getColor()
	if self.covered then
		return color[-1]
	else
		return color[self.value]
	end
end