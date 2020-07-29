local Tree = require(game:GetService("ServerStorage"):WaitForChild("Tree"))

local position = Vector3.new(0, 0, 0)
local size = Vector3.new(25, 50, 25)
local seed = math.random(-10000, 10000)
local leafColor = Color3.fromRGB(25, 63, 0)
local trunkColor = Color3.fromRGB(56, 30, 0)

local parent = Workspace

--[[
    Testing standard tree placement abd drawing
]]
local christmasTree = Tree.new(position, size, seed, leafColor, trunkColor)
christmasTree:Draw(seed, parent)
