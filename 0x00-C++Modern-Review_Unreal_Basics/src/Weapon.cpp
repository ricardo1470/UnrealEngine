#include "Weapon.h"

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
