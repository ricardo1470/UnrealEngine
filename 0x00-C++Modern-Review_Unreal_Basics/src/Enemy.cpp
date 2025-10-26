#include "Enemy.h"
#include <iostream>

Enemy::Enemy() : health_(100) {
    std::cout << "Enemy created with " << health_ << " health\n";
}

void Enemy::TakeDamage(int damage) {
    health_ -= damage;
    std::cout << "Enemy health: " << health_ << "\n";
}

bool Enemy::IsAlive() const {
    return health_ > 0;
}

std::shared_ptr<Enemy> Enemy::GetSharedPtr() {
    return shared_from_this();
}
