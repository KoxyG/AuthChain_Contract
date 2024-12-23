// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract UserRoleManager {

    enum userRole { 
        Default, 
        Consumers, 
        Manufacturer, 
        LogisticsPersonnel, 
        Retailers, 
        Admin 
    }

    mapping(address => userRole) public userRoles;

    event UserRoleAssigned(
        address indexed userAddress,
        userRole role
    );

    function assignRole(address user, userRole role) public {
        userRoles[user] = role;
        emit UserRoleAssigned(user, role);
    }

    function getUserRole(address user) public view returns (userRole) {
        return userRoles[user];
    }

}