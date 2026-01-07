const API_BASE = resolveApiBase();
let invoices = [];

window.addEventListener('DOMContentLoaded', () => {
    checkAuth();
    loadUserInfo();
    ensureHeaderActions();
    setupActions();
    setupAppMenuModal();
    setupLogout();
    loadInvoices();
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

    const initialEl = document.getElementById('userInitial');
    if (initialEl) initialEl.textContent = userInitial;
    const nameEl = document.getElementById('userName');
    if (nameEl) nameEl.textContent = username || 'Nhân viên';
}

function setupActions() {
    document.getElementById('backToPos')?.addEventListener('click', () => {
        window.location.href = '/pages/employee-dashboard.html';
    });

    const logo = document.getElementById('goPosFromLogo') || document.querySelector('.logo-mark');
    logo?.addEventListener('click', () => {
        window.location.href = '/pages/employee-dashboard.html';
    });

    document.getElementById('invoiceSearch')?.addEventListener('input', applyFilters);
    document.getElementById('statusFilter')?.addEventListener('change', applyFilters);
}

function ensureHeaderActions() {
    const headerActions = document.querySelector('.header-actions');
    if (!headerActions) return;

    if (!document.getElementById('logoutBtn')) {
        const logoutBtn = document.createElement('button');
        logoutBtn.id = 'logoutBtn';
        logoutBtn.className = 'icon-btn';
        logoutBtn.title = 'Đăng xuất';
        logoutBtn.setAttribute('aria-label', 'Đăng xuất');
        logoutBtn.innerHTML = `
            <svg viewBox="0 0 24 24" class="icon-svg" aria-hidden="true">
                <path d="M10 6H5v12h5" />
                <path d="M14 16l4-4-4-4" />
                <path d="M18 12H9" />
            </svg>
        `;
        headerActions.appendChild(logoutBtn);
    }

    if (!document.getElementById('appMenuBtn')) {
        const appMenuBtn = document.createElement('button');
        appMenuBtn.id = 'appMenuBtn';
        appMenuBtn.className = 'icon-btn';
        appMenuBtn.title = 'Ứng dụng';
        appMenuBtn.setAttribute('aria-label', 'Ứng dụng');
        appMenuBtn.innerHTML = `
            <svg viewBox="0 0 24 24" class="icon-svg" aria-hidden="true">
                <circle cx="6" cy="6" r="1.5" />
                <circle cx="12" cy="6" r="1.5" />
                <circle cx="18" cy="6" r="1.5" />
                <circle cx="6" cy="12" r="1.5" />
                <circle cx="12" cy="12" r="1.5" />
                <circle cx="18" cy="12" r="1.5" />
            </svg>
        `;
        headerActions.appendChild(appMenuBtn);
    }
}

function setupAppMenuModal() {
    ensureAppMenuModal();
    const modal = document.getElementById('appMenuModal');
    const openBtn = document.getElementById('appMenuBtn');
    const closeBtn = document.getElementById('closeAppMenu');
    if (!modal || !openBtn || !closeBtn) return;

    openBtn.addEventListener('click', () => {
        modal.classList.add('show');
        modal.setAttribute('aria-hidden', 'false');
    });

    closeBtn.addEventListener('click', () => {
        modal.classList.remove('show');
        modal.setAttribute('aria-hidden', 'true');
    });

    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.classList.remove('show');
            modal.setAttribute('aria-hidden', 'true');
        }
    });

    const grid = modal.querySelector('.app-menu-grid');
    grid?.addEventListener('click', (e) => {
        const tile = e.target.closest('.app-tile[data-app]');
        if (!tile) return;
        const target = tile.dataset.app;
        if (target === 'pos') {
            window.location.href = '/pages/employee-dashboard.html';
        } else if (target === 'invoices') {
            window.location.href = '/pages/invoice-list.html';
        }
    });
}

function ensureAppMenuModal() {
    if (document.getElementById('appMenuModal')) return;
    const modal = document.createElement('div');
    modal.className = 'modal side';
    modal.id = 'appMenuModal';
    modal.setAttribute('aria-hidden', 'true');
    modal.innerHTML = `
        <div class="modal-content app-menu">
            <div class="modal-header">
                <h3>Ứng dụng</h3>
                <button id="closeAppMenu" class="icon-btn small" type="button" aria-label="Đóng">×</button>
            </div>
            <div class="app-menu-grid">
                <button class="app-tile" data-app="pos">
                    <span class="app-icon app-blue">BH</span>
                    <span>Bán hàng</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-purple">ĐH</span>
                    <span>Đơn hàng</span>
                </button>
                <button class="app-tile" data-app="invoices">
                    <span class="app-icon app-pink">HD</span>
                    <span>DS hóa đơn</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-green">ON</span>
                    <span>Đơn hàng online</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-orange">ĐR</span>
                    <span>Đổi trả hàng</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-cyan">YC</span>
                    <span>YC điều chuyển</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-green">NT</span>
                    <span>Nạp tiền TT</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-indigo">TC</span>
                    <span>Thu chi</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-blue">MH</span>
                    <span>Màn hình phụ</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-orange">IN</span>
                    <span>Máy in - Mẫu in</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-teal">BC</span>
                    <span>Báo cáo theo ngày</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-gray">NK</span>
                    <span>Nhật ký truy cập</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-indigo">QL</span>
                    <span>Trang quản lý</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-blue">TH</span>
                    <span>Thiết lập hiển thị</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-pink">MT</span>
                    <span>HĐĐT từ MTT</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-purple">HD</span>
                    <span>Hướng dẫn</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-cyan">GY</span>
                    <span>Góp ý cải tiến</span>
                </button>
                <button class="app-tile">
                    <span class="app-icon app-orange">GT</span>
                    <span>Giới thiệu</span>
                </button>
            </div>
        </div>
    `;
    document.body.appendChild(modal);
}

function setupLogout() {
    document.getElementById('logoutBtn')?.addEventListener('click', () => {
        if (confirm('Đăng xuất?')) {
            sessionStorage.clear();
            window.location.href = '/pages/login.html';
        }
    });
}

async function loadInvoices() {
    const listEl = document.getElementById('invoiceList');
    const emptyEl = document.getElementById('invoiceEmpty');
    if (listEl) {
        listEl.innerHTML = '<div class="invoice-row"><span>Đang tải...</span></div>';
    }

    try {
        const response = await fetch(`${API_BASE}/orders/summary`, {
            headers: { 'Authorization': `Bearer ${sessionStorage.getItem('accessToken') || ''}` }
        });

        if (!response.ok) {
            if (response.status === 401) {
                sessionStorage.clear();
                window.location.href = '/pages/login.html';
                return;
            }
            throw new Error('Không tải được danh sách hóa đơn');
        }

        invoices = await response.json();
        renderInvoices(invoices || []);
    } catch (err) {
        console.error('Error loading invoices', err);
        if (listEl) listEl.innerHTML = '';
        if (emptyEl) {
            emptyEl.textContent = 'Không thể tải dữ liệu hóa đơn';
            emptyEl.style.display = 'block';
        }
    }
}

function applyFilters() {
    const keyword = (document.getElementById('invoiceSearch')?.value || '').trim().toLowerCase();
    const status = document.getElementById('statusFilter')?.value || 'all';

    const filtered = (invoices || []).filter(inv => {
        const matchesStatus = status === 'all' || inv.status === status;
        if (!matchesStatus) return false;

        if (!keyword) return true;
        const invoiceNumber = (inv.invoiceNumber || '').toLowerCase();
        const customerName = (inv.customerName || '').toLowerCase();
        const customerPhone = (inv.customerPhone || '').toLowerCase();
        const cashierName = (inv.cashierName || inv.userName || '').toLowerCase();
        return invoiceNumber.includes(keyword)
            || customerName.includes(keyword)
            || customerPhone.includes(keyword)
            || cashierName.includes(keyword);
    });

    renderInvoices(filtered);
}

function renderInvoices(list) {
    const listEl = document.getElementById('invoiceList');
    const emptyEl = document.getElementById('invoiceEmpty');
    const countEl = document.getElementById('invoiceCount');
    const totalEl = document.getElementById('invoiceTotal');

    if (!listEl || !emptyEl) return;

    if (!list || list.length === 0) {
        listEl.innerHTML = '';
        emptyEl.style.display = 'block';
        if (countEl) countEl.textContent = '0';
        if (totalEl) totalEl.textContent = formatPrice(0);
        return;
    }

    emptyEl.style.display = 'none';

    const total = list.reduce((sum, inv) => sum + (Number(inv.totalAmount) || 0), 0);
    if (countEl) countEl.textContent = String(list.length);
    if (totalEl) totalEl.textContent = formatPrice(total);

    listEl.innerHTML = list.map(inv => {
        const createdAt = formatDate(inv.createdAt);
        const customerName = inv.customerName || 'Khách lẻ';
        const customerPhone = inv.customerPhone || '-';
        const itemCount = inv.itemCount || 0;
        const statusInfo = mapStatus(inv.status);

        const invoiceCode = inv.invoiceNumber || inv.orderCode || inv.code || (inv.id ? `HD-${inv.id}` : '-');
        return `
            <div class="invoice-row">
                <span>${escapeHtml(invoiceCode)}</span>
                <span>${createdAt}</span>
                <span class="invoice-customer">
                    <strong>${escapeHtml(customerName)}</strong>
                    <span>${escapeHtml(customerPhone)}</span>
                </span>
                <span>${itemCount}</span>
                <span>${formatPrice(inv.totalAmount || 0)}</span>
                <span><span class="status-badge ${statusInfo.className}">${statusInfo.label}</span></span>
            </div>
        `;
    }).join('');
}

function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND',
        minimumFractionDigits: 0
    }).format(price).replace('₫', 'đ');
}

function formatDate(value) {
    if (!value) return '-';
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return '-';
    return date.toLocaleString('vi-VN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function mapStatus(status) {
    switch (status) {
        case 'PAID':
            return { label: 'Đã thanh toán', className: 'status-paid' };
        case 'RETURNED':
            return { label: 'Đổi trả', className: 'status-returned' };
        case 'UNPAID':
            return { label: 'Chưa thanh toán', className: 'status-unpaid' };
        default:
            return { label: status || 'Không rõ', className: 'status-unpaid' };
    }
}

function escapeHtml(value) {
    return String(value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}
