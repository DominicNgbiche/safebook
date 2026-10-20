
package com.safebook.safebook.dto;

import com.safebook.safebook.model.User;

public record AdminUserResponse(
        Long id,
        String email,
        String role,
        boolean emailVerified
) {
    public static AdminUserResponse from(User user) {
        return new AdminUserResponse(
                user.getId(),
                user.getEmail(),
                user.getRole(),
                user.isEmailVerified()
        );
    }
}
