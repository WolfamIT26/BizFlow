package com.example.promotion.controller;

import com.example.promotion.dto.PromotionDTO;
import com.example.promotion.service.PromotionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;

@RestController
@RequestMapping("/api/v1/promotions")
public class PromotionController {

    private final PromotionService promotionService;

    public PromotionController(PromotionService promotionService) {
        this.promotionService = promotionService;
    }

    // GET /api/v1/promotions
    @GetMapping
    public ResponseEntity<List<PromotionDTO>> getAllPromotions() {
        try {
            return ResponseEntity.ok(promotionService.getAllPromotions());
        } catch (RuntimeException ex) {
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    // GET /api/v1/promotions/active
    @GetMapping("/active")
    public ResponseEntity<List<PromotionDTO>> getActivePromotions() {
        try {
            return ResponseEntity.ok(promotionService.getActivePromotions());
        } catch (RuntimeException ex) {
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    // GET /api/v1/promotions/code/{code}
    @GetMapping("/code/{code}")
    public ResponseEntity<PromotionDTO> getByCode(@PathVariable String code) {
        PromotionDTO dto = promotionService.getPromotionByCode(code);
        return dto != null
                ? ResponseEntity.ok(dto)
                : ResponseEntity.notFound().build();
    }

    // POST /api/v1/promotions
    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<PromotionDTO> createPromotion(@RequestBody PromotionDTO dto) {
        PromotionDTO created = promotionService.createPromotion(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // PUT /api/v1/promotions/{id}
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<PromotionDTO> updatePromotion(
            @PathVariable Long id,
            @RequestBody PromotionDTO dto
    ) {
        PromotionDTO updated = promotionService.updatePromotion(id, dto);
        return ResponseEntity.ok(updated);
    }

    // DELETE /api/v1/promotions/{id}
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<Void> deletePromotion(
            @PathVariable Long id
    ) {
        promotionService.deletePromotion(id);
        return ResponseEntity.noContent().build();
    }

    // PATCH /api/v1/promotions/{id}/deactivate
    @PatchMapping("/{id}/deactivate")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<Void> deactivatePromotion(@PathVariable Long id) {
        promotionService.deactivatePromotion(id);
        return ResponseEntity.noContent().build();
    }

    // POST /api/v1/promotions/sync
    @PostMapping("/sync")
    public ResponseEntity<?> syncPromotion(@RequestBody PromotionDTO dto) {
        return ResponseEntity.ok(promotionService.createPromotion(dto));
    }

    // GET /api/v1/promotions/validate/{code}
    @GetMapping("/validate/{code}")
    public ResponseEntity<PromotionDTO> validateCode(@PathVariable String code) {
        PromotionDTO promo = promotionService.getActivePromotionByCode(code);
        return (promo != null) ? ResponseEntity.ok(promo) : ResponseEntity.notFound().build();
    }
}
