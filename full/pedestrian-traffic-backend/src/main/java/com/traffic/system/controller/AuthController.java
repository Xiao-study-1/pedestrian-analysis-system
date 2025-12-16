package com.traffic.system.controller;

import com.traffic.system.common.result.Result;
import com.traffic.system.common.utils.JwtUtils;
import com.traffic.system.entity.User;
import com.traffic.system.service.UserService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Api(tags = "认证管理")
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;
    private final JwtUtils jwtUtils;
    private final PasswordEncoder passwordEncoder;

    @ApiOperation("用户登录")
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody LoginRequest request) {
        // 查询用户
        User user = userService.getUserByUsername(request.getUsername());
        if (user == null) {
            return Result.error("用户名或密码错误");
        }

        // 验证密码
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return Result.error("用户名或密码错误");
        }

        // 生成Token
        String token = jwtUtils.generateToken(user.getUsername());

        // 构造返回数据
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        
        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("id", user.getId());
        userInfo.put("username", user.getUsername());
        userInfo.put("nickname", user.getNickname());
        userInfo.put("role", user.getRole());
        userInfo.put("avatar", user.getAvatar());
        data.put("userInfo", userInfo);

        return Result.success("登录成功", data);
    }

    @ApiOperation("用户登出")
    @PostMapping("/logout")
    public Result<?> logout() {
        return Result.success("登出成功");
    }

    @ApiOperation("获取当前用户信息")
    @GetMapping("/info")
    public Result<User> getUserInfo() {
        // 这里应该从SecurityContext中获取当前用户
        // 简化处理,直接返回示例数据
        User user = new User();
        user.setId(1L);
        user.setUsername("admin");
        user.setNickname("系统管理员");
        user.setRole("ADMIN");
        return Result.success(user);
    }

    @Data
    static class LoginRequest {
        private String username;
        private String password;
        private String captcha;
    }
}
