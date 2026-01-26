package com.example.payment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = {"com.example.payment", "com.example.bizflow"})
public class PaymentserviceApplication {
    public static void main(String[] args) {
        SpringApplication.run(PaymentserviceApplication.class, args);
    }
}
