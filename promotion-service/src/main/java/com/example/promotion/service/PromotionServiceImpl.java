package com.example.promotion.service;

import com.example.promotion.dto.BundleItemDTO;
import com.example.promotion.dto.PromotionDTO;
import com.example.promotion.dto.PromotionTargetDTO;
import com.example.promotion.entity.BundleItem;
import com.example.promotion.entity.Promotion;
import com.example.promotion.entity.PromotionTarget;
import com.example.promotion.repository.PromotionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Transactional
public class PromotionServiceImpl implements PromotionService {

    private static final Logger log = LoggerFactory.getLogger(PromotionServiceImpl.class);

    private final PromotionRepository promotionRepository;
    private final CacheManager cacheManager;
    private final RestTemplate restTemplate;

    @Value("${nifi.promotion.signal-url:}")
    private String nifiSignalUrl;

    public PromotionServiceImpl(
            PromotionRepository promotionRepository,
            CacheManager cacheManager,
            RestTemplateBuilder restTemplateBuilder
    ) {
        this.promotionRepository = promotionRepository;
        this.cacheManager = cacheManager;
        this.restTemplate = restTemplateBuilder.build();
    }

    /* ================== QUERY ================== */

    @Override
    public List<PromotionDTO> getAllPromotions() {
        return promotionRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Cacheable(cacheNames = "activePromotions", key = "'active'")
    public List<PromotionDTO> getActivePromotions() {
        return promotionRepository.findActivePromotions(LocalDateTime.now())
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Cacheable(cacheNames = "promotionByCode", key = "#code", unless = "#result == null")
    public PromotionDTO getPromotionByCode(String code) {
        return promotionRepository.findByCode(code)
                .map(this::toDTO)
                .orElse(null);
    }

    @Override
    @Cacheable(cacheNames = "activePromotionByCode", key = "#code", unless = "#result == null")
    public PromotionDTO getActivePromotionByCode(String code) {
        return promotionRepository.findActivePromotionByCode(code, LocalDateTime.now())
                .map(this::toDTO)
                .orElse(null);
    }

    /* ================== COMMAND ================== */

    @Override
    @CachePut(cacheNames = "promotionByCode", key = "#result.code", unless = "#result == null")
    @CacheEvict(cacheNames = "activePromotions", allEntries = true)
    public PromotionDTO createPromotion(PromotionDTO dto) {
        validatePromotionDTO(dto, null);
        Promotion promotion = new Promotion();
        promotion.setTargets(new ArrayList<>());
        promotion.setBundleItems(new ArrayList<>());

        applyDTOToEntity(dto, promotion);
        PromotionDTO created = toDTO(promotionRepository.save(promotion));
        refreshActivePromotionCache(created);
        emitNifiSignalAfterCommit("PROMOTION_CREATED", created);
        return created;
    }

    @Override
    @CachePut(cacheNames = "promotionByCode", key = "#result.code", unless = "#result == null")
    @CacheEvict(cacheNames = "activePromotions", allEntries = true)
    public PromotionDTO updatePromotion(Long id, PromotionDTO dto) {
        if (id == null) {
            throw new IllegalArgumentException("Promotion id must not be null");
        }
        validatePromotionDTO(dto, id);

        Promotion promotion = promotionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Promotion not found"));
        String previousCode = promotion.getCode();

        if (promotion.getTargets() == null) {
            promotion.setTargets(new ArrayList<>());
        } else {
            promotion.getTargets().clear();
        }

        if (promotion.getBundleItems() == null) {
            promotion.setBundleItems(new ArrayList<>());
        } else {
            promotion.getBundleItems().clear();
        }

        applyDTOToEntity(dto, promotion);
        PromotionDTO updated = toDTO(promotionRepository.save(promotion));
        if (updated != null && previousCode != null && !previousCode.equals(updated.getCode())) {
            evictPromotionByCode(previousCode);
            evictActivePromotionByCode(previousCode);
        }
        refreshActivePromotionCache(updated);
        emitNifiSignalAfterCommit("PROMOTION_UPDATED", updated);
        return updated;
    }

    @Override
    @CacheEvict(cacheNames = "activePromotions", allEntries = true)
    public void deletePromotion(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("Promotion id must not be null");
        }

        Promotion promotion = promotionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Promotion not found"));
        PromotionDTO snapshot = toDTO(promotion);

        promotionRepository.delete(promotion);
        evictPromotionByCode(promotion.getCode());
        evictActivePromotionByCode(promotion.getCode());
        emitNifiSignalAfterCommit("PROMOTION_DELETED", snapshot);
    }

    @Override
    @CacheEvict(cacheNames = "activePromotions", allEntries = true)
    public void deactivatePromotion(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("Promotion id must not be null");
        }

        Promotion promotion = promotionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Promotion not found"));

        promotion.setActive(false);
        promotionRepository.save(promotion);
        evictPromotionByCode(promotion.getCode());
        evictActivePromotionByCode(promotion.getCode());
    }

    /* ================== MAPPING ================== */

    private PromotionDTO toDTO(Promotion promotion) {
        PromotionDTO dto = new PromotionDTO();
        dto.setId(promotion.getId());
        dto.setCode(promotion.getCode());
        dto.setName(promotion.getName());
        dto.setDescription(promotion.getDescription());
        dto.setDiscountType(normalizeDiscountType(promotion));
        dto.setDiscountValue(promotion.getDiscountValue());
        dto.setStartDate(promotion.getStartDate());
        dto.setEndDate(promotion.getEndDate());
        dto.setActive(promotion.getActive());

        try {
            List<PromotionTarget> targets = promotion.getTargets();
            dto.setTargets(
                    targets == null
                            ? Collections.emptyList()
                            : targets.stream()
                                .map(this::toTargetDTO)
                                .collect(Collectors.toList())
            );
        } catch (RuntimeException ex) {
            dto.setTargets(Collections.emptyList());
        }

        try {
            List<BundleItem> bundleItems = promotion.getBundleItems();
            dto.setBundleItems(
                    bundleItems == null
                            ? Collections.emptyList()
                            : bundleItems.stream()
                                .map(this::toBundleItemDTO)
                                .collect(Collectors.toList())
            );
        } catch (RuntimeException ex) {
            dto.setBundleItems(Collections.emptyList());
        }

        return dto;
    }

    private PromotionTargetDTO toTargetDTO(PromotionTarget target) {
        PromotionTargetDTO dto = new PromotionTargetDTO();
        dto.setId(target.getId());
        dto.setTargetType(target.getTargetType());
        dto.setTargetId(target.getTargetId());
        return dto;
    }

    private BundleItemDTO toBundleItemDTO(BundleItem item) {
        BundleItemDTO dto = new BundleItemDTO();
        dto.setId(item.getId());
        dto.setProductId(item.getProductId());
        dto.setQuantity(item.getQuantity());
        return dto;
    }

    private void applyDTOToEntity(PromotionDTO dto, Promotion promotion) {
        promotion.setCode(dto.getCode());
        promotion.setName(dto.getName());
        promotion.setDescription(dto.getDescription());
        if (dto.getDiscountType() != null) {
            promotion.setDiscountType(dto.getDiscountType());
            promotion.setPromotionType(mapPromotionTypeFromDiscount(dto.getDiscountType()));
        }
        promotion.setDiscountValue(dto.getDiscountValue());
        promotion.setStartDate(dto.getStartDate());
        promotion.setEndDate(dto.getEndDate());
        promotion.setActive(dto.getActive() != null ? dto.getActive() : true);

        if (dto.getTargets() != null) {
            if (promotion.getTargets() == null) {
                promotion.setTargets(new ArrayList<>());
            }
            for (PromotionTargetDTO tdto : dto.getTargets()) {
                PromotionTarget target = new PromotionTarget();
                target.setTargetType(tdto.getTargetType());
                target.setTargetId(tdto.getTargetId());
                target.setPromotion(promotion);
                promotion.getTargets().add(target);
            }
        }

        if (dto.getBundleItems() != null) {
            if (promotion.getBundleItems() == null) {
                promotion.setBundleItems(new ArrayList<>());
            }
            for (BundleItemDTO bdto : dto.getBundleItems()) {
                BundleItem item = new BundleItem();
                item.setProductId(bdto.getProductId());
                item.setQuantity(bdto.getQuantity());
                item.setPromotion(promotion);
                promotion.getBundleItems().add(item);
            }
        }
    }

    private void validatePromotionDTO(PromotionDTO dto, Long currentId) {
        if (dto == null) {
            throw new IllegalArgumentException("Promotion payload must not be null");
        }

        String code = dto.getCode() != null ? dto.getCode().trim() : "";
        if (code.isEmpty()) {
            throw new IllegalArgumentException("Promotion code must not be blank");
        }

        String name = dto.getName() != null ? dto.getName().trim() : "";
        if (name.isEmpty()) {
            throw new IllegalArgumentException("Promotion name must not be blank");
        }

        if (dto.getDiscountType() == null) {
            throw new IllegalArgumentException("Discount type must be provided");
        }

        if (dto.getDiscountValue() == null) {
            throw new IllegalArgumentException("Discount value must be provided");
        }

        double value = dto.getDiscountValue();
        if (value < 0) {
            throw new IllegalArgumentException("Discount value must be non-negative");
        }
        if (dto.getDiscountType() == Promotion.DiscountType.PERCENT && (value <= 0 || value > 100)) {
            throw new IllegalArgumentException("Percent discount must be between 1 and 100");
        }

        if (dto.getStartDate() != null && dto.getEndDate() != null
                && dto.getEndDate().isBefore(dto.getStartDate())) {
            throw new IllegalArgumentException("End date must be after start date");
        }

        validateTargets(dto);
        validateBundleItems(dto);

        promotionRepository.findByCode(code)
                .filter(existing -> currentId == null || !existing.getId().equals(currentId))
                .ifPresent(existing -> {
                    throw new IllegalArgumentException("Promotion code already exists");
                });
    }

    private void validateTargets(PromotionDTO dto) {
        if (dto.getTargets() == null) {
            return;
        }
        for (PromotionTargetDTO target : dto.getTargets()) {
            if (target == null) {
                throw new IllegalArgumentException("Promotion target must not be null");
            }
            if (target.getTargetType() == null) {
                throw new IllegalArgumentException("Promotion target type must be provided");
            }
            if (target.getTargetId() == null || target.getTargetId() <= 0) {
                throw new IllegalArgumentException("Promotion target id must be a positive number");
            }
        }
    }

    private void validateBundleItems(PromotionDTO dto) {
        if (dto.getBundleItems() == null) {
            return;
        }
        if (dto.getDiscountType() == Promotion.DiscountType.BUNDLE && dto.getBundleItems().isEmpty()) {
            throw new IllegalArgumentException("Bundle promotions must include at least one bundle item");
        }
        for (BundleItemDTO item : dto.getBundleItems()) {
            if (item == null) {
                throw new IllegalArgumentException("Bundle item must not be null");
            }
            if (item.getProductId() == null || item.getProductId() <= 0) {
                throw new IllegalArgumentException("Bundle item productId must be a positive number");
            }
            if (item.getQuantity() == null || item.getQuantity() <= 0) {
                throw new IllegalArgumentException("Bundle item quantity must be a positive number");
            }
        }
    }

    private Promotion.DiscountType normalizeDiscountType(Promotion promotion) {
        Promotion.DiscountType raw = promotion.getDiscountType();
        String promotionType = promotion.getPromotionType();

        Promotion.DiscountType fromPromotionType = mapPromotionType(promotionType);
        if (fromPromotionType != null) {
            if (raw == null || raw == Promotion.DiscountType.BUNDLE || raw == Promotion.DiscountType.FREE_GIFT
                    || raw == Promotion.DiscountType.FIXED_AMOUNT) {
                return fromPromotionType;
            }
        }

        return mapDiscountType(raw);
    }

    private Promotion.DiscountType mapDiscountType(Promotion.DiscountType raw) {
        if (raw == null) {
            return null;
        }
        return switch (raw) {
            case FIXED_AMOUNT -> Promotion.DiscountType.FIXED;
            case FREE_GIFT -> Promotion.DiscountType.BUNDLE;
            default -> raw;
        };
    }

    private Promotion.DiscountType mapPromotionType(String promotionType) {
        if (promotionType == null || promotionType.isBlank()) {
            return null;
        }
        return switch (promotionType) {
            case "PERCENT" -> Promotion.DiscountType.PERCENT;
            case "FIXED_AMOUNT", "FIXED" -> Promotion.DiscountType.FIXED;
            case "FREE_GIFT", "BUNDLE" -> Promotion.DiscountType.BUNDLE;
            default -> null;
        };
    }

    private String mapPromotionTypeFromDiscount(Promotion.DiscountType discountType) {
        if (discountType == null) {
            return null;
        }
        return switch (discountType) {
            case PERCENT -> "PERCENT";
            case FIXED, FIXED_AMOUNT -> "FIXED_AMOUNT";
            case FREE_GIFT -> "FREE_GIFT";
            case BUNDLE -> "BUNDLE";
        };
    }

    private void evictPromotionByCode(String code) {
        if (code == null || code.isBlank()) {
            return;
        }
        Cache cache = cacheManager.getCache("promotionByCode");
        if (cache != null) {
            cache.evict(code);
        }
    }

    private void evictActivePromotionByCode(String code) {
        if (code == null || code.isBlank()) {
            return;
        }
        Cache cache = cacheManager.getCache("activePromotionByCode");
        if (cache != null) {
            cache.evict(code);
        }
    }

    private void refreshActivePromotionCache(PromotionDTO dto) {
        if (dto == null || dto.getCode() == null || dto.getCode().isBlank()) {
            return;
        }
        Cache cache = cacheManager.getCache("activePromotionByCode");
        if (cache == null) {
            return;
        }
        if (isActiveNow(dto, LocalDateTime.now())) {
            cache.put(dto.getCode(), dto);
        } else {
            cache.evict(dto.getCode());
        }
    }

    private boolean isActiveNow(PromotionDTO dto, LocalDateTime now) {
        if (dto.getActive() != null && !dto.getActive()) {
            return false;
        }
        if (dto.getStartDate() != null && dto.getStartDate().isAfter(now)) {
            return false;
        }
        return dto.getEndDate() == null || !dto.getEndDate().isBefore(now);
    }

    private void emitNifiSignalAfterCommit(String eventType, PromotionDTO dto) {
        if (!isNifiSignalEnabled()) {
            return;
        }
        if (!TransactionSynchronizationManager.isSynchronizationActive()) {
            sendNifiSignal(eventType, dto);
            return;
        }
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                sendNifiSignal(eventType, dto);
            }
        });
    }

    private boolean isNifiSignalEnabled() {
        return nifiSignalUrl != null && !nifiSignalUrl.isBlank();
    }

    private void sendNifiSignal(String eventType, PromotionDTO dto) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("eventType", eventType);
        payload.put("promotion", dto);
        payload.put("timestamp", LocalDateTime.now());

        try {
            restTemplate.postForEntity(nifiSignalUrl, payload, Void.class);
        } catch (Exception ex) {
            log.warn("Failed to send NiFi signal to {}", nifiSignalUrl, ex);
        }
    }
}
