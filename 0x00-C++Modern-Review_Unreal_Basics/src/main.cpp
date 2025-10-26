#include "Weapon.h"
#include "Texture.h"
#include "Material.h"
#include "Enemy.h"
#include "Player.h"

/**
 * @brief Main function demonstrating smart pointer usage
 * Tests unique_ptr, shared_ptr, weak_ptr, and enable_shared_from_this
 */
int main() {
    std::cout << "=== Smart Pointers Demo ===\n\n";
    
    // Test 1: unique_ptr
    std::cout << "=== Test 1: unique_ptr (Exclusive Ownership) ===\n";
    {
        auto pistol = CreateUniqueWeapon("pistol");
        if (pistol) {
            pistol->Fire();
        }
        
        auto rifle = CreateUniqueWeapon("rifle");
        if (rifle) {
            rifle->Fire();
        }
        std::cout << "Leaving scope, weapons will be destroyed...\n";
    }
    std::cout << "\n";
    
    // Test 2: shared_ptr
    std::cout << "=== Test 2: shared_ptr (Shared Ownership) ===\n";
    {
        auto texture = std::make_shared<Texture>("brick.png");
        std::cout << "Texture ref count: " << texture.use_count() << "\n";
        
        {
            Material mat1(texture);
            std::cout << "After mat1, ref count: " << texture.use_count() << "\n";
            
            Material mat2(texture);
            std::cout << "After mat2, ref count: " << texture.use_count() << "\n";
            
            std::cout << "Materials going out of scope...\n";
        }
        
        std::cout << "After materials destroyed, ref count: " 
                  << texture.use_count() << "\n";
    }
    std::cout << "\n";
    
    // Test 3: weak_ptr
    std::cout << "=== Test 3: weak_ptr (Non-owning Reference) ===\n";
    Player player;
    {
        auto enemy = std::make_shared<Enemy>();
        player.SetTarget(enemy);
        
        std::cout << "Attacking while enemy exists:\n";
        player.Attack();
        player.Attack();
        
        std::cout << "Enemy about to be destroyed...\n";
    }
    
    std::cout << "Attacking after enemy destroyed:\n";
    player.Attack();
    std::cout << "\n";
    
    // Test 4: enable_shared_from_this
    std::cout << "=== Test 4: enable_shared_from_this ===\n";
    {
        auto enemy = std::make_shared<Enemy>();
        auto sameEnemy = enemy->GetSharedPtr();
        
        std::cout << "Both pointers point to same enemy: " 
                  << (enemy == sameEnemy ? "YES" : "NO") << "\n";
        std::cout << "Ref count: " << enemy.use_count() << "\n";
    }
    
    std::cout << "\n=== Demo Complete ===\n";
    return 0;
}
