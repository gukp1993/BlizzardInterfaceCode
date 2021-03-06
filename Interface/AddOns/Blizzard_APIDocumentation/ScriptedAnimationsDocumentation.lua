local ScriptedAnimations =
{
	Name = "ScriptedAnimations",
	Type = "System",
	Namespace = "C_ScriptedAnimations",

	Functions =
	{
		{
			Name = "GetAllScriptedAnimationEffects",
			Type = "Function",

			Returns =
			{
				{ Name = "scriptedAnimationEffects", Type = "table", InnerType = "ScriptedAnimationEffect", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ScriptedAnimationBehavior",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "ScriptedAnimationBehavior", EnumValue = 0 },
				{ Name = "TargetShake", Type = "ScriptedAnimationBehavior", EnumValue = 1 },
				{ Name = "TargetKnockBack", Type = "ScriptedAnimationBehavior", EnumValue = 2 },
				{ Name = "SourceRecoil", Type = "ScriptedAnimationBehavior", EnumValue = 3 },
				{ Name = "SourceCollideWithTarget", Type = "ScriptedAnimationBehavior", EnumValue = 4 },
			},
		},
		{
			Name = "ScriptedAnimationTrajectory",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "AtSource", Type = "ScriptedAnimationTrajectory", EnumValue = 0 },
				{ Name = "AtTarget", Type = "ScriptedAnimationTrajectory", EnumValue = 1 },
				{ Name = "Straight", Type = "ScriptedAnimationTrajectory", EnumValue = 2 },
				{ Name = "CurveLeft", Type = "ScriptedAnimationTrajectory", EnumValue = 3 },
				{ Name = "CurveRight", Type = "ScriptedAnimationTrajectory", EnumValue = 4 },
				{ Name = "CurveRandom", Type = "ScriptedAnimationTrajectory", EnumValue = 5 },
			},
		},
		{
			Name = "ScriptedAnimationEffect",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "visual", Type = "number", Nilable = false },
				{ Name = "visualScale", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "trajectory", Type = "ScriptedAnimationTrajectory", Nilable = false },
				{ Name = "startBehavior", Type = "ScriptedAnimationBehavior", Nilable = true },
				{ Name = "startSoundKitID", Type = "number", Nilable = true },
				{ Name = "finishEffectID", Type = "number", Nilable = true },
				{ Name = "finishBehavior", Type = "ScriptedAnimationBehavior", Nilable = true },
				{ Name = "finishSoundKitID", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ScriptedAnimations);