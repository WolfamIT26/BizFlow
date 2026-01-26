const ADMIN_API_BASE = window.location.pathname.startsWith('/admin/') ? '/admin' : '';
const apiEndpoints = {
    users: `${ADMIN_API_BASE}/api/users`
};

const ROLE_PREFIX = 'ROLE_';
let allUsers = [];
let filteredUsers = [];

window.addEventListener('load', () => {
    enforceAuth();
    renderHeader();
    wireUserSearch();
    loadUsers();
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

function renderUserRows(list) {
    const tbody = document.getElementById('userTableBody');
    if (!tbody) return;
    if (!list.length) {
        tbody.innerHTML = '<tr><td colspan="4" class="empty-box">Không tìm thấy chủ cửa hàng.</td></tr>';
        return;
    }

    tbody.innerHTML = list.map(user => {
        const name = user.fullName || user.username || '-';
        const email = user.email || '-';
        const phone = user.phoneNumber || '-';
        const status = user.enabled === false ? 'Ngừng' : 'Hoạt động';
        return `
            <tr>
                <td>
                    <strong>${escapeHtml(name)}</strong><br>
                    <span class="card-subtitle">${escapeHtml(user.username || '-')}</span>
                </td>
                <td>${escapeHtml(email)}<br><span class="card-subtitle">${escapeHtml(phone)}</span></td>
                <td>${status}</td>
                <td class="actions">
                    <button class="action-btn" data-action="view" data-id="${user.id}">Xem</button>
                    <button class="action-btn" data-action="edit" data-id="${user.id}">Sửa</button>
                    <button class="action-btn" data-action="toggle" data-id="${user.id}">${user.enabled === false ? "Kích hoạt" : "Ngừng"}</button>
                    <button class="action-btn danger" data-action="delete" data-id="${user.id}">Xóa</button>
                </td>
            </tr>
        `;
    }).join('');
}

async function loadUsers() {
    const meta = document.getElementById('userSearchMeta');
    try {
        const response = await fetch(apiEndpoints.users, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        if (!response.ok) {
            throw new Error('Không thể tải danh sách người dùng.');
        }
        const users = await response.json();
        const list = Array.isArray(users) ? users : [];
        allUsers = list;
        applyUserFilters();
        if (meta) {
            meta.textContent = `Tổng ${allUsers.length} người dùng đã đăng ký.`;
        }
    } catch (error) {
        if (meta) {
            meta.textContent = 'Không thể tải danh sách người dùng.';
        }
        renderUserRows([]);
    }
}

function wireUserSearch() {
    const input = document.getElementById('userSearchInput');
    const statusFilter = document.getElementById('userStatusFilter');
    const clearBtn = document.getElementById('clearUserSearchBtn');
    const tbody = document.getElementById('userTableBody');

    input?.addEventListener('input', applyUserFilters);
    statusFilter?.addEventListener('change', applyUserFilters);
    clearBtn?.addEventListener('click', () => {
        if (input) input.value = '';
        if (statusFilter) statusFilter.value = 'all';
        applyUserFilters();
    });

    tbody?.addEventListener('click', async (event) => {
        const button = event.target.closest('button');
        if (!button) return;
        const action = button.dataset.action;
        const id = button.dataset.id;
        const user = allUsers.find(u => String(u.id) === String(id));
        if (!user) return;

        if (action === 'view') {
            openUserDetail(user);
        }
        if (action === 'edit') {
            openEditUser(user);
        }
        if (action === 'toggle') {
            const token = getToken();
            const endpoint = user.enabled === false ? 'enable' : 'disable';
            try {
                await fetch(`${apiEndpoints.users}/${id}/${endpoint}`, {
                    method: 'PATCH',
                    headers: { 'Authorization': `Bearer ${token}` }
                });
                await loadUsers();
            } catch (error) {
                alert('Không thể cập nhật trạng thái tài khoản.');
            }
        }
        if (action === 'delete') {
            if (!confirm('Bạn có chắc muốn xóa tài khoản này?')) return;
            try {
                const token = getToken();
                await fetch(`${apiEndpoints.users}/${id}`, {
                    method: 'DELETE',
                    headers: { 'Authorization': `Bearer ${token}` }
                });
                await loadUsers();
            } catch (error) {
                alert('Không thể xóa tài khoản.');
            }
        }
    });
}

function applyUserFilters() {
    const input = document.getElementById('userSearchInput');
    const statusFilter = document.getElementById('userStatusFilter');
    const meta = document.getElementById('userSearchMeta');
    const keyword = normalizeKeyword(input?.value || '');
    const statusValue = statusFilter?.value || 'all';

    filteredUsers = allUsers.filter(user => {
        if (statusValue === 'active' && user.enabled === false) return false;
        if (statusValue === 'inactive' && user.enabled !== false) return false;
        if (!keyword) return true;
        const combined = normalizeKeyword([
            user.fullName,
            user.username,
            user.email,
            user.phoneNumber,
            user.id
        ].join(' '));
        return combined.includes(keyword);
    });

    if (meta) {
        if (!keyword && statusValue === 'all') {
            meta.textContent = `Tổng ${allUsers.length} người dùng đã đăng ký.`;
        } else {
            meta.textContent = `Tìm thấy ${filteredUsers.length} người dùng phù hợp.`;
        }
    }
    renderUserRows(filteredUsers);
}

function openUserDetail(user) {
    const modal = document.getElementById('userDetailModal');
    const grid = document.getElementById('userDetailGrid');
    grid.innerHTML = `
        <div class="detail-item">
            <div class="detail-label">Họ tên</div>
            <div class="detail-value">${escapeHtml(user.fullName || '-')}</div>
        </div>
        <div class="detail-item">
            <div class="detail-label">Username</div>
            <div class="detail-value">${escapeHtml(user.username || '-')}</div>
        </div>
        <div class="detail-item">
            <div class="detail-label">Email</div>
            <div class="detail-value">${escapeHtml(user.email || '-')}</div>
        </div>
        <div class="detail-item">
            <div class="detail-label">SĐT</div>
            <div class="detail-value">${escapeHtml(user.phoneNumber || '-')}</div>
        </div>
        <div class="detail-item">
            <div class="detail-label">Vai trò</div>
            <div class="detail-value">${escapeHtml(extractRole(user.role) || '-')}</div>
        </div>
        <div class="detail-item">
            <div class="detail-label">Trạng thái</div>
            <div class="detail-value">${user.enabled === false ? 'Ngừng kích hoạt' : 'Đang hoạt động'}</div>
        </div>
    `;
    modal.classList.add('show');
    modal.setAttribute('aria-hidden', 'false');
}

function closeUserDetail() {
    const modal = document.getElementById('userDetailModal');
    modal.classList.remove('show');
    modal.setAttribute('aria-hidden', 'true');
}

function openEditUser(user) {
    const modal = document.getElementById('editUserModal');
    document.getElementById('editUsername').value = user.username || '';
    document.getElementById('editFullName').value = user.fullName || '';
    document.getElementById('editEmail').value = user.email || '';
    document.getElementById('editPhone').value = user.phoneNumber || '';
    document.getElementById('editEnabled').value = user.enabled === false ? 'false' : 'true';
    document.getElementById('editUserForm').dataset.userId = user.id;
    document.getElementById('editUserStatus').textContent = '';
    modal.classList.add('show');
    modal.setAttribute('aria-hidden', 'false');
}

function closeEditUser() {
    const modal = document.getElementById('editUserModal');
    modal.classList.remove('show');
    modal.setAttribute('aria-hidden', 'true');
}

document.getElementById('editUserForm')?.addEventListener('submit', async (event) => {
    event.preventDefault();
    const status = document.getElementById('editUserStatus');
    const userId = event.currentTarget.dataset.userId;
    const payload = {
        username: document.getElementById('editUsername').value,
        email: document.getElementById('editEmail').value,
        fullName: document.getElementById('editFullName').value,
        phoneNumber: document.getElementById('editPhone').value,
        role: 'OWNER'
    };

    try {
        const token = getToken();
        const response = await fetch(`${apiEndpoints.users}/${userId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
            body: JSON.stringify(payload)
        });
        if (!response.ok) {
            const message = await response.text();
            throw new Error(message || 'Không thể cập nhật tài khoản.');
        }
        const enabledValue = document.getElementById('editEnabled').value;
        await fetch(`${apiEndpoints.users}/${userId}/${enabledValue === 'true' ? 'enable' : 'disable'}`, {
            method: 'PATCH',
            headers: { 'Authorization': `Bearer ${token}` }
        });
        status.textContent = 'Cập nhật thành công.';
        status.classList.add('status-success');
        await loadUsers();
    } catch (error) {
        status.textContent = error.message || 'Có lỗi xảy ra.';
        status.classList.add('status-error');
    }
});

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

function extractRole(role) {
    if (!role) return '';
    if (typeof role === 'string') return role;
    if (typeof role === 'object') {
        return role.name || role.code || String(role);
    }
    return String(role);
}

function normalizeRole(role) {
    if (!role) {
        return '';
    }
    return role.startsWith(ROLE_PREFIX) ? role.slice(ROLE_PREFIX.length) : role;
}

function initials(name) {
    return name.split(' ').map(part => part[0]).join('').slice(0, 2).toUpperCase() || 'AD';
}

function getToken() {
    return sessionStorage.getItem('accessToken') || localStorage.getItem('accessToken') || '';
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
