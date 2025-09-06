package com.example.springboot_mysql_login_ci_sonar.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 登入請求 DTO
 */
@Data
public class LoginRequest {

    @NotBlank(message = "登入 ID 不能為空")
    private String loginId;

    @NotBlank(message = "密碼不能為空")
    private String password;
}


