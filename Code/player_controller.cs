using System;
using System.Runtime.InteropServices;
using Godot;

public partial class player_controller : CharacterBody2D
{
	[Export] public TileMapLayer Tilemap;

	private Camera2D _camera;
	private AnimatedSprite2D _anim;
	private GpuParticles2D _move_particles;
	private GpuParticles2D _dash_particles;

	private PackedScene _spray_scene;
	private Area2D _attack_area;
	private Area2D _dash_attack_area;

	[Export] public AudioStreamPlayer2D footstepSfx;
	[Export] public AudioStreamPlayer2D dashSfx;
	[Export] public AudioStreamPlayer2D punchSfx;

	[Export] public Sprite2D yoyo;
	[Export] public Line2D yoyo_string;

	private const float MAX_SPEED = 150f;
	private const float TIME_TO_MAX = 0.4f;
	private const float ACCEL = MAX_SPEED / TIME_TO_MAX;
	private const float FRICTION = 600f;
	private const float JUMP_VELOCITY = -400f;

	private const int MAX_JUMPS = 1;
	private int jumps_left = MAX_JUMPS;

	private const float DASH_COOLDOWN = 1f;
	private const float DASH_DURATION = 0.2f;

	private float dash_timer = 0f;
	private bool dashing = false;

	private bool spraying = false;
	private float punching = 0f;

	private float _gravity;
	private bool _breaking = false;

	private bool _yoyo_returning = false;
	private float _yoyo_timer = 0f;
	private float _yoyo_duration = 1.0f;
	private Vector2 last_hit_position;
	private Robot yoyo_enemy;
	private CharacterBody2D yoyo_enemy_body;

	private Vector2 dirRadial;

	public override void _Ready()
	{
		_camera = GetNode<Camera2D>("Camera2D");
		_anim = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
		_move_particles = GetNode<GpuParticles2D>("GPUParticles2D");
		_dash_particles = GetNode<GpuParticles2D>("dash_sfx");

		_attack_area = GetNode<Area2D>("attack_area");
		_dash_attack_area = GetNode<Area2D>("dash_attack_area");

		_attack_area.BodyEntered += OnBodyEntered;
		_dash_attack_area.BodyEntered += OnDashBodyHit;

		_attack_area.Monitoring = false;
		_dash_attack_area.Monitoring = false;

		_spray_scene = ResourceLoader.Load<PackedScene>("res://Scenes/Interactables/spray.tscn");
		_gravity = (float)ProjectSettings.GetSetting("physics/2d/default_gravity");

		SetupCameraLimits();
	}

	public override void _Input(InputEvent e)
	{
		if (e.IsActionPressed("spray"))
		{
			spraying = true;
			_anim.Play("Paint");
			return;
		}

		if (e.IsActionPressed("punch"))
		{
			punching = 0.4f;
			punchSfx.Play();
			_attack_area.Monitoring = true;
		}

		if (e.IsActionPressed("dash") && dash_timer < 0f)
			StartDash();

		if (e.IsActionPressed("yoyo") && yoyo.Visible && IsInstanceValid(yoyo_enemy))
		{
			GD.Print("Yoyo hit!");
			GD.Print(yoyo_enemy);
			Vector2 dir = (yoyo_enemy.Position - Position).Normalized();
			dir += Vector2.Down;
			yoyo_enemy.TakeHit(-dir, -0.1f, 200f);
		}
	}

	public override void _Process(double delta)
	{
		UpdateCooldowns((float)delta);
		UpdateYoyo();
	}

	public override void _PhysicsProcess(double delta)
	{
		float dt = (float)delta;

		if (dash_timer < DASH_COOLDOWN - DASH_DURATION)
			dashing = false;

		if (IsOnFloor())
			jumps_left = MAX_JUMPS;

		ApplyGravity(dt);
		HandleJump();
		HandleMovement(dt);

		UpdateAttackOffset();
		UpdateAnimation();

		MoveAndSlide();
	}

	private void ApplyGravity(float dt)
	{
		if (!IsOnFloor() && !dashing)
			Velocity += Vector2.Down * _gravity * dt;


		if (IsOnWall() && !IsOnFloor() && Velocity.Y >0)
		{
			float damp = dirRadial.Y > 0 ? 1.2f : 0.2f;
			Velocity = Vector2.Down * _gravity * dt * damp;
			jumps_left = MAX_JUMPS;
		}
	}

	private void HandleJump()
	{
		if (!Input.IsActionJustPressed("jump") || jumps_left <= 0 || dashing)
			return;

		Velocity = new Vector2(Velocity.X, JUMP_VELOCITY);
		jumps_left--;

		if (IsOnWallOnly())
			Velocity = (new Vector2(GetWallNormal().X * 400, JUMP_VELOCITY / 2)+Velocity)*0.5f;
	}

	private void HandleMovement(float dt)
	{
		dirRadial = new Vector2(Input.GetAxis("left", "right"), Input.GetAxis("jump", "down"));
		_breaking = Mathf.Sign(dirRadial.X) != Mathf.Sign(Velocity.X) && dirRadial.X != 0;

		if (dirRadial.X != 0)
		{
			float target = dirRadial.X * MAX_SPEED;
			float accel = ACCEL * dt * (1f + (_breaking ? 1f : 0f));

			Velocity = new Vector2(
				Mathf.MoveToward(Velocity.X, target, accel),
				Velocity.Y
			);

			_anim.FlipH = dirRadial.X < 0;

			if (_move_particles.ProcessMaterial is ParticleProcessMaterial mat)
				mat.Direction = new Vector3(Mathf.Sign(-dirRadial.X), -0.3f, 0);
		}
		else
		{
			Velocity = new Vector2(
				Mathf.MoveToward(Velocity.X, 0f, FRICTION * dt),
				Velocity.Y
			);
		}

		if (dirRadial.Y > 0.0)
		{
			SetCollisionMaskValue(2, false);
		}
		else
		{
			SetCollisionMaskValue(2, true);
		}
	}

	private void StartDash()
	{
		dashing = true;
		dash_timer = DASH_COOLDOWN;

		Vector2 dir = new(_anim.FlipH ? -1 : 1, 0);
		Velocity = dir * 400f;

		_dash_particles.Emitting = true;
		_dash_attack_area.Monitoring = true;
		dashSfx.Play();
	}

	private void UpdateCooldowns(float dt)
	{
		if (punching > 0f)
		{
			punching -= dt;
			if (punching <= 0f)
				_attack_area.Monitoring = false;
		}

		if (dash_timer >= 0f)
		{
			dash_timer -= dt;

			if (dash_timer < DASH_COOLDOWN - DASH_DURATION)
			{
				dashing = false;
				var mat = _dash_particles.ProcessMaterial as ShaderMaterial;
				mat.SetShaderParameter("fliph", _anim.FlipH);
				_dash_attack_area.Monitoring = false;
				_dash_particles.Emitting = false;
			}
		}
	}

	private void UpdateAnimation()
	{
		if (spraying)
		{
			if (_anim.Animation != "Paint" || !_anim.IsPlaying())
				spraying = false;
			else
				return;
		}

		float speed = Mathf.Abs(Velocity.X);

		if (dashing)
			_anim.Play("Dash");
		else if (IsOnWall() && !IsOnFloor())
			_anim.Play("Wall");
		else if (!IsOnFloor())
			_anim.Play("Jump");
		else if (punching > 0f)
			_anim.Play("Punch");
		else if (_breaking && speed > 100f)
		{
			_anim.Play("Breaking");
			_move_particles.Emitting = true;
		}
		else if (speed < 5f)
		{
			_anim.Play("Idle");
			_move_particles.Emitting = false;
		}
		else
		{
			_anim.Play("Walk");
			_move_particles.Emitting = false;

			if (!footstepSfx.Playing && new Random().NextDouble() < 0.2)
				footstepSfx.Play();
		}
	}

	private void UpdateYoyo()
	{
		if (!yoyo.Visible)
			return;

		float dt = (float)GetProcessDeltaTime();

		if (!_yoyo_returning)
		{
			_yoyo_timer -= dt;

			// Stay attached to enemy
			if (IsInstanceValid(yoyo_enemy_body))
			{
				Vector2 hit = yoyo_enemy_body.GlobalPosition;
				hit.Y -= 16;
				yoyo.GlobalPosition = hit;
			}

			if (_yoyo_timer <= 0f)
				_yoyo_returning = true;
		}
		else
		{
			// Return to player
			Vector2 target = GlobalPosition;
			target.Y -= 10;

			yoyo.GlobalPosition = yoyo.GlobalPosition.MoveToward(target, 300f * dt);

			if (yoyo.GlobalPosition.DistanceTo(target) < 5f)
			{
				yoyo.Visible = false;
				_yoyo_returning = false;
				yoyo_enemy = null;
				yoyo_enemy_body = null;
			}
		}

		// Update string
		Vector2 player_local = yoyo_string.ToLocal(GlobalPosition);
		player_local.Y -= 10;

		Vector2 yoyo_local = yoyo_string.ToLocal(yoyo.GlobalPosition);

		yoyo_string.SetPointPosition(0, player_local);
		yoyo_string.SetPointPosition(1, yoyo_local);
	}


	private void UpdateAttackOffset()
	{
		Vector2 offset = _attack_area.Position;
		offset.X = _anim.FlipH ? -Mathf.Abs(offset.X) : Mathf.Abs(offset.X);
		_attack_area.Position = offset;
	}

	private void OnBodyEntered(Node body)
	{
		if (body.GetParent() is not Robot enemy || !enemy.IsInGroup("Enemy"))
			return;

		Vector2 dir = (enemy.GlobalPosition - GlobalPosition).Normalized();
		enemy.TakeHit(dir, punching, 100f);
	}

	private void OnDashBodyHit(Node body)
	{
		if (body.GetParent() is not Robot enemy || !enemy.IsInGroup("Enemy"))
			return;

		Vector2 hit = (body as Node2D).GlobalPosition;
		hit.Y -= 16;

		last_hit_position = hit;
		yoyo_enemy = enemy;
		yoyo_enemy_body = body as CharacterBody2D;
		yoyo.Visible = true;

		_yoyo_timer = _yoyo_duration;
		_yoyo_returning = false;

		enemy.TakeDash(dash_timer, 400f);
	}

	private void SetupCameraLimits()
	{
		if (Tilemap == null)
			return;

		Rect2I rect = Tilemap.GetUsedRect();
		Vector2I size = Tilemap.TileSet.TileSize;

		_camera.LimitLeft = rect.Position.X * size.X + size.X;
		_camera.LimitRight = (rect.Position.X + rect.Size.X) * size.X;
		_camera.LimitBottom = (rect.Position.Y + rect.Size.Y) * size.Y;
	}
}
