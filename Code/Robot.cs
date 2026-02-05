using System.Diagnostics;
using Godot;

public partial class Robot : Node2D
{
    [Export] public int MaxHealth = 3;

    private int _health;

    private CharacterBody2D _alive;
    private RigidBody2D _dead;

    public override void _Ready()
    {
        _health = MaxHealth;

        _alive = GetNode<CharacterBody2D>("alive_body");
        _dead = GetNode<RigidBody2D>("dead_body");

        _dead.Freeze = true;
        _dead.Visible = false;  
    }

    public void TakeHit(Vector2 hitDir, float force)
    {
        _health--;
        Debug.Print($"TrashCanEnemy took hit! Remaining health: {_health}");

        if (_health <= 0)
            Die(hitDir, force);
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
        _dead.Freeze = false;
        _dead.ApplyImpulse(hitDir * force);
        _dead.ApplyTorqueImpulse(force * 0.4f);
    }
}
