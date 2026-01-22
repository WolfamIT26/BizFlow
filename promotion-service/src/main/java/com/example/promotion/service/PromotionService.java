package com.example.promotion.service;

import com.example.promotion.dto.PromotionDTO;

import java.util.List;

public interface PromotionService {

    List<PromotionDTO> getAllPromotions();

    List<PromotionDTO> getActivePromotions();

    PromotionDTO getPromotionByCode(String code);

    PromotionDTO getActivePromotionByCode(String code);

    PromotionDTO createPromotion(PromotionDTO dto);

    PromotionDTO updatePromotion(Long id, PromotionDTO dto);

    void deactivatePromotion(Long id);
}
