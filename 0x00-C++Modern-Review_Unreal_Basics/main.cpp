#include "SmartPointers.h"

int main()
{
    std::cout << "=== Test Unique Ptr ===\n";
    {
        auto weapon = CreateUniqueWeapon("pistol");
        weapon->Fire();
    }
}
