using System;
using Godot;

public partial class player_controller : CharacterBody2D
{
	[Export] public TileMapLayer Tilemap;

	private Camera2D _camera;
	private AnimatedSprite2D _animationPlayer;
	private GpuParticles2D _particle;
	private GpuParticles2D _dash_particle;
	private PackedScene _spray;
	private Area2D _attack_area;
	private Area2D _dash_attack_area;

	//sound effects
	[Export] public AudioStreamPlayer2D footstepSfx;
	[Export] public AudioStreamPlayer2D dashSfx;
	[Export] public AudioStreamPlayer2D punchSfx;

	private const float WALK_SPEED = 60.0f;
	private const float MAX_SPEED = 120.0f;
	private const float TIME_TO_MAX_SPEED = 0.4f;
	private const float FRICTION = 600.0f;
	private const float JUMP_VELOCITY = -300.0f;

	private const float ACCELERATION = MAX_SPEED / TIME_TO_MAX_SPEED;
	private const float DASH_COOLDOWN = 1.0f;
	private const float dashDuration = 0.2f;
	private bool dashing = false;
	private float dashCooldownTimer = 0.0f;

	private bool spraying = false;
	private float punching = 0.0f;

	private float _gravity;
	private bool _breaking = false;

	public override void _Ready()
	{
		_camera = GetNode<Camera2D>("Camera2D");
		_animationPlayer = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
		_particle = GetNode<GpuParticles2D>("GPUParticles2D");

		//dash particle setup
		_dash_particle = GetNode<GpuParticles2D>("dash_sfx");
		_dash_attack_area = GetNode<Area2D>("dash_attack_area");
		_dash_attack_area.BodyEntered += OnDashBodyHit;
		_dash_attack_area.Monitoring = false;

		_gravity = (float)ProjectSettings.GetSetting("physics/2d/default_gravity");

		_spray = ResourceLoader.Load<PackedScene>("res://Scenes/Interactables/spray.tscn");
		_attack_area = GetNode<Area2D>("attack_area");
		_attack_area.Monitoring = false;
		_attack_area.BodyEntered += OnBodyEntered;

		SetupCameraLimits();
	}


	public override void _Input(InputEvent @event)
	{
		if (@event.IsActionPressed("spray"))
		{
			spraying = true;
			_animationPlayer.Play("Paint");
			return;//spraying this way is currently disabled
			var sprayInstance = _spray.Instantiate() as Node2D;
			//sprayInstance.Material = (Material)sprayInstance.Material.Duplicate();
			sprayInstance.Position = Position + new Vector2(_animationPlayer.FlipH ? -67 : 67, -32);
			GetParent().AddChild(sprayInstance);
		}
		else if (@event.IsActionPressed("punch"))
		{
			punching = 0.4f;
			punchSfx.Play();
			_attack_area.Monitoring = true;
		}
		else if (@event.IsActionPressed("dash") && dashCooldownTimer<0.0f)
		{
			_dash_particle.Emitting = true;
			_dash_attack_area.Monitoring = true;
			dashSfx.Play();
			Vector2 dashDir = new Vector2(_animationPlayer.FlipH ? -1 : 1,0);
			Velocity = dashDir * 300.0f;
			dashCooldownTimer = DASH_COOLDOWN;
			dashing = true;
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		float dt = (float)delta;


		if (dashCooldownTimer < DASH_COOLDOWN - dashDuration)
		{
			dashing = false;
		}

		// Gravity
		if (!IsOnFloor()&&!dashing)
		{
			Velocity += Vector2.Down * _gravity * dt;
		}

		// Jump
		if (Input.IsActionJustPressed("jump") && IsOnFloor()&& !dashing)
		{
			Velocity = new Vector2(Velocity.X, JUMP_VELOCITY);
		}

		// Horizontal movement (momentum-based)
		float direction = Input.GetAxis("left", "right");

		_breaking = Mathf.Sign(direction) != Mathf.Sign(Velocity.X) && direction != 0;

		if (direction != 0)
		{
			if (_particle.ProcessMaterial is ParticleProcessMaterial mat)
			{
				mat.Direction = new Vector3(Mathf.Sign(-direction), -0.3f, 0);
			}

			float targetSpeed = direction * MAX_SPEED;
			Velocity = new Vector2(
				Mathf.MoveToward(
					Velocity.X,
					targetSpeed,
					ACCELERATION * dt * (1.0f + (_breaking ? 1.0f : 0.0f))
				),
				Velocity.Y
			);

			_animationPlayer.FlipH = direction < 0;

		}
		else
		{
			Velocity = new Vector2(
				Mathf.MoveToward(Velocity.X, 0.0f, FRICTION * dt),
				Velocity.Y
			);
		}

		Vector2 attackOffset = _attack_area.Position;
		attackOffset.X = _animationPlayer.FlipH ? -Mathf.Abs(attackOffset.X) : Mathf.Abs(attackOffset.X);
		_attack_area.Position = attackOffset;

		updateCooldowns(dt);
		UpdateAnimation();
		MoveAndSlide();
	}

	private void updateCooldowns(float dt)
	{
		if (punching > 0.0f)
		{
			punching -= dt;
			if (punching <= 0.0f)
			{
				_attack_area.Monitoring = false;
			}
		}
		if (dashCooldownTimer >= 0.0f)
		{
			dashCooldownTimer -= dt;
			if (dashCooldownTimer < DASH_COOLDOWN - dashDuration)
			{
				dashing = false;
				var mat = _dash_particle.ProcessMaterial as ShaderMaterial;
				mat.SetShaderParameter("fliph", _animationPlayer.FlipH);
				_dash_attack_area.Monitoring = false;
				_dash_particle.Emitting = false;
			}
		}
	}

	private void UpdateAnimation()
	{
		if (spraying)
		{
			if (_animationPlayer.Animation != "Paint" || !_animationPlayer.IsPlaying())
			{
				spraying = false;
			}
			else
			{
				return;
			}
		}

		float speed = Mathf.Abs(Velocity.X);

		if (dashing)
		{
			_animationPlayer.Play("Dash");
		}
		else if (!IsOnFloor())
		{
			_animationPlayer.Play("Jump");
		}
		else if (punching > 0.0f)
		{
			_animationPlayer.Play("Punch");
		}
		else if (_breaking && speed > 100.0f)
		{
			_animationPlayer.Play("Breaking");
			_particle.Emitting = true;
		}
		else if (speed < 5.0f)
		{
			_animationPlayer.Play("Idle");
			_particle.Emitting = false;
		}
		else
		{
			_animationPlayer.Play("Walk");
			if (footstepSfx.Playing == false)
			{
				Random random = new Random();
				if (random.NextDouble() < 0.2)
					footstepSfx.Play();
			}
			
			_particle.Emitting = false;
		}

	}

	private void OnBodyEntered(Node body)
	{
		Robot enemy = body.GetParent() as Robot;

		if (enemy == null)
			return;

		if (!enemy.IsInGroup("Enemy"))
			return;

		Vector2 hitDir = (enemy.GlobalPosition-GlobalPosition).Normalized();
		enemy.TakeHit(hitDir,punching, 100.0f);
	}

	private void OnDashBodyHit(Node body)
	{
		Robot enemy = body.GetParent() as Robot;

		if (enemy == null)
			return;

		if (!enemy.IsInGroup("Enemy"))
			return;
		enemy.TakeDash(dashCooldownTimer, 400.0f);
	}

	private void SetupCameraLimits()
	{
		if (Tilemap == null)
			return;

		Rect2I usedRect = Tilemap.GetUsedRect();
		Vector2I tileSize = Tilemap.TileSet.TileSize;

		_camera.LimitLeft = usedRect.Position.X * tileSize.X;
		_camera.LimitRight = (usedRect.Position.X + usedRect.Size.X) * tileSize.X;
		_camera.LimitBottom = (usedRect.Position.Y + usedRect.Size.Y) * tileSize.Y;
	}
}
