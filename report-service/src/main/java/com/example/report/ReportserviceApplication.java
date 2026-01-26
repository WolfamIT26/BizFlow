package com.example.report;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = {"com.example.report", "com.example.bizflow"})
public class ReportserviceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ReportserviceApplication.class, args);
    }
}
