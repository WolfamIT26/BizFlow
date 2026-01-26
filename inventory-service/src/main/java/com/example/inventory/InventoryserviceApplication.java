package com.example.inventory;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = {"com.example.inventory", "com.example.bizflow"})
public class InventoryserviceApplication {
    public static void main(String[] args) {
        SpringApplication.run(InventoryserviceApplication.class, args);
    }
}
