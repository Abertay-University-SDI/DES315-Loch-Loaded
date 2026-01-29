using Godot;

public partial class player_controller : CharacterBody2D
{
    [Export] public TileMapLayer Tilemap;

    private Camera2D _camera;
    private AnimatedSprite2D _animationPlayer;
    private GpuParticles2D _particle;
    private PackedScene _spray;


    private const float WALK_SPEED = 60.0f;
    private const float MAX_SPEED = 120.0f;
    private const float TIME_TO_MAX_SPEED = 0.4f;
    private const float FRICTION = 600.0f;
    private const float JUMP_VELOCITY = -300.0f;

    private const float ACCELERATION = MAX_SPEED / TIME_TO_MAX_SPEED;

    private bool spraying = false;
    private float punching = 0.0f;

    private float _gravity;
    private bool _breaking = false;

    public override void _Ready()
    {
        _camera = GetNode<Camera2D>("Camera2D");
        _animationPlayer = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
        _particle = GetNode<GpuParticles2D>("GPUParticles2D");

        _gravity = (float)ProjectSettings.GetSetting("physics/2d/default_gravity");

        _spray = ResourceLoader.Load<PackedScene>("res://Scenes/spray.tscn");

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
        }
    }

    public override void _PhysicsProcess(double delta)
    {
        float dt = (float)delta;

        // Gravity
        if (!IsOnFloor())
        {
            Velocity += Vector2.Down * _gravity * dt;
        }

        // Jump
        if (Input.IsActionJustPressed("jump") && IsOnFloor())
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

        UpdateAnimation();
        MoveAndSlide();
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

        if (!IsOnFloor())
        {
            _animationPlayer.Play("Jump");
        }
        else if (punching > 0.0f)
        {
            punching -= (float)GetPhysicsProcessDeltaTime();
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
            _particle.Emitting = false;
        }

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
