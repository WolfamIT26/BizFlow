const ADMIN_API_BASE = window.location.pathname.startsWith('/admin/') ? '/admin' : '';
const REPORTS_API_BASE = `${ADMIN_API_BASE}/api/reports`;

/**
 * Authentication helpers
 */
function getToken() {
    return sessionStorage.getItem('accessToken') || localStorage.getItem('accessToken') || '';
}

function defaultHeaders() {
    const headers = {};
    const token = getToken();
    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }
    return headers;
}

function logout() {
    if (confirm('Bạn có chắc muốn đăng xuất?')) {
        sessionStorage.clear();
        localStorage.removeItem('accessToken');
        window.location.href = '/pages/login.html';
    }
}

window.logout = logout;

/**
 * Formatting helpers
 */
function formatCurrency(value) {
    const amount = Number(value) || 0;
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(amount);
}

function formatTrendLabel(value) {
    const num = Number(value);
    if (Number.isNaN(num)) {
        return { text: '--', state: '' };
    }
    const positive = num >= 0;
    const symbol = positive ? '↑' : '↓';
    return {
        text: `${symbol} ${Math.abs(num).toFixed(1)}%`,
        state: positive ? 'positive' : 'negative'
    };
}

function setText(id, value) {
    const el = document.getElementById(id);
    if (el) {
        el.textContent = value ?? '--';
    }
}

function applyTrend(id, value) {
    const el = document.getElementById(id);
    if (!el) return;
    const trend = formatTrendLabel(value);
    el.textContent = trend.text;
    el.classList.remove('positive', 'negative');
    if (trend.state) {
        el.classList.add(trend.state);
    }
}

/**
 * Revenue cards + tables
 */
async function loadRevenueComparison() {
    try {
        const res = await fetch(`${REPORTS_API_BASE}/revenue/comparison`, {
            headers: defaultHeaders()
        });
        if (!res.ok) {
            throw new Error('Không lấy được dữ liệu so sánh');
        }
        const data = await res.json();
        setText('todayRevenue', formatCurrency(data.todayRevenue));
        applyTrend('todayChange', data.todayChange);
        setText('weeklyRevenue', formatCurrency(data.weeklyRevenue));
        applyTrend('weeklyChange', data.weeklyChange);
        setText('monthlyRevenue', formatCurrency(data.monthlyRevenue));
        applyTrend('monthlyChange', data.monthlyChange);
        const margin = Number(data.monthlyMargin) || 0;
        setText('profitMargin', `${margin.toFixed(1)}%`);
        applyTrend('marginChange', data.marginChange);
    } catch (error) {
        console.error('loadRevenueComparison', error);
        setText('todayRevenue', '--');
        applyTrend('todayChange', null);
        setText('weeklyRevenue', '--');
        applyTrend('weeklyChange', null);
        setText('monthlyRevenue', '--');
        applyTrend('monthlyChange', null);
        setText('profitMargin', '-- %');
        applyTrend('marginChange', null);
    }
}

async function loadRevenueTable(url) {
    try {
        const res = await fetch(url, {
            headers: defaultHeaders()
        });
        if (!res.ok) {
            throw new Error('Không lấy được dữ liệu doanh thu');
        }
        const payload = await res.json();
        renderDailyBreakdown(payload.dailyBreakdown || []);
    } catch (error) {
        console.error('loadRevenueTable', error);
        const tbody = document.getElementById('dailyRevenueTableBody');
        if (tbody) {
            tbody.innerHTML = '<tr><td colspan="5" class="empty-box">Không có dữ liệu</td></tr>';
        }
    }
}

function renderDailyBreakdown(items) {
    const tbody = document.getElementById('dailyRevenueTableBody');
    if (!tbody) return;
    if (!items.length) {
        tbody.innerHTML = '<tr><td colspan="5" class="empty-box">Không có dữ liệu</td></tr>';
        return;
    }
    tbody.innerHTML = items.map(item => {
        const profit = Number(item.profit) || 0;
        const margin = Number(item.margin) || 0;
        const marginColor = margin >= 30 ? '#10b981' : (margin >= 15 ? '#d97706' : '#ef4444');
        return `
            <tr>
                <td>${item.date}</td>
                <td><strong>${formatCurrency(item.revenue)}</strong></td>
                <td>${formatCurrency(item.cost)}</td>
                <td style="color:${profit >= 0 ? '#10b981' : '#ef4444'};"><strong>${formatCurrency(profit)}</strong></td>
                <td style="color:${marginColor};"><strong>${margin.toFixed(1)}%</strong></td>
            </tr>
        `;
    }).join('');
}

async function loadWeeklyBreakdown() {
    await loadRevenueTable(`${REPORTS_API_BASE}/revenue/weekly`);
}

async function loadCustomRange() {
    const start = document.getElementById('reportStartDate')?.value;
    const end = document.getElementById('reportEndDate')?.value;
    if (!start || !end) {
        alert('Vui lòng chọn khoảng thời gian');
        return;
    }
    await loadRevenueTable(`${REPORTS_API_BASE}/revenue/custom?startDate=${start}&endDate=${end}`);
}

/**
 * Top products + low stock
 */
async function loadTopProducts() {
    try {
        const res = await fetch(`${REPORTS_API_BASE}/top-products/monthly?limit=10`, {
            headers: defaultHeaders()
        });
        if (!res.ok) {
            throw new Error('Không lấy được top sản phẩm');
        }
        const data = await res.json();
        const tbody = document.getElementById('topProductsTableBody');
        if (!tbody) return;
        if (!data.length) {
            tbody.innerHTML = '<tr><td colspan="5" class="empty-box">Không có sản phẩm nổi bật</td></tr>';
            return;
        }
        tbody.innerHTML = data.map((item, idx) => {
            const profit = Number(item.profit) || 0;
            const profitColor = profit >= 0 ? '#10b981' : '#ef4444';
            return `
                <tr>
                    <td><strong>${idx + 1}</strong></td>
                    <td>
                        <div><strong>${item.productName}</strong></div>
                        <div style="font-size:11px;color:#6b7280;">${item.productCode || '-'}</div>
                    </td>
                    <td><strong>${item.quantitySold || 0}</strong></td>
                    <td><strong>${formatCurrency(item.revenue)}</strong></td>
                    <td style="color:${profitColor};"><strong>${formatCurrency(profit)}</strong></td>
                </tr>
            `;
        }).join('');
    } catch (error) {
        console.error('loadTopProducts', error);
    }
}

async function loadLowStock() {
    try {
        const summaryRes = await fetch(`${REPORTS_API_BASE}/low-stock/summary`, {
            headers: defaultHeaders()
        });
        if (summaryRes.ok) {
            const summary = await summaryRes.json();
            const total = Number(summary.total) || 0;
            const critical = Number(summary.critical) || 0;
            const warning = Number(summary.warning) || 0;
            const normal = Math.max(0, total - critical - warning);
            const summaryEl = document.getElementById('lowStockSummary');
            if (summaryEl) {
                summaryEl.innerHTML = `
                    <span class="alert-badge critical">🔴 Nghiêm trọng: ${critical}</span>
                    <span class="alert-badge warning">🟡 Cảnh báo: ${warning}</span>
                    <span class="alert-badge normal">🟢 Bình thường: ${normal}</span>
                `;
            }
        }

        const res = await fetch(`${REPORTS_API_BASE}/low-stock`, {
            headers: defaultHeaders()
        });
        const tbody = document.getElementById('lowStockTableBody');
        if (!tbody) return;
        if (!res.ok) {
            throw new Error('Không lấy được danh sách tồn kho');
        }
        const stock = await res.json();
        if (!stock.length) {
            tbody.innerHTML = '<tr><td colspan="5" class="empty-box">Không có cảnh báo tồn kho</td></tr>';
            return;
        }
        tbody.innerHTML = stock.map(item => {
            const level = item.alertLevel || 'WARNING';
            const label = level === 'CRITICAL' ? '🔴 Nghiêm trọng' : '🟡 Cảnh báo';
            const badgeClass = level === 'CRITICAL' ? 'critical' : 'warning';
            return `
                <tr>
                    <td>${item.productName}</td>
                    <td>${item.productCode || '-'}</td>
                    <td><strong>${item.currentStock ?? 0}</strong></td>
                    <td>${item.threshold ?? '-'}</td>
                    <td><span class="alert-badge ${badgeClass}">${label}</span></td>
                </tr>
            `;
        }).join('');
    } catch (error) {
        console.error('loadLowStock', error);
    }
}

/**
 * Init
 */
function setDefaultDateRange() {
    const today = new Date();
    const start = new Date(today);
    start.setDate(start.getDate() - 6);
    const startInput = document.getElementById('reportStartDate');
    const endInput = document.getElementById('reportEndDate');
    if (startInput) {
        startInput.value = start.toISOString().split('T')[0];
    }
    if (endInput) {
        endInput.value = today.toISOString().split('T')[0];
    }
}

document.addEventListener('DOMContentLoaded', () => {
    setDefaultDateRange();
    loadRevenueComparison();
    loadWeeklyBreakdown();
    loadTopProducts();
    loadLowStock();
    document.getElementById('loadRangeBtn')?.addEventListener('click', loadCustomRange);
});
