#include "Player.h"
#include "Enemy.h"
#include <iostream>

void Player::SetTarget(std::shared_ptr<Enemy> enemy) {
    target_ = enemy;
    std::cout << "Target set\n";
}

void Player::Attack() {
    if (auto enemy = target_.lock()) {
        if (enemy->IsAlive()) {
            std::cout << "Attacking target...\n";
            enemy->TakeDamage(25);
        } else {
            std::cout << "Enemy is already dead!\n";
        }
    } else {
        std::cout << "Target is gone!\n";
    }
}
