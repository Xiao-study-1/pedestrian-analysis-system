# pedestrian-analysis-system
# 行人交通行为智能分析系统 - 项目交付说明

## 交付内容清单

本次交付包含以下文件和文档:

### 1. 核心项目文件

| 文件名 | 说明 |
|:------|:-----|
| `pedestrian-traffic-backend/` | Spring Boot 后端项目完整源码 |
| `pedestrian-traffic-frontend/` | Vue 3 前端项目完整源码 |
| `database_design.sql` | MySQL 数据库设计脚本 (包含建表和初始数据) |
| `README.md` | 项目说明和IDEA环境配置指南 |

### 2. 设计文档

| 文件名 | 说明 |
|:------|:-----|
| `system_analysis.md` | 系统需求分析文档 |
| `api_design.md` | API接口设计文档 (包含所有接口定义) |

---

## 快速开始指南

### 第一步: 导入数据库

使用 MySQL 数据库管理工具执行 `database_design.sql` 脚本,创建数据库和表结构。

```sql
-- 脚本会自动创建数据库: pedestrian_traffic_system
-- 并插入测试数据
```

### 第二步: 配置后端项目

1. 使用 IntelliJ IDEA 打开 `pedestrian-traffic-backend` 文件夹
2. 修改 `src/main/resources/application.yml` 中的数据库连接信息:

```yaml
spring:
  datasource:
    username: root      # 改为您的MySQL用户名
    password: root      # 改为您的MySQL密码
```

3. 运行主类 `PedestrianTrafficApplication.java`

### 第三步: 启动前端项目

1. 进入 `pedestrian-traffic-frontend` 目录
2. 安装依赖: `pnpm install` (或 `npm install`)
3. 启动开发服务器: `pnpm dev`
4. 浏览器访问: `http://localhost:3000`

### 第四步: 登录系统

- 用户名: `admin`
- 密码: `admin123`

---

## 项目架构说明

### 后端架构 (Spring Boot)

后端采用经典的三层架构设计,职责清晰,便于维护和扩展。

**Controller 层** (控制器层) 负责接收HTTP请求,调用Service层处理业务逻辑,并返回JSON格式的响应数据。我们已经为您实现了 `AuthController` (认证控制器) 和 `DashboardController` (首页大屏控制器) 作为示例。

**Service 层** (服务层) 包含核心业务逻辑,处理数据校验、业务规则和事务管理。目前实现了 `UserService` 用于用户相关的业务操作。

**Mapper 层** (数据访问层) 使用 MyBatis Plus 框架,简化了数据库操作。每个实体类都对应一个 Mapper 接口,继承 `BaseMapper` 即可获得基础的 CRUD 功能。

### 前端架构 (Vue 3)

前端采用 Vue 3 Composition API 开发,配合 Vite 构建工具,提供快速的开发体验。

**路由管理** 使用 Vue Router 实现页面导航,并在路由守卫中处理登录状态验证。所有需要登录的页面都设置了 `requireAuth: true` 的元数据。

**状态管理** 采用 Pinia 管理全局状态,目前实现了 `useUserStore` 用于管理用户登录状态和用户信息。

**API封装** 在 `src/api/index.js` 中统一管理所有后端接口调用,使用 Axios 进行HTTP请求,并在 `request.js` 中配置了请求拦截器和响应拦截器,自动处理Token和错误信息。

**组件化开发** 页面级组件放在 `views` 目录,可复用的UI组件放在 `components` 目录。我们已经实现了登录页面和首页大屏的基础框架。

---

## 数据接口说明

所有API接口都已经在后端实现并提供Mock数据,前端可以直接调用。接口遵循 RESTful 规范,统一返回格式如下:

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1700000000000
}
```

### 主要接口模块

**认证模块** (`/api/auth/*`) 提供用户登录、登出和获取用户信息的功能。登录成功后会返回JWT Token,前端需要在后续请求中携带此Token。

**首页大屏** (`/api/dashboard/*`) 提供违规行为TOP5、设备在线状态、行为类型占比、处置结果占比、人流量趋势等数据接口,支持时间范围筛选。

**违规记录** (`/api/violations`) 提供违规记录的增删改查功能,支持分页查询和条件筛选。

**人流分析** (`/api/traffic/*`) 提供总人流量统计、停留时间分布、高峰时段分析、重点区域分析和趋势分析等接口。

**预警管理** (`/api/alerts`) 提供预警列表查询、预警处理和预警统计功能。

详细的接口参数和返回值说明,请查看 `api_design.md` 文档,或启动后端服务后访问 `http://localhost:8080/doc.html` 查看在线API文档。

---

## 前端界面保持说明

我们已经将原始HTML页面的样式和布局完整迁移到Vue组件中,主要保留了以下特性:

**视觉风格** 保持了深色科技风格,使用了相同的配色方案 (主色调 `#00d4ff`),并保留了渐变背景、发光边框等视觉效果。

**布局结构** 首页采用三栏布局 (左栏、中栏、右栏),与原始设计一致。顶部导航栏固定在页面顶部,包含系统标题、导航菜单和用户信息。

**图表展示** 使用 ECharts 替代了原来的 Chart.js,实现了相同的图表效果,包括柱状图、环形图、折线图等。

**响应式设计** 保留了原有的响应式布局,适配不同屏幕尺寸。

---

## 后续开发建议

### 1. 完善其他页面

我们已经为您创建了所有页面的路由和占位组件,您可以参考原始HTML文件 (`movies.html`, `people.html`, `remind.html`, `person-information.html`) 继续开发这些页面。

### 2. 实现真实数据接口

目前后端接口返回的是Mock数据,您需要在 Service 层实现真实的数据库查询逻辑。我们已经创建了所有实体类和 Mapper 接口,您可以直接使用 MyBatis Plus 提供的方法进行数据操作。

### 3. 完善权限控制

当前的 Spring Security 配置比较简单,您可以根据实际需求添加更细粒度的权限控制,例如基于角色的访问控制 (RBAC)。

### 4. 添加实时数据更新

原始系统中有定时刷新数据的功能,您可以在Vue组件中使用 `setInterval` 或 WebSocket 实现实时数据更新。

### 5. 优化性能

- 后端可以添加 Redis 缓存,减少数据库查询压力
- 前端可以使用虚拟滚动、懒加载等技术优化大数据量渲染
- 图表可以使用防抖节流优化频繁更新

---

## 技术支持

如果您在使用过程中遇到任何问题,可以参考以下资源:

- **Spring Boot 官方文档**: https://spring.io/projects/spring-boot
- **Vue 3 官方文档**: https://cn.vuejs.org/
- **MyBatis Plus 官方文档**: https://baomidou.com/
- **Element Plus 官方文档**: https://element-plus.org/zh-CN/
- **ECharts 官方文档**: https://echarts.apache.org/zh/index.html

---

## 项目文件说明

### 后端关键文件

- `pom.xml` - Maven 依赖配置
- `application.yml` - Spring Boot 配置文件
- `PedestrianTrafficApplication.java` - 主启动类
- `SecurityConfig.java` - Spring Security 安全配置
- `JwtUtils.java` - JWT Token 工具类
- `Result.java` - 统一响应结果封装
- `GlobalExceptionHandler.java` - 全局异常处理器

### 前端关键文件

- `package.json` - npm 依赖配置
- `vite.config.js` - Vite 构建配置
- `main.js` - Vue 应用入口
- `router/index.js` - 路由配置
- `utils/request.js` - Axios 请求封装
- `api/index.js` - API 接口定义
- `store/user.js` - 用户状态管理

---

祝您开发顺利! 如有任何疑问,欢迎随时咨询。
