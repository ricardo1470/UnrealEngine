#include "SmartPointers.h"

/**
    * Main function to test Smart Pointer implementations.
    * Demonstrates unique_ptr, shared_ptr, and weak_ptr usage.
 */
int main()
{
    std::cout << "=== Test Unique Ptr ===\n";
    {
        auto weapon = CreateUniqueWeapon("pistol");
        weapon->Fire();
    }

    std::cout << "\n=== Test Shared Ptr ===\n";
    {
        auto texture = std::make_shared<Texture>("brick.png");
        Material mat1(texture);
        Material mat2(texture);
    }

    std::cout << "\n=== Test Weak Ptr ===\n";
    Player player;
    {
        auto enemy = std::make_shared<Enemy>();
        player.SetTarget(enemy);
        player.Attack();
        player.Attack();
    }
    player.Attack();

    return 0;
}
