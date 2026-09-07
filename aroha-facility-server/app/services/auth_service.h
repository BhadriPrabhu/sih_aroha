#pragma once

#include <json/json.h>
#include <string>

class AuthService
{
public:
    explicit AuthService() = default;

    /// Authenticate a user/member against the database using name and member ID (password)
    Json::Value login(const std::string &name, const std::string &password);
};
