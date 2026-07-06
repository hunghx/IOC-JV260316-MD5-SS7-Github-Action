package com.devops.demo.userservice.controller;

import com.devops.demo.userservice.dto.UserDto;
import com.devops.demo.userservice.entity.User;
import com.devops.demo.userservice.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.BDDMockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration Test cho UserController (Web Layer Test)
 *
 * @WebMvcTest chỉ khởi động tầng Web (Controller, Filter, Security)
 * KHÔNG load toàn bộ ApplicationContext - chạy nhanh hơn @SpringBootTest
 *
 * MockMvc giả lập HTTP requests mà không cần khởi động server thật
 */
@WebMvcTest(UserController.class)
@DisplayName("UserController Integration Tests")
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private UserService userService;

    private UserDto.Response buildSampleResponse() {
        return UserDto.Response.builder()
                .id(1L)
                .name("Nguyễn Văn Test")
                .email("test@example.com")
                .role(User.Role.STUDENT)
                .active(true)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
    }

    // ==========================
    // TEST: GET /api/v1/users
    // ==========================
    @Test
    @DisplayName("GET /api/v1/users - Phải trả về 200 và danh sách users")
    void getAllUsers_ShouldReturn200WithList() throws Exception {
        // Given
        given(userService.getAllUsers()).willReturn(List.of(buildSampleResponse()));

        // When & Then
        mockMvc.perform(get("/api/v1/users")
                        .contentType(MediaType.APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data[0].email").value("test@example.com"))
                .andExpect(jsonPath("$.data[0].role").value("STUDENT"));
    }

    // ==========================
    // TEST: GET /api/v1/users/{id}
    // ==========================
    @Test
    @DisplayName("GET /api/v1/users/1 - Phải trả về 200 và thông tin user")
    void getUserById_ShouldReturn200WithUser() throws Exception {
        // Given
        given(userService.getUserById(1L)).willReturn(buildSampleResponse());

        // When & Then
        mockMvc.perform(get("/api/v1/users/1"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.name").value("Nguyễn Văn Test"));
    }

    // ==========================
    // TEST: POST /api/v1/users
    // ==========================
    @Test
    @DisplayName("POST /api/v1/users - Phải trả về 201 khi tạo user thành công")
    void createUser_WithValidData_ShouldReturn201() throws Exception {
        // Given
        UserDto.CreateRequest request = UserDto.CreateRequest.builder()
                .name("User Mới")
                .email("newuser@example.com")
                .role(User.Role.STUDENT)
                .build();

        given(userService.createUser(any(UserDto.CreateRequest.class)))
                .willReturn(buildSampleResponse());

        // When & Then
        mockMvc.perform(post("/api/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Tạo user thành công"));
    }

    // ==========================
    // TEST: POST /api/v1/users - Validation Failed
    // ==========================
    @Test
    @DisplayName("POST /api/v1/users - Phải trả về 400 khi email không hợp lệ")
    void createUser_WithInvalidEmail_ShouldReturn400() throws Exception {
        // Given: Request với email sai format
        UserDto.CreateRequest request = UserDto.CreateRequest.builder()
                .name("Test User")
                .email("email-khong-hop-le")  // Email không đúng format
                .build();

        // When & Then: Controller phải trả về 400 do @Valid fail
        mockMvc.perform(post("/api/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isBadRequest());
    }

    // ==========================
    // TEST: DELETE /api/v1/users/{id}
    // ==========================
    @Test
    @DisplayName("DELETE /api/v1/users/1 - Phải trả về 200 sau khi xóa")
    void deleteUser_ShouldReturn200() throws Exception {
        // Given: Service không ném exception
        willDoNothing().given(userService).deleteUser(1L);

        // When & Then
        mockMvc.perform(delete("/api/v1/users/1"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Xóa user thành công"));
    }
}
