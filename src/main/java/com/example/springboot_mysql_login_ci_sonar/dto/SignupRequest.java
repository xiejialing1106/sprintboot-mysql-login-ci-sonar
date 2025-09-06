package com.example.springboot_mysql_login_ci_sonar.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 註冊請求 DTO
 */
@Data
public class SignupRequest {

    @NotBlank(message = "用戶名稱不能為空")
    @Size(min = 2, max = 50, message = "用戶名稱長度必須在 2-50 字元之間")
    private String username;

    @NotBlank(message = "登入 ID 不能為空")
    @Size(min = 3, max = 30, message = "登入 ID 長度必須在 3-30 字元之間")
    private String loginId;

    @NotBlank(message = "密碼不能為空")
    @Size(min = 6, message = "密碼長度至少 6 字元")
    private String password;
}


