package com.traffic.system.controller;

import com.traffic.system.common.result.Result;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@Api(tags = "首页大屏")
@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    @ApiOperation("违规行为TOP5")
    @GetMapping("/violation-top5")
    public Result<List<ViolationTop5VO>> getViolationTop5(@RequestParam(defaultValue = "today") String timeRange) {
        List<ViolationTop5VO> list = new ArrayList<>();
        list.add(new ViolationTop5VO("闯红灯", 381, "学校门口路口"));
        list.add(new ViolationTop5VO("违规横穿", 87, "商业街路口"));
        list.add(new ViolationTop5VO("路口逗留", 87, "医院门口"));
        list.add(new ViolationTop5VO("逆行", 70, "地铁站出口"));
        list.add(new ViolationTop5VO("违规骑行", 64, "公园入口"));
        return Result.success(list);
    }

    @ApiOperation("设备在线状态")
    @GetMapping("/device-status")
    public Result<DeviceStatusVO> getDeviceStatus() {
        DeviceStatusVO vo = new DeviceStatusVO();
        vo.setTotal(100);
        vo.setOnline(67);
        vo.setOffline(33);
        
        List<AreaStatusVO> areaStatus = new ArrayList<>();
        areaStatus.add(new AreaStatusVO("所有路口", 67));
        areaStatus.add(new AreaStatusVO("学校区", 84));
        areaStatus.add(new AreaStatusVO("商圈", 60));
        areaStatus.add(new AreaStatusVO("医院周边", 50));
        areaStatus.add(new AreaStatusVO("交通枢纽", 61));
        vo.setAreaStatus(areaStatus);
        
        return Result.success(vo);
    }

    @ApiOperation("行人行为类型占比")
    @GetMapping("/behavior-ratio")
    public Result<BehaviorRatioVO> getBehaviorRatio() {
        BehaviorRatioVO vo = new BehaviorRatioVO();
        vo.setTotalSamples(2000);
        
        List<BehaviorItemVO> behaviors = new ArrayList<>();
        behaviors.add(new BehaviorItemVO("合规通行", 860, 43));
        behaviors.add(new BehaviorItemVO("闯红灯", 600, 30));
        behaviors.add(new BehaviorItemVO("违规横穿", 260, 13));
        behaviors.add(new BehaviorItemVO("其他", 160, 8));
        behaviors.add(new BehaviorItemVO("路口逗留", 120, 6));
        vo.setBehaviors(behaviors);
        
        return Result.success(vo);
    }

    @ApiOperation("行为处置结果占比")
    @GetMapping("/disposal-ratio")
    public Result<List<DisposalRatioVO>> getDisposalRatio() {
        List<DisposalRatioVO> list = new ArrayList<>();
        list.add(new DisposalRatioVO("和解劝离案件", 20.8));
        list.add(new DisposalRatioVO("引导整改案件", 20.8));
        list.add(new DisposalRatioVO("罚款警示案件", 20.8));
        list.add(new DisposalRatioVO("其他处置", 37.6));
        return Result.success(list);
    }

    @ApiOperation("人流量趋势")
    @GetMapping("/traffic-trend")
    public Result<TrafficTrendVO> getTrafficTrend(@RequestParam(defaultValue = "7") Integer days) {
        TrafficTrendVO vo = new TrafficTrendVO();
        vo.setDates(Arrays.asList("周一", "周二", "周三", "周四", "周五"));
        vo.setAvgFlow(Arrays.asList(3200, 3500, 3100, 3800, 4200));
        vo.setPeakFlow(Arrays.asList(4500, 4800, 4300, 5100, 5500));
        return Result.success(vo);
    }

    // VO类定义
    @Data
    static class ViolationTop5VO {
        private String violationType;
        private Integer count;
        private String location;
        
        public ViolationTop5VO(String violationType, Integer count, String location) {
            this.violationType = violationType;
            this.count = count;
            this.location = location;
        }
    }

    @Data
    static class DeviceStatusVO {
        private Integer total;
        private Integer online;
        private Integer offline;
        private List<AreaStatusVO> areaStatus;
    }

    @Data
    static class AreaStatusVO {
        private String areaName;
        private Integer onlineRate;
        
        public AreaStatusVO(String areaName, Integer onlineRate) {
            this.areaName = areaName;
            this.onlineRate = onlineRate;
        }
    }

    @Data
    static class BehaviorRatioVO {
        private Integer totalSamples;
        private List<BehaviorItemVO> behaviors;
    }

    @Data
    static class BehaviorItemVO {
        private String type;
        private Integer count;
        private Integer percentage;
        
        public BehaviorItemVO(String type, Integer count, Integer percentage) {
            this.type = type;
            this.count = count;
            this.percentage = percentage;
        }
    }

    @Data
    static class DisposalRatioVO {
        private String type;
        private Double percentage;
        
        public DisposalRatioVO(String type, Double percentage) {
            this.type = type;
            this.percentage = percentage;
        }
    }

    @Data
    static class TrafficTrendVO {
        private List<String> dates;
        private List<Integer> avgFlow;
        private List<Integer> peakFlow;
    }
}


