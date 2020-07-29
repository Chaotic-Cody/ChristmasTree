--[[
    Tree.lua
    Generates a tree via a position, size, leaf, and trunk colors
    Decorates the tree randomly.
    Tree.Position refers to the bottom of the trunk.
    Size.X, Size.Z refers to the size of the base square
    Size.Y refers to the height from the square to the apex
    Trunk height will be determined based on a scale of the tree height
]]

local ServerStorage = game:GetService("ServerStorage")
local TriangleModule = require(ServerStorage:WaitForChild("TriangleModule"))
local Decorations = ServerStorage:WaitForChild("Decorations")
local Adornments = Decorations:WaitForChild("Adornments")

local WIDTH = 0.2
local ADORNMENTS_PER_FACE_LEVEL = 10

Tree = {}
Tree.__index = Tree

function Tree.new(position, size, seed, leafColor, trunkColor)

    local newTree = {}
    setmetatable(newTree, Tree)

    newTree.Position = position
    newTree.Size = size
    newTree.Seed = seed
    newTree.LeafColor = leafColor
    newTree.TrunkColor = trunkColor

    newTree._trunkHeight = size.Y * (2/10)
    newTree._trunkWidth = size.X * (2/10)
    newTree._decorationScale = 0.2 --size.X * (0.2)

    return newTree

end

--[[
    Tree:Draw(double seed, Model parent)
    Draws a physical model of Tree from seed
]]
function Tree:Draw(seed, parent)

    local treeModel = Instance.new("Model")
    treeModel.Name = "Tree"
    treeModel.Parent = parent
    local decorationModel = Instance.new("Model")
    decorationModel.Name = "Decorations"
    decorationModel.Parent = treeModel

    local apex = self.Position + Vector3.new(0, self.Size.Y, 0) + Vector3.new(0, self._trunkHeight, 0)

    local leftDown = self.Position - Vector3.new(self.Size.X, 0, self.Size.Z)/2
    local leftUp = self.Position - Vector3.new(self.Size.X, 0, 0)/2 + Vector3.new(0, 0, self.Size.Z)/2
    local rightUp = self.Position + Vector3.new(self.Size.X, 0, self.Size.Z)/2
    local rightDown = self.Position + Vector3.new(self.Size.X, 0, 0)/2 - Vector3.new(0, 0, self.Size.Z)/2

    local vertexTable = {leftDown, leftUp, rightUp, rightDown}

    -- Adjust vertices by trunkHeight
    for i, vertex in pairs(vertexTable) do
        vertexTable[i] = vertex + Vector3.new(0, self._trunkHeight, 0)
    end

    -- Draw vertices for each triangular face of pyramid
    for i = 2, #vertexTable+1 do
        local v1 = apex
        local v2 = vertexTable[i-1]
        local v3 = vertexTable[i]
        if i > #vertexTable then
            v3 = vertexTable[1]
        end
        local triangleModel = TriangleModule.DrawTriangle(v1, v2, v3, treeModel, WIDTH)
        for j, triangle in ipairs(triangleModel:GetChildren()) do
            triangle.Color = self.LeafColor
        end
    end

    -- Draw in base of pyramid
    local base = Instance.new("Part")
    base.Name = "Base"
    base.Anchored = true
    base.Color = self.LeafColor
    base.TopSurface = Enum.SurfaceType.SmoothNoOutlines
    base.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
    base.Size = Vector3.new(self.Size.X, WIDTH, self.Size.Z)
    base.CFrame = CFrame.new(self.Position) + Vector3.new(0, self._trunkHeight, 0) - Vector3.new(0, WIDTH, 0)/2
    base.Parent = treeModel

    -- Draw trunk
    local trunk = Instance.new("Part")
    trunk.Name = "Trunk"
    trunk.Anchored = true
    trunk.Color = self.TrunkColor
    trunk.TopSurface = "SmoothNoOutlines"
    trunk.BottomSurface = "SmoothNoOutlines"
    trunk.Shape = "Cylinder"
    trunk.Size = Vector3.new(self._trunkHeight, self._trunkWidth, self._trunkWidth)
    trunk.CFrame = CFrame.new(self.Position) + Vector3.new(0, self._trunkHeight, 0)/2
    trunk.Orientation = Vector3.new(0, 0, 90)
    trunk.Parent = treeModel

    -- Draw star

    -- Draw decorations
    --[[
        Given:
        Side of base square (a)
        side of slant from v1 to apex (e)

        we can find the new height of the prism
    ]]
    local iteration = 1
    local h = self.Size.Y
    local v1 = vertexTable[iteration]
    local v2 = vertexTable[iteration + 1]

    while h > 1 do

        for i = 0, ADORNMENTS_PER_FACE_LEVEL do

            local bell = Adornments:FindFirstChild("Bell"):Clone()
            bell.Name = "Bell"
            bell.Size = Vector3.new(1, 1, 1) * ((v2 - v1).magnitude / ADORNMENTS_PER_FACE_LEVEL)
            bell.Position = v1 + (v2 - v1).unit * ((i/ADORNMENTS_PER_FACE_LEVEL) * (v2 - v1).magnitude)
            bell.Parent = decorationModel

            if i ~= ADORNMENTS_PER_FACE_LEVEL then

                -- update vertices by pushing them back along the line to the apex
                for j = 1, #vertexTable do
                    local p = apex + ((vertexTable[j] - apex).unit) * ((vertexTable[j] - apex).magnitude - WIDTH)
                    --print("this is p ", p)
                    vertexTable[j] = p
                end

                -- use pythagorean theorem to figure out new height based on the slant and inradius
                local r = (v2 - v1).magnitude / 2
                local midpoint = v1 + (v2 - v1).unit * r
                local slant = (apex - midpoint).magnitude

                h = math.sqrt(slant^2 - r^2)

            end

            v1 = vertexTable[iteration % #vertexTable ~= 0 and iteration % #vertexTable or #vertexTable]
            v2 = vertexTable[(iteration + 1) % #vertexTable ~= 0 and (iteration + 1) % #vertexTable or #vertexTable]

        end
        iteration = iteration + 1

        v1 = vertexTable[iteration % #vertexTable ~= 0 and iteration % #vertexTable or #vertexTable]
        v2 = vertexTable[(iteration + 1) % #vertexTable ~= 0 and (iteration + 1) % #vertexTable or #vertexTable]

    end

    return treeModel

end

return Tree