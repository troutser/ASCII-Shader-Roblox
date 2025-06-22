local module = {}

local Camera = workspace.CurrentCamera
local NearPlaneZ = Camera.NearPlaneZ
local PlaneHeight = NearPlaneZ * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2
local PlaneWidth = PlaneHeight --* --Camera.ViewportSize.X / Camera.ViewportSize.Y

local ScreenSize = { x = 100, y = 100 }
local RenderDistance = 1000
local RAYCAST_PARAMS = RaycastParams.new()

local transformedPointLookUp = {}

local ASCIICharacterLookUp = {
	" ",
	".",
	"∙",
	"⁚",
	"⁖",
	"⁘",
	"⁙",
	"⁜",
	"♼",
	"☗"
}

local BottomLeftLocal = Vector3.new(-PlaneWidth / 2, -PlaneHeight / 2, NearPlaneZ)


for x = 0, ScreenSize.x - 1 do
	transformedPointLookUp[x] = {}
	local tx = x / (ScreenSize.x - 1)
	for y = 0, ScreenSize.y - 1 do
		local ty = y / (ScreenSize.y - 1)
		local pointLocal = BottomLeftLocal + Vector3.new(PlaneWidth * tx, PlaneHeight * ty)
		transformedPointLookUp[x][y+1] = -(Camera.CFrame.RightVector * pointLocal.X +
			Camera.CFrame.UpVector * pointLocal.Y +
			Camera.CFrame.LookVector * pointLocal.Z)
	end
end
local Black = Color3.new(0,0,0)
return {function(player, TaskIndex: number)
	local start = os.clock()
	local CameraCF = Camera.CFrame

	local Colors = {}

	for x = 1, ScreenSize.x do
		local Direction = transformedPointLookUp[x-1][TaskIndex]
		local Raycast = workspace:Raycast(CameraCF.Position, Direction*RenderDistance, RAYCAST_PARAMS)

		if Raycast then
			local LightDirection = workspace[player].HumanoidRootPart.Position-Raycast.Position
			local Diffuse = LightDirection.Unit:Dot(Raycast.Normal)
			Diffuse = math.clamp(Diffuse,0,1)

			local R = Raycast.Instance.Color.R * Diffuse
			local G = Raycast.Instance.Color.G * Diffuse
			local B = Raycast.Instance.Color.B * Diffuse
			local Luminance = 1+math.round(2.7*R + 5.4*G + 0.9*B)--1+math.round(9*(0.3*R + 0.6*G + 0.1*B))
			local Character = ASCIICharacterLookUp[Luminance]

			Colors[x] = {Character, Luminance}
		else
			Colors[x] = {"X", 1}
		end
	end
	return Colors
end
}
