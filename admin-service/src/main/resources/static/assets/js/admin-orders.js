const ADMIN_API_BASE = window.location.pathname.startsWith('/admin/') ? '/admin' : '';
const apiEndpoints = {
    orders: `${ADMIN_API_BASE}/api/admin/orders`,
    branches: `${ADMIN_API_BASE}/api/dashboard/branches`
};

let allOrders = [];

window.addEventListener('load', () => {
    enforceAuth();
    renderHeader();
    wireOrderFilters();
    loadBranches();
    loadOrders();
});

function enforceAuth() {
    const token = getToken() || localStorage.getItem('accessToken');
    const roleRaw = sessionStorage.getItem('role') || localStorage.getItem('role');
    const role = normalizeRole(roleRaw);
    if (!token) {
        window.location.href = '/pages/login.html';
        return;
    }
    sessionStorage.setItem('accessToken', token);
    if (role) {
        sessionStorage.setItem('role', role);
    }
    if (role !== 'ADMIN') {
        if (role === 'OWNER') {
            window.location.href = '/pages/owner-dashboard.html';
        } else {
            window.location.href = '/pages/employee-dashboard.html';
        }
    }
}

function renderHeader() {
    const username = sessionStorage.getItem('username') || 'Admin';
    document.getElementById('userGreeting').textContent = username;
    document.getElementById('userAvatar').textContent = initials(username);
    document.getElementById('sidebarTime').textContent = new Date().toLocaleString('vi-VN', { hour12: false });
}

async function loadBranches() {
    const select = document.getElementById('branchFilter');
    if (!select) {
        return;
    }
    try {
        const response = await fetch(apiEndpoints.branches, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        if (!response.ok) {
            throw new Error('Không thể tải chi nhánh');
        }
        const branches = await response.json();
        const list = Array.isArray(branches) ? branches : [];
        list.forEach(branch => {
            const option = document.createElement('option');
            option.value = branch.id;
            option.textContent = branch.name || `Chi nhánh #${branch.id}`;
            select.appendChild(option);
        });
    } catch (error) {
        select.disabled = true;
    }
}

async function loadOrders() {
    const meta = document.getElementById('orderMeta');
    try {
        const branchId = document.getElementById('branchFilter')?.value || '';
        const url = new URL(apiEndpoints.orders, window.location.origin);
        if (branchId) {
            url.searchParams.set('branchId', branchId);
        }
        const response = await fetch(url.toString(), {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        if (!response.ok) {
            throw new Error('Không thể tải đơn hàng');
        }
        const orders = await response.json();
        allOrders = Array.isArray(orders) ? orders : [];
        applyOrderFilters();
        if (meta) {
            meta.textContent = `Tổng ${allOrders.length} đơn hàng.`;
        }
    } catch (error) {
        if (meta) {
            meta.textContent = 'Không thể tải dữ liệu đơn hàng.';
        }
        renderOrderRows([]);
    }
}

function wireOrderFilters() {
    const searchInput = document.getElementById('orderSearchInput');
    const branchFilter = document.getElementById('branchFilter');
    const clearBtn = document.getElementById('clearOrderFilterBtn');
    const tbody = document.getElementById('orderTableBody');

    searchInput?.addEventListener('input', applyOrderFilters);
    branchFilter?.addEventListener('change', () => {
        loadOrders();
    });
    clearBtn?.addEventListener('click', () => {
        if (searchInput) searchInput.value = '';
        if (branchFilter) branchFilter.value = '';
        loadOrders();
    });

    tbody?.addEventListener('click', (event) => {
        const button = event.target.closest('button');
        if (!button) return;
        const id = button.dataset.id;
        if (button.dataset.action === 'view') {
            openOrderDetail(id);
        }
    });
}

function applyOrderFilters() {
    const searchInput = document.getElementById('orderSearchInput');
    const meta = document.getElementById('orderMeta');
    const keyword = normalizeKeyword(searchInput?.value || '');

    const filtered = allOrders.filter(order => {
        if (!keyword) return true;
        const combined = normalizeKeyword([
            order.invoiceNumber,
            order.customerName,
            order.customerPhone,
            order.userName,
            order.branchName,
            order.id
        ].join(' '));
        return combined.includes(keyword);
    });

    if (meta) {
        if (!keyword) {
            meta.textContent = `Tổng ${allOrders.length} đơn hàng.`;
        } else {
            meta.textContent = `Tìm thấy ${filtered.length} đơn hàng phù hợp.`;
        }
    }
    renderOrderRows(filtered);
}

function renderOrderRows(list) {
    const tbody = document.getElementById('orderTableBody');
    if (!tbody) return;
    if (!list.length) {
        tbody.innerHTML = '<tr><td colspan="7" class="empty-box">Không có đơn hàng phù hợp.</td></tr>';
        return;
    }
    tbody.innerHTML = list.map(order => {
        const branchName = order.branchName || '-';
        const customerName = order.customerName || order.customerPhone || '-';
        const total = formatNumber(order.totalAmount);
        const status = order.status || '-';
        const date = formatTimestamp(order.createdAt);
        return `
            <tr>
                <td>${escapeHtml(order.invoiceNumber || order.id || '-')}</td>
                <td>${escapeHtml(branchName)}</td>
                <td>${escapeHtml(customerName)}</td>
                <td>${total}</td>
                <td>${escapeHtml(status)}</td>
                <td>${date}</td>
                <td class="actions">
                    <button class="action-btn" data-action="view" data-id="${order.id}">Xem</button>
                </td>
            </tr>
        `;
    }).join('');
}

async function openOrderDetail(id) {
    const modal = document.getElementById('orderDetailModal');
    const grid = document.getElementById('orderDetailGrid');
    const itemsBody = document.getElementById('orderItemsBody');
    if (!id) return;

    grid.innerHTML = '';
    itemsBody.innerHTML = '<tr><td colspan="4" class="empty-box">Đang tải...</td></tr>';
    try {
        const viewer = sessionStorage.getItem('username') || 'Admin';
        const url = new URL(`${apiEndpoints.orders}/${id}`, window.location.origin);
        url.searchParams.set('viewer', viewer);
        const response = await fetch(url.toString(), {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        if (!response.ok) {
            throw new Error('Không thể tải chi tiết');
        }
        const detail = await response.json();
        grid.innerHTML = `
            <div class="detail-item">
                <div class="detail-label">Mã đơn</div>
                <div class="detail-value">${escapeHtml(detail.invoiceNumber || detail.id || '-')}</div>
            </div>
            <div class="detail-item">
                <div class="detail-label">Chi nhánh</div>
                <div class="detail-value">${escapeHtml(detail.branchName || '-')}</div>
            </div>
            <div class="detail-item">
                <div class="detail-label">Khách hàng</div>
                <div class="detail-value">${escapeHtml(detail.customerName || detail.customerPhone || '-')}</div>
            </div>
            <div class="detail-item">
                <div class="detail-label">Tổng tiền</div>
                <div class="detail-value">${formatNumber(detail.totalAmount)}</div>
            </div>
            <div class="detail-item">
                <div class="detail-label">Trạng thái</div>
                <div class="detail-value">${escapeHtml(detail.status || '-')}</div>
            </div>
            <div class="detail-item">
                <div class="detail-label">Ngày tạo</div>
                <div class="detail-value">${formatTimestamp(detail.createdAt)}</div>
            </div>
            <div class="detail-item">
                <div class="detail-label">Ghi chú</div>
                <div class="detail-value">${escapeHtml(detail.note || '-')}</div>
            </div>
        `;

        if (!detail.items || !detail.items.length) {
            itemsBody.innerHTML = '<tr><td colspan="4" class="empty-box">Không có sản phẩm.</td></tr>';
        } else {
            itemsBody.innerHTML = detail.items.map(item => `
                <tr>
                    <td>${escapeHtml(item.productName || '-')}</td>
                    <td>${item.quantity ?? '-'}</td>
                    <td>${formatNumber(item.price)}</td>
                    <td>${formatNumber(item.lineTotal)}</td>
                </tr>
            `).join('');
        }
    } catch (error) {
        itemsBody.innerHTML = '<tr><td colspan="4" class="empty-box">Không thể tải chi tiết.</td></tr>';
    }

    modal.classList.add('show');
    modal.setAttribute('aria-hidden', 'false');
}

function closeOrderDetail() {
    const modal = document.getElementById('orderDetailModal');
    modal.classList.remove('show');
    modal.setAttribute('aria-hidden', 'true');
}

function logout() {
    if (confirm('Bạn có chắc muốn đăng xuất?')) {
        sessionStorage.clear();
        window.location.href = '/pages/login.html';
    }
}

function normalizeKeyword(value) {
    return (value || '')
        .toString()
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '');
}

function normalizeRole(role) {
    if (!role) {
        return '';
    }
    return role.startsWith('ROLE_') ? role.slice(5) : role;
}

function initials(name) {
    return name.split(' ').map(part => part[0]).join('').slice(0, 2).toUpperCase() || 'AD';
}

function getToken() {
    return sessionStorage.getItem('accessToken') || localStorage.getItem('accessToken') || '';
}

function formatNumber(value) {
    if (value === null || value === undefined) {
        return '--';
    }
    return new Intl.NumberFormat('vi-VN').format(value);
}

function formatTimestamp(value) {
    if (!value) {
        return '--';
    }
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) {
        return value;
    }
    return parsed.toLocaleString('vi-VN', { hour12: false });
}

function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, match => ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;'
    }[match]));
}
