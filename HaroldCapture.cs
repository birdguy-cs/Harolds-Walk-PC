using Godot;
using System;

public partial class HaroldCapture : Node3D
{
	public override void _Ready()
	{
		Node foundNode = GetTree().Root.FindChild("InfiniteTerrain", true, false);
		Node3D infiniteTerrain = foundNode as Node3D;
		infiniteTerrain.Set("viewer", GameManager.Instance.playermovement);
	}
}
