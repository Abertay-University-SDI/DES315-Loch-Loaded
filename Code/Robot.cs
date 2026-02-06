using System.Diagnostics;
using Godot;

public partial class Robot : Node2D
{
    [Export] public int MaxHealth = 3;

    private int _health;

    private CharacterBody2D _alive;
    private RigidBody2D _dead;
    private Sprite2D _alive_sprite;

    private AnimationPlayer _animationPlayer;

    [Export] public float WalkSpeed = 40f;
    [Export] public float GroundCheckDistance = 8f;

    private int _direction = -1; // -1 = left, 1 = right

    private float immunity = 0.0f;

    public override void _Ready()
    {
        _health = MaxHealth;

        _alive = GetNode<CharacterBody2D>("alive_body");
        _dead = GetNode<RigidBody2D>("dead_body");

        _animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
        _alive_sprite = _alive.GetNode<Sprite2D>("Sprite2D");

        _dead.Freeze = true;
        _dead.Visible = false;  
    }

    public void TakeHit(Vector2 hitDir,float hit_duration, float force)
    {
        if (immunity > 0.0f)
            return;
        
        immunity = hit_duration;

        _health--;
        Debug.Print($"TrashCanEnemy took hit! Remaining health: {_health}");
        _animationPlayer.Play("take_hit");
        if (_health <= 0)
            Die(hitDir, force);
    }

    private bool HasGroundAhead()
    {
        Vector2 origin = _alive.GlobalPosition;
        origin.X += _direction * 12f;

        Vector2 target = origin + Vector2.Down * GroundCheckDistance;

        var space = GetWorld2D().DirectSpaceState;

        var query = PhysicsRayQueryParameters2D.Create(
            origin,
            target
        );

        query.CollisionMask = 1; // world layer
        var result = space.IntersectRay(query);

        return result.Count > 0;
    }

    public override void _PhysicsProcess(double delta)
    {
        if (!_alive.Visible)
            return;

        float dt = (float)delta;

        // gravity
        if (!_alive.IsOnFloor())
            _alive.Velocity += Vector2.Down * 1200f * dt;

        // walk
        _alive.Velocity = new Vector2(_direction * WalkSpeed, _alive.Velocity.Y);

        // ledge check
        if (!HasGroundAhead())
            _direction *= -1;

        _alive_sprite.FlipH = _direction > 0;
        _alive.MoveAndSlide();
    }

    public override void _Process(double delta)
    {
        immunity -= (float)delta;
    }

    private void ApplyDeathImpulse(Vector2 hitDir, float force)
    {
        _dead.ApplyImpulse(hitDir * force);
        _dead.ApplyTorqueImpulse(force * 0.4f);
    }

    private void Die(Vector2 hitDir, float force)
    {
        // sync transforms
        _dead.GlobalPosition = _alive.GlobalPosition;
        _dead.Rotation = _alive.Rotation;

        // disable alive body
        _alive.SetPhysicsProcess(false);
        _alive.Visible = false;
        _alive.CollisionLayer = 0;
        _alive.CollisionMask = 0;

        // enable physics body
        _dead.Visible = true;
        _dead.CollisionLayer = 0;
        _dead.CollisionMask = 1;
        _dead.SetDeferred("freeze", false);
        CallDeferred(nameof(ApplyDeathImpulse), hitDir, force);
    }
}
