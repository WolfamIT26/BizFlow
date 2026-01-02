// Employee Dashboard - Sales JavaScript
const API_BASE = resolveApiBase();

let products = [];
let cart = [];
let selectedCustomer = null;
let selectedEmployee = null;
let currentCategory = 'all';
let topSearchTerm = '';
let bottomSearchTerm = '';
let currentSort = 'name';
let customersLoaded = false;
let customers = [];
let customerSearchTerm = '';
let currentPaymentMethod = 'CASH';
let employeesLoaded = false;
let employees = [];

const PRODUCT_ICON = `
    <svg viewBox="0 0 24 24" class="icon-svg" aria-hidden="true">
        <path d="M6 8h12l-1.2 11H7.2L6 8Z" />
        <path d="M9 8V6a3 3 0 0 1 6 0v2" />
    </svg>
`;

window.addEventListener('DOMContentLoaded', async () => {
    checkAuth();
    loadUserInfo();
    selectedCustomer = { id: 0, name: 'Khách lẻ', phone: '-' };
    const selectedCustomerLabel = document.getElementById('selectedCustomer');
    if (selectedCustomerLabel) {
        selectedCustomerLabel.textContent = 'Khách lẻ';
    }
    setupEventListeners();
    setupCustomerModal();
    setupProductDetailModal();
    setupCustomerDetailModal();
    setupEmployeeSelector();
    toggleCashPanel(true);

    document.getElementById('productsGrid').innerHTML =
        '<div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #999;">Đang tải...</div>';

    await Promise.all([loadProducts()]);

    const customerSearchInput = document.getElementById('customerSearch');
    customerSearchInput?.addEventListener('focus', () => {
        if (customerSearchInput.classList.contains('has-selection')) {
            return;
        }
        const customerList = document.getElementById('customerList');
        if (customerList) {
            customerList.style.display = 'block';
        }
        if (!customersLoaded) {
            loadCustomers().then(() => applyCustomerFilter());
            return;
        }
        applyCustomerFilter();
    });
});

function resolveApiBase() {
    const configured = window.API_BASE_URL || window.API_BASE;
    if (configured) {
        return configured.replace(/\/$/, '');
    }

    if (window.location.protocol === 'file:') {
        return 'http://localhost:8080/api';
    }

    return `${window.location.origin}/api`;
}

function checkAuth() {
    const token = sessionStorage.getItem('accessToken');
    const role = sessionStorage.getItem('role');

    if (!token || role !== 'EMPLOYEE') {
        window.location.href = '/pages/login.html';
    }
}

function loadUserInfo() {
    const username = sessionStorage.getItem('username');
    const userInitial = (username ? username[0] : 'E').toUpperCase();

    document.getElementById('userInitial').textContent = userInitial;
    document.getElementById('userNameDropdown').textContent = username || 'Nhân viên';
}

async function loadProducts() {
    try {
        const response = await fetch(`${API_BASE}/products`, {
            headers: { 'Authorization': `Bearer ${sessionStorage.getItem('accessToken')}` }
        });

        if (!response.ok) {
            if (response.status === 401) {
                sessionStorage.clear();
                window.location.href = '/pages/login.html';
                return;
            }
            throw new Error('Failed to load products');
        }

        products = await response.json();
        filterProducts();
    } catch (err) {
        console.error('Error loading products:', err);
        renderProducts([]);
    }
}

async function loadCustomers() {
    if (customersLoaded) return;

    try {
        const response = await fetch(`${API_BASE}/customers`, {
            headers: { 'Authorization': `Bearer ${sessionStorage.getItem('accessToken')}` }
        });

        if (!response.ok) {
            if (response.status === 401) {
                sessionStorage.clear();
                window.location.href = '/pages/login.html';
                return;
            }
            throw new Error('Failed to load customers');
        }

        const rawCustomers = await response.json();
        customers = dedupeCustomers(rawCustomers);
        applyCustomerFilter();
        customersLoaded = true;
    } catch (err) {
        console.error('Error loading customers:', err);
    }
}

function renderCustomers(customers) {
    const list = document.getElementById('customerList');
    if (!list) return;

    if (!customers || customers.length === 0) {
        const emptyMessage = customerSearchTerm ? 'Không tìm thấy khách hàng' : 'Chưa có khách hàng';
        list.innerHTML = `<div class="customer-empty">${emptyMessage}</div>`;
        return;
    }

    const customersHtml = customers.map(c => {
        const phone = c.phone || '-';
        const secondary = c.email || c.address || '-';
        return `
        <div class="customer-item" data-customer-id="${c.id}" onclick="selectCustomer(event, ${c.id}, '${c.name}', '${phone}')">
            <div class="customer-info">
                <p class="customer-name">${c.name || 'Khách hàng'}</p>
                <p class="customer-phone">${phone}</p>
            </div>
            <div class="customer-meta">
                <span class="customer-phone">${phone}</span>
                <span class="customer-sub">${secondary}</span>
            </div>
        </div>
        `;
    }).join('');

    list.innerHTML = customersHtml || '<div class="customer-empty">Chưa có khách hàng</div>';
}

function applyCustomerFilter() {
    const keyword = customerSearchTerm.trim().toLowerCase();
    const searchInput = document.getElementById('customerSearch');
    const list = document.getElementById('customerList');
    if (searchInput?.classList.contains('has-selection')) {
        if (list) {
            list.style.display = 'none';
        }
        return;
    }
    if (list) {
        list.style.display = 'block';
    }
    if (!keyword) {
        renderCustomers(getSuggestedCustomers());
        return;
    }

    const filtered = customers.filter(c => {
        const name = (c.name || '').toLowerCase();
        const phone = (c.phone || '').toLowerCase();
        const email = (c.email || '').toLowerCase();
        return name.includes(keyword) || phone.includes(keyword) || email.includes(keyword);
    });

    renderCustomers(filtered);
}

function getSuggestedCustomers() {
    return customers.slice(0, 8);
}

function normalizeCustomerKey(customer) {
    const phone = (customer.phone || '').replace(/\s+/g, '');
    if (phone) return `phone:${phone}`;
    return `id:${customer.id || Math.random()}`;
}

function dedupeCustomers(list) {
    const seen = new Map();
    (list || []).forEach(c => {
        const key = normalizeCustomerKey(c);
        if (!seen.has(key)) {
            seen.set(key, c);
        }
    });
    return Array.from(seen.values());
}

function addToCart(productId, productName, productPrice) {
    const qty = getCurrentQty();
    const splitLine = document.getElementById('splitLine')?.checked;
    const product = products.find(p => p.id === productId) || {};

    if (!splitLine) {
        const existingItem = cart.find(item => item.productId === productId);
        if (existingItem) {
            existingItem.quantity += qty;
        } else {
            cart.push({
                productId,
                productName,
                productPrice,
                quantity: qty,
                productCode: product.code || product.barcode || '',
                unit: product.unit || ''
            });
        }
    } else {
        cart.push({
            productId,
            productName,
            productPrice,
            quantity: qty,
            productCode: product.code || product.barcode || '',
            unit: product.unit || ''
        });
    }

    renderCart();
    updateTotal();
}

function clearCart(resetCustomer = true) {
    cart = [];
    renderCart();
    updateTotal();
    if (resetCustomer) {
        selectedCustomer = { id: 0, name: 'Khách lẻ', phone: '-' };
        document.getElementById('selectedCustomer').textContent = 'Khách lẻ';
    }
}

async function createOrder(isPaid) {
    if (cart.length === 0) {
        alert('Giỏ hàng trống!');
        return;
    }

    const userId = parseInt(sessionStorage.getItem('userId'), 10) || null;
    const customerId = selectedCustomer && selectedCustomer.id > 0 ? selectedCustomer.id : null;
    const payload = {
        userId,
        customerId,
        paid: isPaid,
        paymentMethod: isPaid ? currentPaymentMethod : null,
        items: cart.map(item => ({
            productId: item.productId,
            quantity: item.quantity
        }))
    };

    try {
        const res = await fetch(`${API_BASE}/orders`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${sessionStorage.getItem('accessToken') || ''}`
            },
            body: JSON.stringify(payload)
        });

        if (!res.ok) {
            const message = await res.text();
            alert(message || 'Không thể tạo đơn hàng.');
            return;
        }

        const data = await res.json();
        alert(isPaid ? `Thanh toán thành công. Mã đơn: ${data.orderId}` : `Đã lưu tạm đơn: ${data.orderId}`);
        clearCart(true);
    } catch (err) {
        alert('Lỗi kết nối khi tạo đơn hàng.');
        console.error(err);
    }
}

function renderCart() {
    const cartContainer = document.getElementById('cartItems');
    const emptyState = document.getElementById('emptyState');
    if (cart.length === 0) {
        if (cartContainer) {
            cartContainer.innerHTML = '';
        }
        if (emptyState) {
            emptyState.style.display = 'grid';
        }
        toggleEmptyState(true);
        return;
    }

    toggleEmptyState(false);
    if (emptyState) {
        emptyState.style.display = 'none';
    }
    cartContainer.innerHTML = cart.map((item, idx) => `
        <div class="cart-row">
            <span>${idx + 1}</span>
            <span>${item.productCode || '-'}</span>
            <span class="cart-name">${item.productName}</span>
            <span class="cart-qty">
                <input type="number" class="qty-input" value="${item.quantity}" onchange="setQty(${idx}, this.value)">
            </span>
            <span>${item.unit || '-'}</span>
            <span>${formatPrice(item.productPrice)}</span>
            <span>${formatPrice(item.productPrice * item.quantity)}</span>
            <button class="cart-item-remove" onclick="removeFromCart(${idx})">×</button>
        </div>
    `).join('');
}

function updateQty(idx, change) {
    if (cart[idx]) {
        cart[idx].quantity = Math.max(1, cart[idx].quantity + change);
        renderCart();
        updateTotal();
    }
}

function setQty(idx, value) {
    const qty = parseInt(value, 10) || 1;
    if (cart[idx]) {
        cart[idx].quantity = Math.max(1, qty);
        renderCart();
        updateTotal();
    }
}

function removeFromCart(idx) {
    cart.splice(idx, 1);
    renderCart();
    updateTotal();
}

function selectCustomer(evt, customerId, customerName, customerPhone) {
    selectedCustomer = { id: customerId, name: customerName, phone: customerPhone };

    document.querySelectorAll('.customer-item').forEach(item => {
        item.classList.remove('active');
    });
    const row = evt?.target?.closest('.customer-item');
    if (row) row.classList.add('active');

    const searchInput = document.getElementById('customerSearch');
    if (searchInput) {
        searchInput.value = customerName || customerPhone || '';
        searchInput.classList.add('has-selection');
        searchInput.readOnly = true;
    }

    customerSearchTerm = '';
    const customerList = document.getElementById('customerList');
    if (customerList) {
        customerList.innerHTML = '';
        customerList.style.display = 'none';
    }

    const addBtn = document.getElementById('addCustomerBtn');
    if (addBtn) {
        addBtn.style.display = 'none';
    }
    const clearBtn = document.getElementById('clearCustomerBtn');
    if (clearBtn) {
        clearBtn.style.display = 'inline-flex';
    }

    openCustomerDetail(customerId);
}

function clearSelectedCustomer() {
    selectedCustomer = { id: 0, name: 'Khách lẻ', phone: '-' };
    const selectedView = document.getElementById('selectedCustomer');
    if (selectedView) {
        selectedView.textContent = 'Khách lẻ';
    }

    const searchInput = document.getElementById('customerSearch');
    if (searchInput) {
        searchInput.value = '';
        searchInput.classList.remove('has-selection');
        searchInput.readOnly = false;
    }

    const addBtn = document.getElementById('addCustomerBtn');
    if (addBtn) {
        addBtn.style.display = '';
    }
    const clearBtn = document.getElementById('clearCustomerBtn');
    if (clearBtn) {
        clearBtn.style.display = 'none';
    }

    customerSearchTerm = '';
    const customerList = document.getElementById('customerList');
    if (customerList) {
        customerList.style.display = 'block';
    }
    applyCustomerFilter();
}

function updateTotal() {
    const subtotal = cart.reduce((sum, item) => sum + (item.productPrice * item.quantity), 0);
    const total = Math.max(0, subtotal);

    document.getElementById('subtotal').textContent = formatPrice(subtotal);
    document.getElementById('totalAmount').textContent = formatPrice(total);
    document.getElementById('amountDue').textContent = formatPrice(total);
    updateChangeDue(total);
    setDefaultTierByTotal(total);
}

function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND',
        minimumFractionDigits: 0
    }).format(price).replace('₫', 'đ');
}

function formatPriceCompact(price) {
    return new Intl.NumberFormat('vi-VN', {
        minimumFractionDigits: 0
    }).format(price);
}

function updateChangeDue(forcedTotal = null) {
    const changeLabel = document.getElementById('changeAmount');
    if (!changeLabel) return;

    if (currentPaymentMethod !== 'CASH') {
        changeLabel.textContent = formatPrice(0);
        return;
    }

    const totalAmount = forcedTotal !== null
        ? forcedTotal
        : parseInt(document.getElementById('totalAmount').textContent.replace(/\D/g, ''), 10) || 0;
    const cashReceived = parseInt(document.getElementById('cashReceivedInput')?.value, 10) || 0;
    const change = Math.max(0, cashReceived - totalAmount);
    changeLabel.textContent = formatPrice(change);
}

function toggleCashPanel(show) {
    const panel = document.getElementById('cashPanel');
    if (!panel) return;
    panel.style.display = show ? 'block' : 'none';
}

function setDefaultTierByTotal(total) {
    const tierSelect = document.getElementById('customerTierSelect');
    if (!tierSelect) return;
    if (total >= 1000000) return;
    if (!tierSelect.value) {
        tierSelect.value = 'member';
    }
}

function setTierByPoints(points) {
    const tierSelect = document.getElementById('customerTierSelect');
    if (!tierSelect) return;

    let tier = 'member';
    if (points >= 25000) {
        tier = 'diamond';
    } else if (points >= 15000) {
        tier = 'platinum';
    } else if (points >= 9000) {
        tier = 'gold';
    } else if (points >= 3000) {
        tier = 'silver';
    } else {
        tier = 'member';
    }

    tierSelect.value = tier;
}

function setupEventListeners() {
    document.getElementById('searchInput').addEventListener('input', (e) => {
        topSearchTerm = e.target.value;
        filterProducts();
    });
    document.getElementById('searchInput').addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            handleBarcodeSearch();
        }
    });

    document.getElementById('suggestionSearchInput')?.addEventListener('input', (e) => {
        bottomSearchTerm = e.target.value;
        filterProducts();
    });

    document.getElementById('sortSelect').addEventListener('change', (e) => {
        currentSort = e.target.value;
        sortProducts(currentSort);
    });

    document.getElementById('qtyInput').addEventListener('change', () => {
        const val = getCurrentQty();
        document.getElementById('qtyInput').value = val;
    });

    document.getElementById('cashReceivedInput')?.addEventListener('input', () => {
        updateChangeDue();
    });

    document.querySelectorAll('input[name="paymentMethod"]').forEach(input => {
        input.addEventListener('change', () => {
            currentPaymentMethod = input.value;
            toggleCashPanel(currentPaymentMethod === 'CASH');
            updateChangeDue();
        });
    });

    const customerSearch = document.getElementById('customerSearch');
    const clearCustomerBtn = document.getElementById('clearCustomerBtn');
    clearCustomerBtn?.addEventListener('click', () => {
        clearSelectedCustomer();
    });
    document.addEventListener('click', (e) => {
        const panel = document.querySelector('.customer-panel');
        const customerList = document.getElementById('customerList');
        if (!panel || !customerList) return;
        if (!panel.contains(e.target)) {
            customerList.style.display = 'none';
        }
    });
    customerSearch?.addEventListener('click', () => {
        if (customerSearch.classList.contains('has-selection') && selectedCustomer?.id) {
            openCustomerDetail(selectedCustomer.id);
        }
    });

    customerSearch?.addEventListener('input', (e) => {
        customerSearchTerm = e.target.value || '';
        e.target.classList.remove('has-selection');
        const addBtn = document.getElementById('addCustomerBtn');
        if (addBtn) {
            addBtn.style.display = '';
        }
        const clearBtn = document.getElementById('clearCustomerBtn');
        if (clearBtn) {
            clearBtn.style.display = 'none';
        }
        const customerList = document.getElementById('customerList');
        if (customerList) {
            customerList.style.display = 'block';
        }
        if (!customersLoaded) {
            loadCustomers().then(() => applyCustomerFilter());
            return;
        }
        applyCustomerFilter();
    });

    document.querySelectorAll('.quick-cash .chip').forEach(btn => {
        btn.addEventListener('click', () => {
            const cashInput = document.getElementById('cashReceivedInput');
            if (cashInput) {
                cashInput.value = btn.dataset.cash;
            }
            updateChangeDue();
        });
    });

    const clearCartBtn = document.getElementById('clearCartBtn');
    clearCartBtn?.addEventListener('click', () => {
        if (confirm('Xóa tất cả sản phẩm trong giỏ?')) {
            clearCart(false);
        }
    });

    document.querySelectorAll('.tab-close').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            if (confirm('Xóa toàn bộ đơn hiện tại?')) {
                clearCart(true);
            }
        });
    });

    document.getElementById('saveBillBtn').addEventListener('click', () => {
        createOrder(false);
    });

    document.getElementById('checkoutBtn').addEventListener('click', () => {
        createOrder(true);
    });

    document.getElementById('logoutBtn').addEventListener('click', () => {
        if (confirm('Đăng xuất?')) {
            sessionStorage.clear();
            window.location.href = '/pages/login.html';
        }
    });
}

function setupCustomerModal() {
    const addButton = document.getElementById('addCustomerBtn');
    const modal = document.getElementById('customerModal');
    const closeBtn = document.getElementById('closeCustomerModal');
    const cancelBtn = document.getElementById('cancelCustomerModal');
    const form = document.getElementById('customerForm');
    const pointsInput = document.getElementById('customerPointsInput');

    if (!addButton || !modal || !closeBtn || !form) return;

    addButton.addEventListener('click', () => {
        const searchValue = document.getElementById('customerSearch')?.value.trim();
        const normalized = (searchValue || '').replace(/\s+/g, '');
        if (normalized) {
            const existing = customers.find(c => (c.phone || '').replace(/\s+/g, '') === normalized);
            if (existing) {
                selectCustomer(null, existing.id, existing.name, existing.phone || '-');
                return;
            }
        }
        openCustomerModalWithPhone(searchValue || '');
    });

    closeBtn.addEventListener('click', () => closeCustomerModal());
    cancelBtn?.addEventListener('click', () => closeCustomerModal());

    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            closeCustomerModal();
        }
    });

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        await createCustomerFromForm();
    });

    pointsInput?.addEventListener('input', () => {
        const raw = parseInt(pointsInput.value, 10) || 0;
        setTierByPoints(raw);
    });
}

function setupProductDetailModal() {
    const modal = document.getElementById('productDetailModal');
    if (!modal) return;

    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            closeProductDetail();
        }
    });
}

function setupCustomerDetailModal() {
    const modal = document.getElementById('customerDetailModal');
    const selectedView = document.getElementById('selectedCustomer');
    if (!modal || !selectedView) return;

    selectedView.addEventListener('click', () => {
        if (!selectedCustomer || !selectedCustomer.id) return;
        openCustomerDetail(selectedCustomer.id);
    });

    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            closeCustomerDetail();
        }
    });
}

function openCustomerModalWithPhone(phone) {
    const modal = document.getElementById('customerModal');
    const form = document.getElementById('customerForm');
    if (!modal || !form) return;

    modal.classList.add('show');
    modal.setAttribute('aria-hidden', 'false');
    form.reset();
    const phoneInput = document.getElementById('customerPhoneInput');
    if (phoneInput) {
        phoneInput.value = phone || document.getElementById('customerSearch')?.value.trim() || '';
    }
    const confirmInput = document.getElementById('customerConfirmInput');
    if (confirmInput) {
        confirmInput.checked = false;
    }
    document.getElementById('customerNameInput')?.focus();
}

function closeCustomerModal() {
    const modal = document.getElementById('customerModal');
    if (!modal) return;
    modal.classList.remove('show');
    modal.setAttribute('aria-hidden', 'true');
}

async function createCustomerFromForm() {
    const name = document.getElementById('customerNameInput')?.value.trim();
    const phone = document.getElementById('customerPhoneInput')?.value.trim();
    const email = document.getElementById('customerEmailInput')?.value.trim();
    const address = document.getElementById('customerAddressInput')?.value.trim();
    const confirmed = document.getElementById('customerConfirmInput')?.checked;

    if (!name) {
        alert('Vui lòng nhập tên khách hàng.');
        return;
    }

    const normalizedPhone = (phone || '').replace(/\s+/g, '');
    if (normalizedPhone) {
        const existing = customers.find(c => (c.phone || '').replace(/\s+/g, '') === normalizedPhone);
        if (existing) {
            selectCustomer(null, existing.id, existing.name, existing.phone || '-');
            closeCustomerModal();
            return;
        }
    }

    if (!confirmed) {
        alert('Vui lòng xác nhận thông tin khách hàng.');
        return;
    }

    try {
        const res = await fetch(`${API_BASE}/customers`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${sessionStorage.getItem('accessToken') || ''}`
            },
            body: JSON.stringify({
                name,
                phone: phone || null,
                email: email || null,
                address: address || null
            })
        });

    if (!res.ok) {
        const message = await res.text();
        alert(message || 'Không thể tạo khách hàng.');
        return;
    }

    const created = await res.json();
        customers.unshift(created);
        customersLoaded = true;
        customerSearchTerm = '';
        const searchInput = document.getElementById('customerSearch');
    if (searchInput) searchInput.value = '';
    applyCustomerFilter();
    closeCustomerModal();
    selectCustomer(null, created.id, created.name, created.phone || '-');
    if (searchInput) {
        searchInput.value = created.name || created.phone || '';
        searchInput.classList.add('has-selection');
    }
    } catch (err) {
        console.error(err);
        alert('Lỗi kết nối khi tạo khách hàng.');
    }
}

function filterProducts(searchTerm = '') {
    const explicitKeyword = normalizeKeyword(searchTerm);
    const topKeyword = explicitKeyword || normalizeKeyword(topSearchTerm);
    const bottomKeyword = normalizeKeyword(bottomSearchTerm);

    if (bottomKeyword) {
        const filtered = filterProductList(products, bottomKeyword);
        setSuggestionMode('bottom');
        renderProducts(filtered, 'detailed');
        return;
    }

    if (topKeyword) {
        const filtered = filterProductList(products, topKeyword);
        setSuggestionMode('top');
        renderProducts(filtered, 'compact');
        return;
    }

    setSuggestionMode('default');
    renderProducts(getBestSellerProducts(), 'default');
}

function sortProducts(sortBy) {
    switch (sortBy) {
        case 'name':
            products.sort((a, b) => (a.name || '').localeCompare(b.name || ''));
            break;
        case 'price-low':
            products.sort((a, b) => (a.price || 0) - (b.price || 0));
            break;
        case 'price-high':
            products.sort((a, b) => (b.price || 0) - (a.price || 0));
            break;
        default:
            break;
    }

    filterProducts();
}

function getBestSellerProducts() {
    return [...products]
        .sort((a, b) => (a.id || 0) - (b.id || 0))
        .slice(0, 10);
}

function getCurrentQty() {
    const raw = parseInt(document.getElementById('qtyInput').value, 10);
    return Number.isFinite(raw) && raw > 0 ? raw : 1;
}

function stripDiacritics(value) {
    return value.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
}

function normalizeKeyword(value) {
    return stripDiacritics((value || '').toString().trim().toLowerCase());
}

function escapeForSingleQuote(value) {
    return (value || '').replace(/\\/g, '\\\\').replace(/'/g, "\\'");
}

function filterProductList(list, keyword) {
    return list.filter(p => {
        const matchCategory = currentCategory === 'all' || p.categoryId === parseInt(currentCategory, 10);
        const matchSearch = productMatchesKeyword(p, keyword);
        return matchCategory && matchSearch;
    });
}

function productMatchesKeyword(product, keyword) {
    const normalized = normalizeKeyword(keyword);
    if (!normalized) return true;
    const name = normalizeKeyword(product.name);
    const code = normalizeKeyword(product.code);
    const barcode = normalizeKeyword(product.barcode);
    return name.includes(normalized) || code.includes(normalized) || barcode.includes(normalized);
}

function handleBarcodeSearch() {
    const input = document.getElementById('searchInput');
    if (!input) return;
    const keyword = normalizeKeyword(input.value);
    if (!keyword) return;

    const exactMatch = products.find(p =>
        normalizeKeyword(p.code) === keyword ||
        normalizeKeyword(p.barcode) === keyword
    );
    if (exactMatch) {
        addToCart(exactMatch.id, exactMatch.name, exactMatch.price || 0);
        input.value = '';
        const suggestionInput = document.getElementById('suggestionSearchInput');
        if (suggestionInput) suggestionInput.value = '';
        topSearchTerm = '';
        bottomSearchTerm = '';
        filterProducts();
        return;
    }

    const nameMatch = products.find(p => normalizeKeyword(p.name) === keyword);
    if (nameMatch) {
        addToCart(nameMatch.id, nameMatch.name, nameMatch.price || 0);
        input.value = '';
        const suggestionInput = document.getElementById('suggestionSearchInput');
        if (suggestionInput) suggestionInput.value = '';
        topSearchTerm = '';
        bottomSearchTerm = '';
        filterProducts();
        return;
    }

    filterProducts(keyword);
}

function getStockValue(product) {
    const candidates = [product.stock, product.quantity, product.inventory, product.onHand];
    const found = candidates.find(val => Number.isFinite(Number(val)));
    return Number.isFinite(Number(found)) ? Number(found) : 0;
}

function renderProducts(filteredProducts = null, viewMode = 'default') {
    const displayProducts = filteredProducts || products;
    const grid = document.getElementById('productsGrid');

    if (!displayProducts || displayProducts.length === 0) {
        grid.innerHTML = '<div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #999;">Không có sản phẩm</div>';
        return;
    }

    if (viewMode === 'compact') {
        grid.innerHTML = displayProducts.map(p => `
            <div class="product-card compact" onclick="addToCart(${p.id}, '${p.name}', ${p.price || 0})">
                <div class="product-name">${p.name || 'Sản phẩm'}</div>
                <div class="product-sku">${p.code || p.barcode || 'SKU'}</div>
                <div class="product-stock">Tồn: ${getStockValue(p)}</div>
            </div>
        `).join('');
        return;
    }

    if (viewMode === 'detailed') {
        grid.innerHTML = displayProducts.map(p => `
            <div class="product-card detailed" onclick="addToCart(${p.id}, '${p.name}', ${p.price || 0})">
                <div class="product-price-tag">${formatPriceCompact(p.price || 0)}</div>
                <div class="product-image">${PRODUCT_ICON}</div>
                <div class="product-name">${p.name || 'Sản phẩm'}</div>
                <div class="product-sku">${p.code || p.barcode || 'SKU'}</div>
                <div class="product-meta">
                    <span>${p.unit ? `ĐVT: ${p.unit}` : 'ĐVT: -'}</span>
                    <span>Tồn: ${getStockValue(p)}</span>
                </div>
                <div class="product-description">${p.description || 'Chưa có mô tả'}</div>
            </div>
        `).join('');
        return;
    }

    grid.innerHTML = displayProducts.map(p => `
        <div class="product-card" onclick="addToCart(${p.id}, '${p.name}', ${p.price || 0})">
            <div class="product-price-tag">${formatPriceCompact(p.price || 0)}</div>
            <div class="product-image">${PRODUCT_ICON}</div>
            <div class="product-name">${p.name || 'Sản phẩm'}</div>
            <div class="product-sku">${p.code || 'SKU'}</div>
        </div>
    `).join('');
}

function setSuggestionMode(mode) {
    const title = document.getElementById('suggestionTitle');
    const controls = document.getElementById('suggestionControls');

    if (!controls || !title) return;

    if (mode === 'bottom') {
        controls.style.display = 'flex';
        title.textContent = 'TƯ VẤN BÁN HÀNG';
        return;
    }

    if (mode === 'top') {
        controls.style.display = 'none';
        title.textContent = 'KẾT QUẢ TÌM KIẾM';
        return;
    }

    controls.style.display = 'flex';
    title.textContent = 'SẢN PHẨM BÁN CHẠY';
}

function openProductDetail(productId) {
    const product = products.find(p => p.id === productId);
    if (!product) return;

    const modal = document.getElementById('productDetailModal');
    if (!modal) return;

    document.getElementById('detailProductName').textContent = product.name || 'Sản phẩm';
    document.getElementById('detailProductSku').textContent = product.code || product.barcode || '-';
    document.getElementById('detailProductBarcode').textContent = product.barcode || '-';
    document.getElementById('detailProductUnit').textContent = product.unit || '-';
    document.getElementById('detailProductPrice').textContent = formatPrice(product.price || 0);
    document.getElementById('detailProductStock').textContent = getStockValue(product);
    document.getElementById('detailProductDescription').textContent = product.description || 'Chưa có mô tả';

    const addBtn = document.getElementById('detailAddToCart');
    if (addBtn) {
        addBtn.onclick = () => addToCart(product.id, product.name, product.price || 0);
    }

    modal.classList.add('show');
    modal.setAttribute('aria-hidden', 'false');
}

function closeProductDetail() {
    const modal = document.getElementById('productDetailModal');
    if (!modal) return;
    modal.classList.remove('show');
    modal.setAttribute('aria-hidden', 'true');
}

function openCustomerDetail(customerId) {
    const modal = document.getElementById('customerDetailModal');
    if (!modal) return;

    const customer = customers.find(c => c.id === customerId);
    if (!customer) return;

    document.getElementById('detailCustomerName').textContent = (customer.name || '').toUpperCase();
    const nameCard = document.getElementById('detailCustomerNameCard');
    if (nameCard) {
        nameCard.textContent = customer.name || '-';
    }
    document.getElementById('detailCustomerPhone').textContent = customer.phone || '-';
    document.getElementById('detailCustomerEmail').textContent = customer.email || '-';
    document.getElementById('detailCustomerAddress').textContent = customer.address || '-';

    modal.classList.add('show');
    modal.setAttribute('aria-hidden', 'false');
}

function closeCustomerDetail() {
    const modal = document.getElementById('customerDetailModal');
    if (!modal) return;
    modal.classList.remove('show');
    modal.setAttribute('aria-hidden', 'true');
}

function toggleEmptyState(isEmpty) {
    const emptyState = document.getElementById('emptyState');
    if (!emptyState) return;
    emptyState.style.display = isEmpty ? 'grid' : 'none';
}

function setupEmployeeSelector() {
    const button = document.getElementById('employeeSelector');
    const dropdown = document.getElementById('employeeList');
    
    if (!button || !dropdown) return;

    button.addEventListener('click', (e) => {
        e.stopPropagation();
        const isOpen = dropdown.style.display !== 'none';
        dropdown.style.display = isOpen ? 'none' : 'block';
        
        if (!isOpen && !employeesLoaded) {
            loadEmployees();
        }
    });

    document.addEventListener('click', (e) => {
        if (!dropdown || !button) return;
        if (!button.contains(e.target) && !dropdown.contains(e.target)) {
            dropdown.style.display = 'none';
        }
    });
}

async function loadEmployees() {
    if (employeesLoaded) return;

    const dropdown = document.getElementById('employeeList');
    if (!dropdown) return;

    dropdown.innerHTML = '<div class="employee-empty">Đang tải...</div>';

    try {
        const response = await fetch(`${API_BASE}/users`, {
            headers: { 'Authorization': `Bearer ${sessionStorage.getItem('accessToken')}` }
        });

        if (!response.ok) {
            if (response.status === 401) {
                sessionStorage.clear();
                window.location.href = '/pages/login.html';
                return;
            }
            throw new Error('Failed to load employees');
        }

        const allUsers = await response.json();
        // Filter for users with EMPLOYEE role (exclude ADMIN, OWNER, MANAGER)
        employees = allUsers.filter(u => {
            const userRole = u.role ? (typeof u.role === 'string' ? u.role : u.role.name || '') : '';
            return userRole === 'EMPLOYEE';
        });
        employeesLoaded = true;
        renderEmployees();
    } catch (err) {
        console.error('Error loading employees:', err);
        dropdown.innerHTML = '<div class="employee-empty">Lỗi tải danh sách nhân viên</div>';
    }
}

function renderEmployees() {
    const dropdown = document.getElementById('employeeList');
    if (!dropdown) return;

    if (!employees || employees.length === 0) {
        dropdown.innerHTML = '<div class="employee-empty">Chưa có nhân viên</div>';
        return;
    }

    const employeesHtml = employees.map(emp => {
        const roleDisplay = emp.role ? (typeof emp.role === 'object' && emp.role.displayName ? emp.role.displayName : 'Nhân viên') : 'Nhân viên';
        return `
        <div class="employee-item" data-employee-id="${emp.id}" onclick="selectEmployee(event, ${emp.id}, '${emp.username.replace(/'/g, "\\'")}', '${(emp.fullName || emp.username).replace(/'/g, "\\'")}')">
            <div class="employee-info">
                <p class="employee-name">${emp.fullName || emp.username}</p>
                <p class="employee-role">${roleDisplay}</p>
            </div>
        </div>
        `;
    }).join('');

    dropdown.innerHTML = employeesHtml || '<div class="employee-empty">Chưa có nhân viên</div>';
}

function selectEmployee(evt, employeeId, employeeUsername, employeeName) {
    selectedEmployee = { id: employeeId, username: employeeUsername, name: employeeName };

    const button = document.getElementById('employeeSelector');
    if (button) {
        const nameSpan = button.querySelector('span:not(.chip-caret)');
        if (nameSpan) {
            nameSpan.textContent = employeeName || employeeUsername;
        }
    }

    const dropdown = document.getElementById('employeeList');
    if (dropdown) {
        dropdown.style.display = 'none';
    }

    document.querySelectorAll('.employee-item').forEach(item => {
        item.classList.remove('active');
    });
    const row = evt?.target?.closest('.employee-item');
    if (row) row.classList.add('active');
}
