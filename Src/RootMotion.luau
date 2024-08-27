--!strict
--optimize 2

--[[
Project: Root Motion system
Author: DevSersponge
Date: 03/08/2024 (DDMMYYYY)
Description:
	Efficient Strictly type checked root motion system.
]]


local Dependencies = script:WaitForChild("Dependencies")
local Types = require(Dependencies:WaitForChild("Types"))
local Track = require(Dependencies:WaitForChild("Track"))
local Assets = script:WaitForChild("Assets")
local RunService = game:GetService("RunService")

local RootMotionObjects = {}

local RootMotion: Types.RootMotionImpl = {Storage = {}} :: Types.RootMotionImpl
RootMotion.__index = RootMotion

function RootMotion:Destroy()
	local self: any = self

	self.Animator1 = nil
	self.Animator2 = nil
	for _,Track in self.Tracks do
		Track:Destroy()
	end
	self.Tracks = nil
	self.PlayingTracks = nil
	self.Stopper = nil
	if self.RootModel.Parent ~= nil then 
		self.RootModel:Destroy()
	end
	self.RootModel = nil
	table.remove(RootMotion.Storage,table.find(RootMotion.Storage,self))
	self = {}
	self = nil
end

function Check(Model)
	for Number, Controller in RootMotion.Storage do 
		Controller:Destroy() --Prevent duplicates
	end
end


function RootMotion.new(Animator: Types.Animators, Model: Model, SelfUpdate: boolean) : Types.RootMotion
	assert(Animator:IsDescendantOf(workspace), "Animator needs to be descendadnt of workspace")
	assert(Model:FindFirstChild("HumanoidRootPart"), "Model is missing HumanoidRootPart")
	local RootModel = Assets._RM:Clone()
	RootModel.Parent = Animator.Parent
	Check(Model)
	local AttachmentHolder = Assets.AttachmentHolder:Clone()
	AttachmentHolder.Parent = Animator.Parent
	AttachmentHolder.CFrame = CFrame.new()
	local MainAttach = Instance.new("Attachment", Model:FindFirstChild("HumanoidRootPart"))
	AttachmentHolder.AlignPosition.Attachment0 = MainAttach
	AttachmentHolder.AlignOrientation.Attachment0 = MainAttach
	local StopAnimation: Animation = Assets.Stopper

	local self = setmetatable({
		Animator1 = Animator,
		Animator2 = RootModel.Controller.Animator,
		IsPlaying = false,
		Animating = false,
		Gravity = false,
		AllowMovement = false,
		Tracks = {},
		PlayingTracks = {},
		Root = Model:FindFirstChild("HumanoidRootPart"),
		Stopper = (Animator :: Animator):LoadAnimation(StopAnimation),
		RootModel = RootModel,
		Model = Model,
		AttachmentHolder = AttachmentHolder,
		AlignPosition = AttachmentHolder.AlignPosition,
		AlignOrientation = AttachmentHolder.AlignOrientation,
		Guide = AttachmentHolder.Guide,
		StoredStartPos = CFrame.new(),
		SelfUpdate = SelfUpdate or false,
	},RootMotion)
	
	self.Stopper:Play()

	table.insert(RootMotion.Storage, self)
	
	self.Stopper:Stop()

	return self
end


function RootMotion:LoadAnimation(Animation) : Types.Track
	local self: Types.RootMotion = self
	local NewTrack = Track.new(Animation, self.Animator1, self.Animator2, self)

	table.insert(self.Tracks, NewTrack)

	return NewTrack
end


function UpdateController(Controller: Types.RootMotion)
	local Data = Controller
	local PlayingTracks = {}
	local OnePlaying = false

	for _,Track in Controller.Tracks do 
		if Track.IsPlaying then
			table.insert(PlayingTracks, Track)
			OnePlaying = true
		end
	end

	Controller.IsPlaying = OnePlaying

	Controller.PlayingTracks = PlayingTracks

	if Controller.IsPlaying then 
		if Controller.AlignPosition.Enabled == false then
			Controller.Stopper:Play()
			Controller.StoredStartPos = Controller.Root.CFrame
			Controller.Guide.CFrame = Controller.StoredStartPos * Controller.RootModel.Guide.CFrame
			Controller.AlignPosition.Enabled = true
			Controller.AlignOrientation.Enabled = true
		else 
			Controller.Guide.CFrame = Controller.StoredStartPos * Controller.RootModel.Guide.CFrame
		end
	else
		if Controller.AlignPosition.Enabled == true then
			Controller.AlignPosition.Enabled = false
			Controller.AlignOrientation.Enabled = false
			task.wait(0.085)
			Controller.Stopper:Stop()
		end
	end
end

function Update(dt)
	for Number, Controller in RootMotion.Storage do 
		if Controller.SelfUpdate then continue end
		UpdateController(Controller)
	end
end

function RootMotion:Update()
	UpdateController(self)
end

if RunService:IsClient() then
	print "Initialized RootMotion Client"
	RunService.RenderStepped:Connect(Update)
else 
	print "Initialized RootMotion Server"
	RunService.Heartbeat:Connect(Update)
end

debug.setmemorycategory("Root Motion Controller")
return RootMotion

