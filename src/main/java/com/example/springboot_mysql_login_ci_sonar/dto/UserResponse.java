package com.example.springboot_mysql_login_ci_sonar.dto;

import com.example.springboot_mysql_login_ci_sonar.entity.User;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用戶回應 DTO
 */
@Data
public class UserResponse {
    
    private Long id;
    private String username;
    private String loginId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Boolean enabled;

    public static UserResponse from(User user) {
        UserResponse response = new UserResponse();
        response.setId(user.getId());
        response.setUsername(user.getUsername());
        response.setLoginId(user.getLoginId());
        response.setCreatedAt(user.getCreatedAt());
        response.setUpdatedAt(user.getUpdatedAt());
        response.setEnabled(user.getEnabled());
        return response;
    }
}


