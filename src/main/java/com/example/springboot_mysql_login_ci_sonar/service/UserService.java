package com.example.springboot_mysql_login_ci_sonar.service;

import com.example.springboot_mysql_login_ci_sonar.entity.User;
import com.example.springboot_mysql_login_ci_sonar.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * User 業務邏輯層
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * 用戶註冊
     * @param username 用戶名稱
     * @param loginId 登入 ID
     * @param password 密碼
     * @return User 註冊成功的用戶
     * @throws IllegalArgumentException 當用戶名稱或登入 ID 已存在時
     */
    public User signup(String username, String loginId, String password) {
        log.info("開始用戶註冊流程: username={}, loginId={}", username, loginId);

        // 檢查用戶名稱是否已存在
        if (userRepository.existsByUsername(username)) {
            log.warn("用戶名稱已存在: {}", username);
            throw new IllegalArgumentException("用戶名稱已存在");
        }

        // 檢查登入 ID 是否已存在
        if (userRepository.existsByLoginId(loginId)) {
            log.warn("登入 ID 已存在: {}", loginId);
            throw new IllegalArgumentException("登入 ID 已存在");
        }

        // 建立新用戶
        User user = new User();
        user.setUsername(username);
        user.setLoginId(loginId);
        user.setPassword(passwordEncoder.encode(password)); // 密碼加密
        user.setEnabled(true);

        User savedUser = userRepository.save(user);
        log.info("用戶註冊成功: id={}, username={}, loginId={}", savedUser.getId(), username, loginId);
        
        return savedUser;
    }

    /**
     * 用戶登入驗證
     * @param loginId 登入 ID
     * @param password 密碼
     * @return Optional<User> 登入成功的用戶
     */
    @Transactional(readOnly = true)
    public Optional<User> login(String loginId, String password) {
        log.info("開始用戶登入驗證: loginId={}", loginId);

        Optional<User> userOpt = userRepository.findByLoginId(loginId);
        if (userOpt.isEmpty()) {
            log.warn("登入失敗: 找不到用戶 loginId={}", loginId);
            return Optional.empty();
        }

        User user = userOpt.get();
        if (!user.getEnabled()) {
            log.warn("登入失敗: 用戶已停用 loginId={}", loginId);
            return Optional.empty();
        }

        // 驗證密碼
        if (!passwordEncoder.matches(password, user.getPassword())) {
            log.warn("登入失敗: 密碼錯誤 loginId={}", loginId);
            return Optional.empty();
        }

        log.info("用戶登入成功: id={}, username={}, loginId={}", user.getId(), user.getUsername(), loginId);
        return Optional.of(user);
    }

    /**
     * 根據登入 ID 查找用戶
     * @param loginId 登入 ID
     * @return Optional<User>
     */
    @Transactional(readOnly = true)
    public Optional<User> findByLoginId(String loginId) {
        return userRepository.findByLoginId(loginId);
    }

    /**
     * 根據用戶名稱查找用戶
     * @param username 用戶名稱
     * @return Optional<User>
     */
    @Transactional(readOnly = true)
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

}
