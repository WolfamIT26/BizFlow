package com.example.bizflow.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateBranchRequest {
    private String name;
    private String address;
    private String phone;
    private String email;
    private Long ownerId;
}
