#ifndef PLAYER_H
#define PLAYER_H

#include <memory>

class Enemy;

/**
 * @brief Player class demonstrating weak_ptr
 * Uses weak_ptr to avoid circular references
 */
class Player {
public:
    void SetTarget(std::shared_ptr<Enemy> enemy);
    void Attack();

private:
    std::weak_ptr<Enemy> target_;
};

#endif // PLAYER_H
