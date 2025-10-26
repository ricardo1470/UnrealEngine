#ifndef WEAPON_H
#define WEAPON_H

#include <memory>
#include <string>
#include <iostream>

/**
 * @brief Abstract base class for weapons
 * Demonstrates polymorphism and unique_ptr
 */
class Weapon {
public:
    virtual ~Weapon();
    virtual void Fire() = 0;
};

class Pistol : public Weapon {
public:
    void Fire() override;
};

class Rifle : public Weapon {
public:
    void Fire() override;
};

std::unique_ptr<Weapon> CreateUniqueWeapon(const std::string& type);

#endif // WEAPON_H
