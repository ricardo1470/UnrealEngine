#include "SmartPointers.h"

class Weapon
{
    public:
        virtual ~Weapon() = {std::cout << "Weapon destroyed\n"; };
        virtual void Fire() = 0;
};

class Pistol : public Weapon
{
    public:
        void Fire() override
        {
            std::cout << "Bang!\n";
        }
};

class Rifle : public Weapon
{
    public:
        void Fire() override
        {
            std::cout << "Rat-a-tat-tat!\n";
        }
};


std::unique_ptr<Weapon> CreateUniqueWeapon(const std::string& type)
{
    if (type == "pistol")
    {
        return std::make_unique<Pistol>();
    }
    else if (type == "rifle")
    {
        return std::make_unique<Rifle>();
    }
    return nullptr;
}

class Texture
{
    public:
        Texture(const std::string& name) : name_(name)
        {
            std::cout << "Texture loaded " << name_ << "\n";
        }
        ~Texture()
        {
            std::cout << "Texture unloaded: " << name_ << "\n";
        }
    private:
        std::string name_;
};

class Material
{
    public:
        Material(std::shared_ptr<Texture> tex) : texture_(tex) {}
    private:
        std::shared_ptr<Texture> texture_;
};

class  Enemy;

class Player {
    public:
        void SetTarget(std::shared_ptr<Enemy> enemy);
        void Attack();
    private:
        std::weak_ptr<Enemy> target_;
};

class Enemy : public std::enable_shared_from_this<Enemy> {
public:
    void TakeDamage(int damage) {
        health_ -= damage;
        std::cout << "Enemy health: " << health_ << "\n";
    }
    bool IsAlive() const { return health_ > 0; }
private:
    int health_ = 100;
};

void Player::SetTarget(std::shared_ptr<Enemy> enemy) {
    target_ = enemy;
}

void Player::Attack() {
    if (auto enemy = target_.lock()) {
        if (enemy->IsAlive()) {
            enemy->TakeDamage(25);
        }
    } else {
        std::cout << "Target is gone!\n";
    }
}
