abstract class Particle {
    // Attributes inherited by Meteorites and Projectiles
    float invMass;
    PVector velocity;
    PVector acceleration;
    // Methods inherited by Meteorites and Projectiles
    abstract void integrate();
    abstract void addForce(PVector force);
    abstract float getMass();
}