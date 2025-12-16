package com.traffic.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.traffic.system.entity.User;

public interface UserService extends IService<User> {
    User getUserByUsername(String username);
}
