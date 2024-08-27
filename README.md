# Roblox-Rootmotion
Simple rootmotion system for roblox written in strictly typed Luau
Should work for most animations, usage is very simple too

```
local Animator = Character:WaitForChild("Humanoid"):WaitForChild("Animator")
local RootMotion = require(Path.To.Rootmotion)
local Motion = RootMotion.new(Animator, Char)

local Animation = Motion:LoadAnimation(script:WaitForChild("Animation"))

Animation:Play()
```
