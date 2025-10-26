#ifndef ENEMY_H
#define ENEMY_H

#include <memory>

/**
 * @brief Enemy class demonstrating enable_shared_from_this
 * Allows creating shared_ptr to itself safely
 */
class Enemy : public std::enable_shared_from_this<Enemy> {
public:
    Enemy();
    
    void TakeDamage(int damage);
    bool IsAlive() const;
    std::shared_ptr<Enemy> GetSharedPtr();

private:
    int health_;
};

#endif // ENEMY_H
