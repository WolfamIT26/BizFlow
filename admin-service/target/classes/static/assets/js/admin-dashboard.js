const ADMIN_API_BASE = window.location.pathname.startsWith('/admin/') ? '/admin' : '';
const ALT_ADMIN_API_BASE = ADMIN_API_BASE ? '' : '/admin';
const ROLE_PREFIX = 'ROLE_';
        const apiEndpoints = {
            adminSummary: `${ADMIN_API_BASE}/api/dashboard/admin-summary`,
            recentUsers: `${ADMIN_API_BASE}/api/dashboard/recent-users`,
            branches: `${ADMIN_API_BASE}/api/dashboard/branches`,
            createUser: `${ADMIN_API_BASE}/api/users`,
            users: `${ADMIN_API_BASE}/api/users`,
            customers: `${ADMIN_API_BASE}/api/customers`,
            search: `${ADMIN_API_BASE}/api/admin/search`
        };

        let currentUsers = [];
        let currentCustomers = [];
        let selectedUserId = null;
        let selectedCustomerId = null;

        window.addEventListener('load', () => {
            enforceAuth();
            renderHeader();
            loadAdminSummary();
            loadRecentUsers();
            loadRecentCustomers();
            loadBranches();
            wireCreateUserForm();
            wirePasswordToggle('adminPassword', 'toggleAdminPassword');
            wireUserSearch();
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

        async function loadAdminSummary() {
            try {
                const response = await fetch(apiEndpoints.adminSummary, {
                headers: { 'Authorization': `Bearer ${getToken()}` }
            });
                if (!response.ok) {
                    throw new Error('Không thể tải dữ liệu tổng quan');
                }
                const data = await response.json();
                document.getElementById('totalUsers').textContent = formatNumber(data.totalUsers);
                document.getElementById('activeEmployees').textContent = formatNumber(data.totalEmployees);
                document.getElementById('totalBranches').textContent = formatNumber(data.totalBranches);
                document.getElementById('openBranches').textContent = formatNumber(data.activeBranches);
                document.getElementById('totalProducts').textContent = formatNumber(data.totalProducts);
                document.getElementById('totalCustomers').textContent = formatNumber(data.totalCustomers);
            } catch (error) {
                setTextContent('totalUsers', '--');
                setTextContent('activeEmployees', '--');
                setTextContent('totalBranches', '--');
                setTextContent('openBranches', '--');
                setTextContent('totalProducts', '--');
                setTextContent('totalCustomers', '--');
            }
        }

        async function loadRecentUsers() {
            const body = document.getElementById('recentUsersBody');
            try {
                const response = await fetch(apiEndpoints.recentUsers, {
                headers: { 'Authorization': `Bearer ${getToken()}` }
            });
                if (!response.ok) {
                    throw new Error('Không thể tải dữ liệu người dùng');
                }
                const users = await response.json();
                body.innerHTML = '';
                if (!users.length) {
                    body.innerHTML = '<tr><td colspan="4" class="empty-box">Chưa có dữ liệu người dùng gần đây.</td></tr>';
                    return;
                }
                users.forEach(user => {
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td>${escapeHtml(user.username || '-') }</td>
                        <td>${escapeHtml(user.fullName || '-') }</td>
                        <td>${escapeHtml(user.role || '-') }</td>
                        <td>${formatTimestamp(user.createdAt) }</td>
                    `;
                    body.appendChild(row);
                });
            } catch (error) {
                body.innerHTML = '<tr><td colspan="4" class="empty-box">Không thể tải dữ liệu người dùng.</td></tr>';
            }
        }

        async function loadRecentCustomers() {
            const body = document.getElementById('recentCustomersBody');
            if (!body) {
                return;
            }
            try {
                const response = await fetch(apiEndpoints.customers, {
                headers: { 'Authorization': `Bearer ${getToken()}` }
            });
                if (!response.ok) {
                    throw new Error('KhÃ´ng thá»ƒ táº£i dá»¯ liá»‡u khÃ¡ch hÃ ng');
                }
                const customers = await response.json();
                const list = Array.isArray(customers) ? customers : [];
                const sorted = list.slice().sort((a, b) => {
                    const aTime = new Date(a.createdAt || a.created_at || 0).getTime();
                    const bTime = new Date(b.createdAt || b.created_at || 0).getTime();
                    if (!Number.isNaN(aTime) && !Number.isNaN(bTime) && aTime !== bTime) {
                        return bTime - aTime;
                    }
                    const aId = Number(a.id || 0);
                    const bId = Number(b.id || 0);
                    return bId - aId;
                });
                const recent = sorted.slice(0, 5);
                body.innerHTML = '';
                if (!recent.length) {
                    body.innerHTML = '<tr><td colspan="4" class="empty-box">ChÆ°a cÃ³ dá»¯ liá»‡u khÃ¡ch hÃ ng gáº§n Ä‘Ã¢y.</td></tr>';
                    return;
                }
                recent.forEach(customer => {
                    const row = document.createElement('tr');
                    const name = customer.name || '-';
                    const phone = customer.phone || '-';
                    const email = customer.email || '-';
                    const points = customer.totalPoints ?? customer.total_points ?? 0;
                    const tier = customer.tier || '-';
                    row.innerHTML = `
                        <td>${escapeHtml(name)}</td>
                        <td>${escapeHtml(phone)}<br><span class="card-subtitle">${escapeHtml(email)}</span></td>
                        <td>${escapeHtml(points)} / ${escapeHtml(tier)}</td>
                        <td>${formatTimestamp(customer.createdAt || customer.created_at)}</td>
                    `;
                    body.appendChild(row);
                });
            } catch (error) {
                body.innerHTML = '<tr><td colspan="4" class="empty-box">KhÃ´ng thá»ƒ táº£i dá»¯ liá»‡u khÃ¡ch hÃ ng.</td></tr>';
            }
        }

        async function loadBranches() {
            const body = document.getElementById('branchTableBody');
            try {
                const response = await fetch(apiEndpoints.branches, {
                headers: { 'Authorization': `Bearer ${getToken()}` }
            });
                if (!response.ok) {
                    throw new Error('Không thể tải dữ liệu chi nhánh');
                }
                const branches = await response.json();
                body.innerHTML = '';
                if (!branches.length) {
                    body.innerHTML = '<tr><td colspan="4" class="empty-box">Chưa có dữ liệu chi nhánh.</td></tr>';
                    return;
                }
                branches.forEach(branch => {
                    const statusText = branch.active ? 'Đang hoạt động' : 'Tạm ngưng';
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td>${escapeHtml(branch.name || '-') }</td>
                        <td>${escapeHtml(branch.ownerName || '-') }</td>
                        <td>${statusText}</td>
                        <td>${escapeHtml(branch.note || '-')}</td>
                    `;
                    body.appendChild(row);
                });
            } catch (error) {
                body.innerHTML = '<tr><td colspan="4" class="empty-box">Không thể tải dữ liệu chi nhánh.</td></tr>';
            }
        }

        async function fetchSearchResults(keyword, role) {
            const token = getToken();
            const headers = { 'Authorization': `Bearer ${token}` };
            const buildUrl = (base, path) => {
                const url = new URL(`${base}${path}`, window.location.origin);
                if (keyword) {
                    url.searchParams.set('keyword', keyword);
                }
                if (role && role !== 'all') {
                    url.searchParams.set('role', role);
                }
                return url;
            };

            const baseCandidates = [ADMIN_API_BASE];
            if (ALT_ADMIN_API_BASE !== ADMIN_API_BASE) {
                baseCandidates.push(ALT_ADMIN_API_BASE);
            }

            let lastError = null;
            for (const base of baseCandidates) {
                try {
                    const response = await fetch(buildUrl(base, '/api/admin/search').toString(), { headers });
                    if (response.ok) {
                        return response.json();
                    }
                    lastError = await response.text();
                } catch (error) {
                    lastError = error?.message || error;
                }
            }

            return fallbackClientSearch(keyword, role, headers, baseCandidates, lastError);
        }

        async function fetchListFallback(path, headers, baseCandidates) {
            let lastError = null;
            for (const base of baseCandidates) {
                try {
                    const response = await fetch(new URL(`${base}${path}`, window.location.origin).toString(), { headers });
                    if (response.ok) {
                        const data = await response.json();
                        return Array.isArray(data) ? data : [];
                    }
                    lastError = await response.text();
                } catch (error) {
                    lastError = error?.message || error;
                }
            }
            throw new Error(lastError || 'Kh?ng th? t?i d? li?u.');
        }

        function normalizeKeyword(value) {
            return (value || '')
                .toString()
                .toLowerCase()
                .normalize('NFD')
                .replace(/[\u0300-\u036f]/g, '');
        }

        function extractRoleValue(role) {
            if (!role) return '';
            if (typeof role === 'string') return role;
            if (typeof role === 'object') {
                return role.name || role.code || String(role);
            }
            return String(role);
        }

        async function fallbackClientSearch(keyword, role, headers, baseCandidates, lastError) {
            try {
                const [users, customers] = await Promise.all([
                    fetchListFallback('/api/users', headers, baseCandidates),
                    fetchListFallback('/api/customers', headers, baseCandidates)
                ]);

                const normalizedKeyword = normalizeKeyword(keyword);
                const filteredUsers = users.filter(user => {
                    const roleValue = extractRoleValue(user.role);
                    if (role && role !== 'all' && roleValue.toLowerCase() !== role.toLowerCase()) {
                        return false;
                    }
                    const combined = normalizeKeyword([
                        user.fullName,
                        user.username,
                        user.email,
                        user.phoneNumber,
                        user.id
                    ].join(' '));
                    return combined.includes(normalizedKeyword);
                }).slice(0, 8);

                const filteredCustomers = customers.filter(customer => {
                    const combined = normalizeKeyword([
                        customer.name,
                        customer.phone,
                        customer.email,
                        customer.id
                    ].join(' '));
                    return combined.includes(normalizedKeyword);
                }).slice(0, 8);

                return { users: filteredUsers, customers: filteredCustomers };
            } catch (error) {
                throw new Error(lastError || error?.message || 'Kh?ng th? t?m ki?m.');
            }
        }

function wireUserSearch() {
            const input = document.getElementById('adminSearchInput');
            const roleFilter = document.getElementById('adminRoleFilter');
            const clearBtn = document.getElementById('clearSearchBtn');
            const tbody = document.getElementById('searchUsersBody');
            const meta = document.getElementById('searchMeta');
            const dropdown = document.getElementById('searchDropdown');

            if (!input || !meta || !dropdown) {
                return;
            }

            let searchTimer;

            const renderUserRows = (list, showCard = true) => {
                const card = document.getElementById('userSearchCard');
                const tableWrap = document.getElementById('userTableWrap');
                if (card) card.style.display = showCard ? 'block' : 'none';
                if (tableWrap) tableWrap.style.display = showCard ? 'block' : 'none';
                if (!list.length) {
                    tbody.innerHTML = '<tr><td colspan="5" class="empty-box">Kh?ng t?m th?y t?i kho?n ph? h?p.</td></tr>';
                    return;
                }
                tbody.innerHTML = list.map(user => {
                    const name = user.fullName || user.username || '-';
                    const email = user.email || '-';
                    const phone = user.phoneNumber || '-';
                    const role = user.role || '-';
                    const status = user.enabled === false ? 'Ng?ng' : 'Ho?t ??ng';
                    return `
                        <tr>
                            <td>
                                <strong>${escapeHtml(name)}</strong><br>
                                <span class="card-subtitle">${escapeHtml(user.username || '-')}</span>
                            </td>
                            <td>${escapeHtml(email)}<br><span class="card-subtitle">${escapeHtml(phone)}</span></td>
                            <td>${escapeHtml(role)}</td>
                            <td>${status}</td>
                            <td class="actions">
                                <button class="action-btn" data-action="view" data-id="${user.id}">Xem</button>
                                <button class="action-btn" data-action="edit" data-id="${user.id}">S?a</button>
                                <button class="action-btn" data-action="toggle" data-id="${user.id}">${user.enabled === false ? "K?ch ho?t" : "Ng?ng"}</button>
                                <button class="action-btn danger" data-action="delete" data-id="${user.id}">X?a</button>
                            </td>
                        </tr>
                    `;
                }).join('');
            };

            const renderCustomerRows = list => {
                const card = document.getElementById('customerSearchCard');
                const tableWrap = document.getElementById('customerTableWrap');
                const body = document.getElementById('searchCustomersBody');
                if (!body) {
                    return;
                }
                if (card) card.style.display = list.length ? 'block' : 'none';
                if (tableWrap) tableWrap.style.display = list.length ? 'block' : 'none';
                if (!list.length) {
                    body.innerHTML = '<tr><td colspan="5" class="empty-box">Kh?ng t?m th?y kh?ch h?ng.</td></tr>';
                    return;
                }
                body.innerHTML = list.map(c => {
                    const name = c.name || 'Kh?ch h?ng';
                    const phone = c.phone || '-';
                    const email = c.email || '-';
                    const points = c.totalPoints ?? c.total_points ?? 0;
                    const tier = c.tier || '-';
                    const status = 'Ho?t ??ng';
                    return `
                        <tr>
                            <td>
                                <strong>${escapeHtml(name)}</strong><br>
                                <span class="card-subtitle">ID: ${c.id ?? '-'}</span>
                            </td>
                            <td>${escapeHtml(phone)}<br><span class="card-subtitle">${escapeHtml(email)}</span></td>
                            <td>${escapeHtml(points)} / ${escapeHtml(tier)}</td>
                            <td>${status}</td>
                            <td class="actions">
                                <button class="action-btn" data-action="view" data-id="${c.id}">Xem</button>
                            </td>
                        </tr>
                    `;
                }).join('');
            };

            window.renderCustomerRows = renderCustomerRows;

            const renderDropdownCombined = (usersList, customersList) => {
                const items = [];
                (usersList || []).slice(0, 5).forEach(user => {
                    items.push(`<div class="item" data-type="user" data-id="${user.id}">` +
                        `<div class="item-title">${escapeHtml(user.fullName || user.username || "-")}</div>` +
                        `<div class="item-sub">${escapeHtml(user.email || "-")} ? ${escapeHtml(user.role || "-")}</div>` +
                        `</div>`);
                });
                (customersList || []).slice(0, 5).forEach(c => {
                    items.push(`<div class="item" data-type="customer" data-id="${c.id}">` +
                        `<div class="item-title">${escapeHtml(c.name || "Kh?ch h?ng")}</div>` +
                        `<div class="item-sub">${escapeHtml(c.phone || "-")} ? Kh?ch h?ng</div>` +
                        `</div>`);
                });
                dropdown.innerHTML = items.length
                    ? items.join('')
                    : '<div class="item"><div class="item-title">Kh?ng t?m th?y k?t qu?</div></div>';
                dropdown.style.display = 'block';
            };

            const triggerSearch = () => {
                const keyword = input.value.trim();
                const roleValue = roleFilter.value;
                const userCard = document.getElementById('userSearchCard');
                const customerCard = document.getElementById('customerSearchCard');
                if (userCard) userCard.style.display = 'none';
                if (customerCard) customerCard.style.display = 'none';

                if (!keyword) {
                    meta.textContent = 'Nh?p t? kh?a ?? t?m ki?m t?i kho?n.';
                    renderUserRows([], false);
                    dropdown.style.display = 'none';
                    currentUsers = [];
                    currentCustomers = [];
                    return;
                }

                if (userCard) userCard.style.display = 'block';
                clearTimeout(searchTimer);
                searchTimer = setTimeout(async () => {
                    try {
                        const data = await fetchSearchResults(keyword, roleValue);
                        currentUsers = Array.isArray(data.users) ? data.users : [];
                        currentCustomers = Array.isArray(data.customers) ? data.customers : [];
                        meta.textContent = `T?m th?y ${currentUsers.length + currentCustomers.length} k?t qu?. Ch?n 1 ?? xem.`;
                        renderDropdownCombined(currentUsers, currentCustomers);
                        renderUserRows(currentUsers, true);
                        renderCustomerRows(currentCustomers);
                    } catch (error) {
                        meta.textContent = 'Kh?ng th? t?i k?t qu? t?m ki?m.';
                        dropdown.style.display = 'none';
                    }
                }, 250);
            };

            window.refreshAdminSearch = triggerSearch;

            tbody.addEventListener('click', async (event) => {
                const button = event.target.closest('button');
                if (!button) return;
                const action = button.dataset.action;
                const id = button.dataset.id;
                const user = currentUsers.find(u => String(u.id) === String(id));
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
                        triggerSearch();
                        await loadAdminSummary();
                        await loadRecentUsers();
                    } catch (error) {
                        alert('Kh?ng th? c?p nh?t tr?ng th?i t?i kho?n.');
                    }
                }
                if (action === 'delete') {
                    if (!confirm('B?n c? ch?c mu?n x?a t?i kho?n n?y?')) return;
                    try {
                        const token = getToken();
                        await fetch(`${apiEndpoints.users}/${id}`, {
                            method: 'DELETE',
                            headers: { 'Authorization': `Bearer ${token}` }
                        });
                        triggerSearch();
                        await loadAdminSummary();
                        await loadRecentUsers();
                    } catch (error) {
                        alert('Kh?ng th? x?a t?i kho?n.');
                    }
                }
            });

            const customerBody = document.getElementById('searchCustomersBody');
            customerBody?.addEventListener('click', (event) => {
                const button = event.target.closest('button');
                if (!button) return;
                const id = button.dataset.id;
                const customer = currentCustomers.find(c => String(c.id) === String(id));
                if (!customer) return;
                openCustomerDetail(customer);
            });

            dropdown.addEventListener('click', (event) => {
                const item = event.target.closest('.item');
                if (!item) return;
                const type = item.dataset.type;
                if (type === 'user') {
                    const user = currentUsers.find(u => String(u.id) === String(item.dataset.id));
                    if (user) {
                        const userCard = document.getElementById('userSearchCard');
                        const customerCard = document.getElementById('customerSearchCard');
                        if (userCard) userCard.style.display = 'block';
                        if (customerCard) { customerCard.dataset.allowShow = 'false'; customerCard.style.display = 'none'; }
                        const tableWrap = document.getElementById('userTableWrap');
                        if (tableWrap) tableWrap.style.display = 'block';
                        renderUserRows([user]);
                        meta.textContent = '?? ch?n 1 t?i kho?n. B?n c? th? xem, s?a, k?ch ho?t ho?c x?a b?n d??i.';
                    }
                } else if (type === 'customer') {
                    const customer = currentCustomers.find(c => String(c.id) === String(item.dataset.id));
                    if (customer) {
                        const userCard = document.getElementById('userSearchCard');
                        const customerCard = document.getElementById('customerSearchCard');
                        if (userCard) userCard.style.display = 'none';
                        if (customerCard) { customerCard.dataset.allowShow = 'true'; customerCard.style.display = 'block'; }
                        renderCustomerRows([customer]);
                        const customerMeta = document.getElementById('customerSearchMeta');
                        if (customerMeta) {
                            customerMeta.textContent = '?? ch?n 1 kh?ch h?ng. B?n c? th? xem chi ti?t b?n d??i.';
                        }
                    }
                }
                dropdown.style.display = 'none';
            });

            document.addEventListener('click', (event) => {
                if (!event.target.closest('.search')) {
                    dropdown.style.display = 'none';
                }
            });

            input.addEventListener('input', triggerSearch);
            input.addEventListener('focus', triggerSearch);
            roleFilter?.addEventListener('change', triggerSearch);
            clearBtn?.addEventListener('click', () => {
                input.value = '';
                roleFilter.value = 'all';
                const userCard = document.getElementById('userSearchCard');
                const customerCard = document.getElementById('customerSearchCard');
                if (userCard) userCard.style.display = 'none';
                if (customerCard) customerCard.style.display = 'none';
                triggerSearch();
            });
        }

function openUserDetail(user) {
            const modal = document.getElementById('userDetailModal');
            const grid = document.getElementById('userDetailGrid');
            const roleValue = typeof user.role === 'object' ? (user.role.name || user.role.code || '') : (user.role || '-');
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
                    <div class="detail-value">${escapeHtml(roleValue || '-')}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Trạng thái</div>
                    <div class="detail-value">${user.enabled === false ? 'Ngưng kích hoạt' : 'Đang hoạt động'}</div>
                </div>
            `;
            modal.classList.add('show');
            modal.setAttribute('aria-hidden', 'false');
        }

        function openEditUser(user) {
            const modal = document.getElementById('editUserModal');
            document.getElementById('editUsername').value = user.username || '';
            document.getElementById('editFullName').value = user.fullName || '';
            document.getElementById('editEmail').value = user.email || '';
            document.getElementById('editPhone').value = user.phoneNumber || '';
            const roleValue = typeof user.role === 'object' ? (user.role.name || user.role.code || '') : (user.role || '');
            document.getElementById('editRole').value = roleValue || 'EMPLOYEE';
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
                role: document.getElementById('editRole').value
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
                    throw new Error(message || 'Khong the cap nhat tai khoan.');
                }
                const enabledValue = document.getElementById('editEnabled').value;
                await fetch(`${apiEndpoints.users}/${userId}/${enabledValue === 'true' ? 'enable' : 'disable'}`, {
                    method: 'PATCH',
                    headers: { 'Authorization': `Bearer ${token}` }
                });
                status.textContent = 'Cập nhật thành công.';
                status.classList.add('status-success');
                window.refreshAdminSearch && window.refreshAdminSearch();
                await loadRecentUsers();
                await loadAdminSummary();
            } catch (error) {
                status.textContent = error.message || 'Co loi xay ra.';
                status.classList.add('status-error');
            }
        });

        async function openCustomerDetail(customer) {
            const modal = document.getElementById('customerDetailModal');
            const grid = document.getElementById('customerDetailGrid');
            const ordersBody = document.getElementById('customerOrdersBody');
            const points = customer.totalPoints ?? customer.total_points ?? 0;
            const tier = customer.tier || '-';
            grid.innerHTML = `
                <div class="detail-item">
                    <div class="detail-label">Tên khách hàng</div>
                    <div class="detail-value">${escapeHtml(customer.name || '-') }</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">SĐT</div>
                    <div class="detail-value">${escapeHtml(customer.phone || '-') }</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Email</div>
                    <div class="detail-value">${escapeHtml(customer.email || '-') }</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Điểm tích lũy</div>
                    <div class="detail-value">${escapeHtml(points)}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Hạng</div>
                    <div class="detail-value">${escapeHtml(tier)}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Trạng thái</div>
                    <div class="detail-value">Hoạt động</div>
                </div>
            `;

            ordersBody.innerHTML = '<tr><td colspan="4" class="empty-box">Đang tải...</td></tr>';
            try {
                const token = getToken();
                const response = await fetch(`${apiEndpoints.customers}/${customer.id}/orders`, {
                    headers: { 'Authorization': `Bearer ${token}` }
                });
                if (!response.ok) {
                    ordersBody.innerHTML = '<tr><td colspan="4" class="empty-box">Không tải được lịch sử mua hàng.</td></tr>';
                } else {
                    const orders = await response.json();
                    if (!orders.length) {
                        ordersBody.innerHTML = '<tr><td colspan="4" class="empty-box">Chưa có đơn hàng.</td></tr>';
                    } else {
                        ordersBody.innerHTML = orders.map(o => {
                            const total = o.totalAmount || o.total || 0;
                            const items = o.itemCount || (o.items ? o.items.length : 0);
                            return `
                                <tr>
                                    <td>${escapeHtml(o.invoiceNumber || o.id)}</td>
                                    <td>${formatTimestamp(o.createdAt)}</td>
                                    <td>${items}</td>
                                    <td>${formatNumber(total)}</td>
                                </tr>
                            `;
                        }).join('');
                    }
                }
            } catch (error) {
                ordersBody.innerHTML = '<tr><td colspan="4" class="empty-box">Không tải được lịch sử mua hàng.</td></tr>';
            }

            modal.classList.add('show');
            modal.setAttribute('aria-hidden', 'false');
        }

        function closeCustomerDetail() {
            const modal = document.getElementById('customerDetailModal');
            modal.classList.remove('show');
            modal.setAttribute('aria-hidden', 'true');
        }


function closeUserDetail() {
            const modal = document.getElementById('userDetailModal');
            modal.classList.remove('show');
            modal.setAttribute('aria-hidden', 'true');
        }
        function wireCreateUserForm() {
            const form = document.getElementById('adminCreateUserForm');
            const status = document.getElementById('adminUserStatus');
            form.addEventListener('submit', async event => {
                event.preventDefault();
                status.textContent = '';
                status.className = 'status-message';
                const data = Object.fromEntries(new FormData(form).entries());
                const payload = {
                    username: (data.username || '').trim(),
                    password: data.password || '',
                    email: (data.email || '').trim(),
                    fullName: (data.fullName || '').trim(),
                    phoneNumber: (data.phoneNumber || '').trim() || null,
                    role: data.role
                };

                try {
                    const response = await fetch(apiEndpoints.createUser, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${getToken()}` },
                        body: JSON.stringify(payload)
                    });
                    if (!response.ok) {
                        const message = await response.text();
                        throw new Error(message || 'Không thể tạo tài khoản');
                    }
                    status.textContent = 'Tạo tài khoản thành công.';
                    status.classList.add('status-success');
                    form.reset();
                    await loadAdminSummary();
                    await loadRecentUsers();
                    if (typeof loadOwnerOptions === 'function') {                        await loadOwnerOptions();                    }
                } catch (error) {
                    status.textContent = error.message || 'Có lỗi xảy ra.';
                    status.classList.add('status-error');
                }
            });
        }

        function logout() {
            if (confirm('Bạn có chắc muốn đăng xuất?')) {
                sessionStorage.clear();
                window.location.href = '/pages/login.html';
            }
        }

        function initials(name) {
            return name.split(' ').map(part => part[0]).join('').slice(0, 2).toUpperCase() || 'AD';
        }

        function wirePasswordToggle(inputId, buttonId) {
            const input = document.getElementById(inputId);
            const toggleBtn = document.getElementById(buttonId);
            if (!input || !toggleBtn) {
                return;
            }
            const eyeIcon = toggleBtn.querySelector('.eye-icon');
            const eyeSlashIcon = toggleBtn.querySelector('.eye-slash-icon');
            toggleBtn.addEventListener('click', () => {
                const isPassword = input.type === 'password';
                input.type = isPassword ? 'text' : 'password';
                if (eyeIcon && eyeSlashIcon) {
                    eyeIcon.style.display = isPassword ? 'none' : 'block';
                    eyeSlashIcon.style.display = isPassword ? 'block' : 'none';
                }
            });
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

        function setTextContent(id, value) {
            const el = document.getElementById(id);
            if (el) {
                el.textContent = value;
            }
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

        function normalizeRole(role) {
            if (!role) {
                return '';
            }
            return role.startsWith(ROLE_PREFIX) ? role.slice(ROLE_PREFIX.length) : role;
        }

        function getToken() {
            return sessionStorage.getItem('accessToken') || localStorage.getItem('accessToken') || '';
        }
