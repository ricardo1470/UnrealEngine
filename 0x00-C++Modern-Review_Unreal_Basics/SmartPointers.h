#ifndef SMART_POINTERS_H
#define SMART_POINTERS_H

#include <iostream>
#include <memory>
#include <string>

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

class Texture {
public:
    Texture(const std::string& name);
    ~Texture();

private:
    std::string name_;
};

class Material {
public:
    Material(std::shared_ptr<Texture> tex);

private:
    std::shared_ptr<Texture> texture_;
};

class Enemy;

class Player {
public:
    void SetTarget(std::shared_ptr<Enemy> enemy);
    void Attack();

private:
    std::weak_ptr<Enemy> target_;
};

class Enemy : public std::enable_shared_from_this<Enemy> {
public:
    void TakeDamage(int damage);
    bool IsAlive() const;

private:
    int health_ = 100;
};

#endif // SMART_POINTERS_H
