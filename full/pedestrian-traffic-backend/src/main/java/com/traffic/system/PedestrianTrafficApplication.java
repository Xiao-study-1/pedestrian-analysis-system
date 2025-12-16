package com.traffic.system;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.traffic.system.mapper")
public class PedestrianTrafficApplication {
    public static void main(String[] args) {
        SpringApplication.run(PedestrianTrafficApplication.class, args);
        System.out.println("========================================");
        System.out.println("行人交通行为智能分析系统启动成功!");
        System.out.println("API文档地址: http://localhost:8080/doc.html");
        System.out.println("========================================");
    }
}
