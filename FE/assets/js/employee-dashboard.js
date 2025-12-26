// Employee Dashboard - Sales JavaScript
const API_BASE = '/api';

let products = [];
let cart = [];
let selectedCustomer = null;
let currentCategory = 'all';
let currentSearch = '';
let currentSort = 'name';
let customersLoaded = false;

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
    document.getElementById('selectedCustomer').textContent = 'Khách lẻ';
    setupEventListeners();

    document.getElementById('productsGrid').innerHTML =
        '<div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #999;">Đang tải...</div>';

    await Promise.all([loadProducts()]);

    document.getElementById('customerSearch')?.addEventListener('focus', () => {
        if (!customersLoaded) loadCustomers();
    }, { once: true });
});

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

        const customers = await response.json();
        renderCustomers(customers);
        customersLoaded = true;
    } catch (err) {
        console.error('Error loading customers:', err);
    }
}

function renderProducts(filteredProducts = null) {
    const displayProducts = filteredProducts || products;
    const grid = document.getElementById('productsGrid');

    if (!displayProducts || displayProducts.length === 0) {
        grid.innerHTML = '<div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #999;">Không có sản phẩm</div>';
        return;
    }

    grid.innerHTML = displayProducts.map(p => `
        <div class="product-card">
            <div class="product-price-tag">${formatPriceCompact(p.price || 0)}</div>
            <div class="product-image">${PRODUCT_ICON}</div>
            <div class="product-name">${p.name || 'Sản phẩm'}</div>
            <div class="product-sku">${p.code || 'SKU'}</div>
            <button class="product-button" onclick="addToCart(${p.id}, '${p.name}', ${p.price || 0})">
                Thêm vào giỏ
            </button>
        </div>
    `).join('');
}

function renderCustomers(customers) {
    const list = document.getElementById('customerList');
    if (!customers || customers.length === 0) {
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

function addToCart(productId, productName, productPrice) {
    const existingItem = cart.find(item => item.productId === productId);
    const qty = getCurrentQty();

    if (existingItem) {
        existingItem.quantity += qty;
    } else {
        cart.push({
            productId,
            productName,
            productPrice,
            quantity: qty
        });
    }

    renderCart();
    updateTotal();
}

function clearCart(resetCustomer = true) {
    cart = [];
    renderCart();
    updateTotal();
    document.getElementById('discountInput').value = '';
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
        paymentMethod: isPaid ? 'CASH' : null,
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

    if (cart.length === 0) {
        cartContainer.innerHTML = '<div class="empty-cart"><p>Giỏ hàng trống</p></div>';
        toggleEmptyState(true);
        return;
    }

    toggleEmptyState(false);
    cartContainer.innerHTML = cart.map((item, idx) => `
        <div class="cart-item">
            <div class="cart-item-info">
                <div class="cart-item-name">${item.productName}</div>
                <div class="cart-item-price">${formatPrice(item.productPrice)}</div>
                <div class="cart-item-qty">
                    <button class="qty-btn" onclick="updateQty(${idx}, -1)">-</button>
                    <input type="number" class="qty-input" value="${item.quantity}" onchange="setQty(${idx}, this.value)">
                    <button class="qty-btn" onclick="updateQty(${idx}, 1)">+</button>
                </div>
            </div>
            <button class="cart-item-remove" onclick="removeFromCart(${idx})">x</button>
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

    document.getElementById('selectedCustomer').innerHTML = `
        <div>
            <p class="customer-name">${customerName}</p>
            <p class="customer-phone">${customerPhone}</p>
        </div>
    `;
}

function updateTotal() {
    const subtotal = cart.reduce((sum, item) => sum + (item.productPrice * item.quantity), 0);
    const discount = parseInt(document.getElementById('discountInput').value, 10) || 0;
    const total = Math.max(0, subtotal - discount);

    document.getElementById('subtotal').textContent = formatPrice(subtotal);
    document.getElementById('totalAmount').textContent = formatPrice(total);
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

function setupEventListeners() {
    document.getElementById('searchInput').addEventListener('input', (e) => {
        currentSearch = e.target.value;
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

    document.getElementById('discountInput').addEventListener('input', () => {
        updateTotal();
    });

    document.querySelectorAll('.quick-cash .chip').forEach(btn => {
        btn.addEventListener('click', () => {
            document.getElementById('discountInput').value = btn.dataset.cash;
            updateTotal();
        });
    });

    document.getElementById('clearCartBtn').addEventListener('click', () => {
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

function filterProducts(searchTerm = '') {
    const keyword = searchTerm || currentSearch;
    const filtered = products.filter(p => {
        const matchCategory = currentCategory === 'all' || p.categoryId === parseInt(currentCategory, 10);
        const matchSearch = !keyword ||
            (p.name && p.name.toLowerCase().includes(keyword.toLowerCase())) ||
            (p.code && p.code.toLowerCase().includes(keyword.toLowerCase()));
        return matchCategory && matchSearch;
    });

    renderProducts(filtered);
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

function getCurrentQty() {
    const raw = parseInt(document.getElementById('qtyInput').value, 10);
    return Number.isFinite(raw) && raw > 0 ? raw : 1;
}

function toggleEmptyState(isEmpty) {
    const emptyState = document.getElementById('emptyState');
    if (!emptyState) return;
    emptyState.style.display = isEmpty ? 'grid' : 'none';
}
