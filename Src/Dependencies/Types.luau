local Types = {}

export type Animators = Animator | Humanoid

export type RootMotionImpl = {
	__index: RootMotionImpl,
	new: (Animator: Types.Animators, Model: Model, SelfUpdate: boolean) -> RootMotion,
	LoadAnimation: (self: RootMotion, Animation) -> Track,
	Update: (self: RootMotion) -> (),
	Destroy: (self: RootMotion) -> (),
	Storage: {RootMotion}
}

export type RootMotion = typeof(setmetatable({} :: { 
	IsPlaying:boolean,
	Animating:boolean,
	Animator1: Animator | Humanoid,
	Animator2: Animator | Humanoid,
	RootModel: any,
	AttachmentHolder: Instance,
	AlignPosition: AlignPosition,
	AlignOrientation: AlignOrientation,
	Guide: Attachment,
	StoredStartPos: CFrame,
	Root: any,
	Model: Model,
	Tracks: {Track},
	PlayingTracks: {Track},
	Stopper: AnimationTrack,
	SelfUpdate: boolean,
	Gravity: boolean,
	AllowMovement: boolean
}, {} :: RootMotionImpl))


export type TrackImpl = {
	__index: TrackImpl,
	new: (Animation: Animation, Animator1: Types.Animators , Animator2: Types.Animators , RootData: any) -> Track,
	Play: (self: Track, fadeTime : number,weight : number,speed : number) -> (),
	Stop: (self: Track, fadeTime: number) -> (),
	GetMarkerReachedSignal: (self: Track, MarkerName: string, UseSecondTrack: boolean) -> (RBXScriptSignal),
	AdjustSpeed: (self: Track, speed : number) -> (),
	AdjustWeight: (self: Track,weight : number,fadeTime : number) -> (),
	GetTimeOfKeyframe: (self: Track, keyframeName : string, UseSecondTrack: boolean) -> (number),
	Destroy: (self: Track) -> ()
}

export type Track = typeof(setmetatable({} :: { 
	IsPlaying:boolean,
	Animation:Animation,
	Animator1: Animator | Humanoid,
	Animator2: Animator | Humanoid,
	Track1: AnimationTrack,
	Track2: AnimationTrack,
	Length: number,
	Looped: boolean,
	Priority: Enum.AnimationPriority,
	Speed: number,
	TimePosition: number,
	WeightCurrent: number,
	RootData: RootMotion,
	WeightTarget: number,
	DidLoop: RBXScriptSignal?,
	Ended: RBXScriptSignal?,
	KeyframeReached: RBXScriptSignal?,
	Stopped: RBXScriptSignal?
}, {} :: TrackImpl))

return Types 
