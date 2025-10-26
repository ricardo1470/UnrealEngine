#include "SmartPointers.h"

/**
    * Implementations for Weapon, Texture, Material, Player, and Enemy classes.
 */
Weapon::~Weapon() {
    std::cout << "Weapon destroyed\n";
}

void Pistol::Fire() {
    std::cout << "Bang!\n";
}

void Rifle::Fire() {
    std::cout << "Rat-a-tat-tat!\n";
}

std::unique_ptr<Weapon> CreateUniqueWeapon(const std::string& type) {
    if (type == "pistol") {
        return std::make_unique<Pistol>();
    } else if (type == "rifle") {
        return std::make_unique<Rifle>();
    }
    return nullptr;
}

Texture::Texture(const std::string& name) : name_(name) {
    std::cout << "Texture loaded: " << name_ << "\n";
}

Texture::~Texture() {
    std::cout << "Texture unloaded: " << name_ << "\n";
}

Material::Material(std::shared_ptr<Texture> tex) : texture_(tex) {}

void Enemy::TakeDamage(int damage) {
    health_ -= damage;
    std::cout << "Enemy health: " << health_ << "\n";
}

bool Enemy::IsAlive() const {
    return health_ > 0;
}

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
