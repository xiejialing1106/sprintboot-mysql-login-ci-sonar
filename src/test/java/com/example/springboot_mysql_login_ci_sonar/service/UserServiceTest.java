package com.example.springboot_mysql_login_ci_sonar.service;

import com.example.springboot_mysql_login_ci_sonar.entity.User;
import com.example.springboot_mysql_login_ci_sonar.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * UserService 單元測試
 */
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserService userService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("測試用戶");
        testUser.setLoginId("testuser");
        testUser.setPassword("encodedPassword");
        testUser.setCreatedAt(LocalDateTime.now());
        testUser.setUpdatedAt(LocalDateTime.now());
        testUser.setEnabled(true);
    }

    @Test
    void testSignup_Success() {
        // Given
        when(userRepository.existsByUsername("測試用戶")).thenReturn(false);
        when(userRepository.existsByLoginId("testuser")).thenReturn(false);
        when(passwordEncoder.encode("password123")).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        User result = userService.signup("測試用戶", "testuser", "password123");

        // Then
        assertNotNull(result);
        assertEquals("測試用戶", result.getUsername());
        assertEquals("testuser", result.getLoginId());
        assertEquals("encodedPassword", result.getPassword());
        assertTrue(result.getEnabled());

        verify(userRepository).existsByUsername("測試用戶");
        verify(userRepository).existsByLoginId("testuser");
        verify(passwordEncoder).encode("password123");
        verify(userRepository).save(any(User.class));
    }

    @Test
    void testSignup_UsernameAlreadyExists() {
        // Given
        when(userRepository.existsByUsername("測試用戶")).thenReturn(true);

        // When & Then
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.signup("測試用戶", "testuser", "password123");
        });

        assertEquals("用戶名稱已存在", exception.getMessage());
        verify(userRepository).existsByUsername("測試用戶");
        verify(userRepository, never()).existsByLoginId(anyString());
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void testSignup_LoginIdAlreadyExists() {
        // Given
        when(userRepository.existsByUsername("測試用戶")).thenReturn(false);
        when(userRepository.existsByLoginId("testuser")).thenReturn(true);

        // When & Then
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.signup("測試用戶", "testuser", "password123");
        });

        assertEquals("登入 ID 已存在", exception.getMessage());
        verify(userRepository).existsByUsername("測試用戶");
        verify(userRepository).existsByLoginId("testuser");
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void testLogin_Success() {
        // Given
        when(userRepository.findByLoginId("testuser")).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches("password123", "encodedPassword")).thenReturn(true);

        // When
        Optional<User> result = userService.login("testuser", "password123");

        // Then
        assertTrue(result.isPresent());
        assertEquals(testUser, result.get());
        verify(userRepository).findByLoginId("testuser");
        verify(passwordEncoder).matches("password123", "encodedPassword");
    }

    @Test
    void testLogin_UserNotFound() {
        // Given
        when(userRepository.findByLoginId("testuser")).thenReturn(Optional.empty());

        // When
        Optional<User> result = userService.login("testuser", "password123");

        // Then
        assertFalse(result.isPresent());
        verify(userRepository).findByLoginId("testuser");
        verify(passwordEncoder, never()).matches(anyString(), anyString());
    }

    @Test
    void testLogin_WrongPassword() {
        // Given
        when(userRepository.findByLoginId("testuser")).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches("wrongpassword", "encodedPassword")).thenReturn(false);

        // When
        Optional<User> result = userService.login("testuser", "wrongpassword");

        // Then
        assertFalse(result.isPresent());
        verify(userRepository).findByLoginId("testuser");
        verify(passwordEncoder).matches("wrongpassword", "encodedPassword");
    }

    @Test
    void testLogin_UserDisabled() {
        // Given
        testUser.setEnabled(false);
        when(userRepository.findByLoginId("testuser")).thenReturn(Optional.of(testUser));

        // When
        Optional<User> result = userService.login("testuser", "password123");

        // Then
        assertFalse(result.isPresent());
        verify(userRepository).findByLoginId("testuser");
        verify(passwordEncoder, never()).matches(anyString(), anyString());
    }

    @Test
    void testFindByLoginId() {
        // Given
        when(userRepository.findByLoginId("testuser")).thenReturn(Optional.of(testUser));

        // When
        Optional<User> result = userService.findByLoginId("testuser");

        // Then
        assertTrue(result.isPresent());
        assertEquals(testUser, result.get());
        verify(userRepository).findByLoginId("testuser");
    }

    @Test
    void testFindByUsername() {
        // Given
        when(userRepository.findByUsername("測試用戶")).thenReturn(Optional.of(testUser));

        // When
        Optional<User> result = userService.findByUsername("測試用戶");

        // Then
        assertTrue(result.isPresent());
        assertEquals(testUser, result.get());
        verify(userRepository).findByUsername("測試用戶");
    }

}
