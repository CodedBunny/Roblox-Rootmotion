--!strict
local Types = require(script.Parent:WaitForChild("Types"))


local Track: Types.TrackImpl = {} :: Types.TrackImpl
Track.__index = Track

--local Meta = {__index = Track}


function Track.new(Animation: Animation, Animator1: Types.Animators , Animator2: Types.Animators , RootData: any) : Types.Track 

	local Track1 = (Animator1 :: Animator):LoadAnimation(Animation)
	local Track2 = (Animator2 :: Animator):LoadAnimation(Animation)

	local self = {
		Animator1 = Animator1,
		Animator2 = Animator2,
		Track1 = Track1,
		Track2 = Track2,
		Animation = Animation,
		IsPlaying = false,
		Length = 0,
		Looped = false,
		Priority = Track1.Priority,
		Speed = Track1.Speed,
		TimePosition = Track1.Speed,
		WeightTarget = Track1.WeightTarget,
		WeightCurrent = Track1.WeightCurrent,
		RootData = RootData,
		DidLoop = Track1.DidLoop,
		Ended = Track1.Ended,
		KeyframeReached = Track1.KeyframeReached,
		Stopped = Track1.Stopped,
	}
	
	Track1.Stopped:Connect(function()
		self.IsPlaying = false
	end)
	
	Track1:GetMarkerReachedSignal("Finish"):Connect(function()
		self.IsPlaying = false
		Track1:Stop()
		Track2:Stop(0)
		
	end)
	

	return setmetatable(self, Track)
end



function Track:Destroy()
	local self: any = self
	pcall(function() --they might be NIL
		self.Track1:Stop()
		self.Track2:Stop()
	end)
	self.Animator1 = nil
	self.Animator2 = nil
	self.RootData = nil
	self.Stopped = nil
	self.Ended = nil
	self.DidLoop = nil
	self.KeyFrameReached = nil
	self = {}
	self = nil
end

function Track:Play(fadeTime : number,weight : number,speed : number)
	self.RootData.StoredStartPos = self.RootData.Root.CFrame
	self.Track1:Play(fadeTime,weight,speed)
	self.Track2:Play(fadeTime,weight,speed)
	self.IsPlaying = true
end


function Track:Stop(fadeTime : number)
	self.Track1:Stop(fadeTime)
	self.Track2:Stop(0)
	self.IsPlaying = false
end

function Track:GetMarkerReachedSignal(MarkerName: string, UseSecondTrack: boolean) : RBXScriptSignal
	if not UseSecondTrack then
		return self.Track1:GetMarkerReachedSignal(MarkerName)
	else 
		return self.Track2:GetMarkerReachedSignal(MarkerName)
	end
	
end

function Track:AdjustSpeed(speed : number)
	self.Track1:AdjustSpeed(speed)
	self.Track2:AdjustSpeed(speed)
end

function Track:AdjustWeight(weight : number,fadeTime : number)
	self.Track1:AdjustWeight(weight,fadeTime)
	self.Track2:AdjustWeight(weight,fadeTime)
end

function Track:GetTimeOfKeyframe(keyframeName : string, UseSecondTrack: boolean) : number
	if not UseSecondTrack then
		return self.Track1:GetTimeOfKeyframe(keyframeName)
	else 
		return self.Track2:GetTimeOfKeyframe(keyframeName)
	end
end


return Track
